#!/usr/bin/env bash
#
# Linux Mint Cleanup — Audit Script
#
# Read-only. Makes NO changes to the system.
# Tailored for Linux Mint (Ubuntu-based: Cinnamon/MATE/Xfce, and LMDE).
# Run this in Phase 2 of the cleanup workflow to gather a structured picture
# of where disk space is going and what cleanup categories apply.
#
# Usage: bash audit.sh [output_file]
#   If output_file is given, results are written there in addition to stdout.
#
# Requires: bash, coreutils, findutils. Optional: ncdu (mentioned but not invoked).
# Some sections need sudo for accurate sizing (apt cache, Timeshift, system logs).

set -u

OUT="${1:-/dev/null}"

section() {
    local title="$1"
    printf '\n\n============================================================\n'
    printf '%s\n' "$title"
    printf '============================================================\n'
}

run() {
    local label="$1"; shift
    printf '\n--- %s ---\n' "$label"
    "$@" 2>&1 || printf '(command failed or not available)\n'
}

have() { command -v "$1" >/dev/null 2>&1; }

exec > >(tee -a "$OUT") 2>&1

cat <<EOF
============================================================
Linux Mint Cleanup — Audit
Date: $(date -Iseconds)
Host: $(hostname)
User: $(whoami)
============================================================
EOF

section "1. Mint edition and environment"
run "Mint info" cat /etc/linuxmint/info 2>/dev/null
run "lsb_release" lsb_release -a
run "os-release (LMDE check: Debian vs Ubuntu base)" cat /etc/os-release
run "Desktop environment" bash -c 'echo "${XDG_CURRENT_DESKTOP:-unknown}"'
run "Kernel (running)" uname -r
run "All installed kernels" bash -c 'dpkg --list 2>/dev/null | grep -E "^ii\s+linux-image-[0-9]"'

section "2. Mint-shipped packages present"
run "Mint packages installed" bash -c 'dpkg -l 2>/dev/null | grep -E "^ii\s+mint" | awk "{print \$2}"'

section "3. Package managers and runtimes detected"
for mgr in apt snap flatpak; do
    if have "$mgr"; then printf 'present: %s\n' "$mgr"; fi
done
for rt in docker podman containerd; do
    if have "$rt"; then printf 'present: %s\n' "$rt"; fi
done

section "4. Disk and inode usage"
run "Filesystems" df -hT
run "Inodes" df -i
run "Block devices" lsblk -o NAME,SIZE,FSUSED,FSAVAIL,MOUNTPOINT,TYPE

section "5. Top-level directory sizes"
run "/ top-level" bash -c 'sudo du -sh /* 2>/dev/null | sort -h | tail -15 || du -sh /* 2>/dev/null | sort -h | tail -15'
run "/var breakdown" bash -c 'sudo du -sh /var/* 2>/dev/null | sort -h | tail -15 || true'
run "/var/cache breakdown" bash -c 'sudo du -sh /var/cache/* 2>/dev/null | sort -h | tail -15 || true'

section "6. \$HOME — top 20 largest directories"
run "Largest dirs in \$HOME" bash -c "du -h -d 2 \"\$HOME\" 2>/dev/null | sort -h | tail -20"
run "Largest hidden dirs in \$HOME" bash -c "du -sh \"\$HOME\"/.[!.]* 2>/dev/null | sort -h | tail -15"

section "7. Timeshift snapshots (Mint-specific, often the largest reclaim category)"
if have timeshift; then
    run "Timeshift snapshot list" bash -c 'sudo timeshift --list 2>/dev/null'
    run "Timeshift raw storage size" bash -c 'sudo du -sh /timeshift 2>/dev/null'
    run "Timeshift per-snapshot sizes" bash -c 'sudo du -sh /timeshift/snapshots/*/ 2>/dev/null | sort -h'
    run "Timeshift config" bash -c 'sudo cat /etc/timeshift/timeshift.json 2>/dev/null | head -40'
    run "Orphan check (filesystem vs CLI)" bash -c '
        gui_count=$(sudo timeshift --list 2>/dev/null | grep -cE "^\s*[0-9]+\s+>")
        fs_count=$(sudo ls /timeshift/snapshots 2>/dev/null | wc -l)
        echo "Snapshots visible in --list: $gui_count"
        echo "Folders in /timeshift/snapshots: $fs_count"
        if [ "$gui_count" -ne "$fs_count" ] 2>/dev/null; then
            echo "WARNING: counts differ; possible orphaned/failed snapshots"
        fi'
else
    printf 'timeshift not installed (unusual on Mint) — skipping\n'
fi

section "8. APT — cache, autoremovable, residual configs, repo signing-key health"
run "Repo signing-key health (a broken key on any repo silently blocks mintupdate's automatic-upgrade timer)" bash -c '
    out="$(sudo apt-get update 2>&1)"
    if grep -qiE "NO_PUBKEY|GPG error|is not signed|EXPKEYSIG" <<<"$out"; then
        echo "WARNING: at least one repo has a signing-key problem — see below. This blocks the whole apt update, not just that repo."
        echo "$out" | grep -iE "NO_PUBKEY|GPG error|is not signed|EXPKEYSIG|Err:|^W:"
    else
        echo "OK — all configured repos verified cleanly"
    fi'
run "APT cache size" bash -c 'sudo du -sh /var/cache/apt/archives/ 2>/dev/null'
run "Autoremovable (dry run preview)" bash -c 'apt-get -s autoremove 2>/dev/null | grep -E "^(Remv|The following)" | head -50'
run "Residual configs (dpkg rc)" bash -c "dpkg -l 2>/dev/null | awk '/^rc/{print \$2}'"
run "Manually-installed package count" bash -c 'apt-mark showmanual 2>/dev/null | wc -l'
run "Largest installed packages (top 20)" bash -c "
    dpkg-query -Wf '\${Installed-Size}\t\${Package}\n' 2>/dev/null | \
    sort -nr | head -20 | \
    awk '{ printf \"%8.1f MB  %s\n\", \$1/1024, \$2 }'"

section "9. Mint-specific cache: apt-xapian-index"
run "apt-xapian-index size" bash -c 'sudo du -sh /var/cache/apt-xapian-index/ 2>/dev/null'

section "10. Other /var/cache items often worth clearing"
run "fontconfig cache" bash -c 'sudo du -sh /var/cache/fontconfig 2>/dev/null'
run "locate cache" bash -c 'sudo du -sh /var/cache/locate 2>/dev/null'

section "11. Snap (Ubuntu-based Mint only)"
if have snap; then
    run "Installed snaps" snap list
    run "All revisions" snap list --all
    run "Disabled (cleanable) revisions" bash -c "snap list --all 2>/dev/null | awk '/disabled/{print \$1, \$3}'"
    run "Snap refresh.retain setting" bash -c 'snap get system refresh.retain 2>/dev/null || echo "(default, typically 3)"'
    run "Snap storage usage" bash -c 'sudo du -sh /var/lib/snapd 2>/dev/null'
else
    printf 'snap not present (expected on LMDE or snap-removed Mint)\n'
fi

section "12. Flatpak (Mint Software Manager defaults to this — often biggest single targets)"
if have flatpak; then
    run "Installed apps with sizes" flatpak list --app --columns=application,name,size
    run "Installed runtimes with sizes" flatpak list --runtime --columns=application,version,size
    run "Would be uninstalled by --unused" bash -c 'flatpak uninstall --unused --assumeno 2>&1 | head -50 || true'
    run "Flatpak storage usage" bash -c 'du -sh ~/.local/share/flatpak 2>/dev/null; sudo du -sh /var/lib/flatpak 2>/dev/null'
else
    printf 'flatpak not present (unusual on Mint)\n'
fi

section "13. Journal logs"
if have journalctl; then
    run "Current journal disk usage" journalctl --disk-usage
fi

section "14. /var/log size"
run "/var/log breakdown" bash -c 'sudo du -sh /var/log/* 2>/dev/null | sort -h | tail -15 || du -sh /var/log/* 2>/dev/null | sort -h | tail -15'
run "Old rotated logs (>30 days)" bash -c 'sudo find /var/log -type f \( -name "*.gz" -o -name "*.[0-9]" \) -mtime +30 2>/dev/null | head -20'

section "15. User caches (~/.cache and friends)"
run "~/.cache breakdown" bash -c "du -sh \"\$HOME/.cache\"/* 2>/dev/null | sort -h | tail -15"
run "Thumbnail cache" bash -c "du -sh \"\$HOME/.cache/thumbnails\" 2>/dev/null"

section "16. Developer caches"
for path in "$HOME/.npm" "$HOME/.cache/pip" "$HOME/.cargo/registry" "$HOME/.gradle/caches" "$HOME/.m2/repository" "$HOME/.cache/go-build" "$HOME/go/pkg/mod" "$HOME/.conda" "$HOME/miniconda3" "$HOME/anaconda3"; do
    if [ -d "$path" ]; then
        run "$path" du -sh "$path"
    fi
done

section "17. Docker / Podman"
if have docker; then
    run "docker system df" bash -c 'docker system df 2>/dev/null || echo "(docker daemon not running or no permission)"'
    run "Named volumes (review before pruning!)" bash -c 'docker volume ls 2>/dev/null'
fi
if have podman; then
    run "podman system df" podman system df
fi

section "18. Trash"
run "~/.local/share/Trash" bash -c "du -sh \"\$HOME/.local/share/Trash\" 2>/dev/null"
run "Trash file count" bash -c "ls \"\$HOME/.local/share/Trash/files\" 2>/dev/null | wc -l"

section "19. AppImages and manual installs"
run "AppImages in \$HOME" bash -c "find \"\$HOME\" -maxdepth 4 -name '*.AppImage' 2>/dev/null"
run "/opt contents" ls -la /opt/ 2>/dev/null
run "/usr/local/bin contents" ls -la /usr/local/bin/ 2>/dev/null

section "20. Large old files (>100MB, atime >180 days) in \$HOME"
run "Candidates for archival/deletion" bash -c "find \"\$HOME\" -type f -size +100M -atime +180 2>/dev/null | head -30 | xargs -I{} du -h '{}' 2>/dev/null | sort -h"

section "21. Build artefacts in \$HOME"
run "node_modules directories" bash -c "find \"\$HOME\" -type d -name node_modules -prune 2>/dev/null | head -20"
run "Rust target/ directories" bash -c "find \"\$HOME\" -type d -name target -prune 2>/dev/null | head -20"

section "Audit complete"
echo
echo "Next steps:"
echo "  1. Review this output."
echo "  2. The agent will categorise findings into tiers 1/2/3 per safe-targets.md."
echo "  3. A recommendation report follows, then explicit user approval before any destructive action."
echo
echo "Mint-specific reminders:"
echo "  - Timeshift snapshots (section 7) are often the largest single reclaim category."
echo "  - Large Flatpaks (section 12) may have smaller .deb equivalents worth swapping to."
echo "  - Use Update Manager → Linux kernels for kernel removal, not manual apt purge."
echo
echo "For interactive drill-down, the user can run:  ncdu -x \$HOME  (or any path)"
