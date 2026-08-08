#!/bin/bash
#
# system-maintenance — routine housekeeping, run fortnightly by a systemd timer.
#   1. checks APT repo signing keys are healthy (detect-only, never auto-fixes)
#   2. trims systemd journal logs to the last 14 days
#   3. clears the APT package cache (.deb files re-download on demand)
#   4. deletes trash items that have sat in the bin for 30+ days
#   5. removes unused Flatpak runtimes
#   6. prunes old kernels, keeping the 2 newest plus the running one
#
# Every action is tier-1 / clearly-safe and regenerating — no app purges, no
# tier-3 removals, no Timeshift or Docker-volume deletion. Keep it that way.
# Step 1 is detection-only for the same reason: re-trusting a signing key is
# a judgement call, so it logs a warning rather than fetching anything.
#
# Install to /usr/local/sbin/system-maintenance and drive it with a systemd
# timer (see the "Recommended: scheduled system maintenance" section of
# SKILL.md). Safe to run by hand at any time.
#
set -uo pipefail
export DEBIAN_FRONTEND=noninteractive
tag=system-maintenance

logger -t "$tag" "Starting system maintenance"

# 1. Check APT repo signing keys are healthy. A missing/expired key on ANY
#    configured repo (e.g. a third-party repo like Tailscale's) makes the
#    whole `apt update` fail, which silently breaks mintupdate's own
#    automatic-upgrade timer too — updates then pile up unnoticed until the
#    user opens Update Manager by hand. Detect and log loudly; do not fetch
#    or trust a new key unattended.
apt_update_output="$(apt-get update 2>&1)"
if grep -qiE "NO_PUBKEY|GPG error|is not signed|EXPKEYSIG" <<<"$apt_update_output"; then
    logger -t "$tag" "WARNING: apt update reported a repo signing-key problem — automatic upgrades may be silently failing. Run 'sudo apt update' to see which repo, then re-fetch its key (see SKILL.md 'Common failure modes to avoid')."
    logger -t "$tag" "$apt_update_output"
else
    logger -t "$tag" "APT repo signing keys OK"
fi

# 2. Trim the systemd journal to the last 14 days.
journalctl --vacuum-time=14d 2>&1 | logger -t "$tag"

# 3. Clear the downloaded-package cache.
apt-get clean && logger -t "$tag" "APT cache cleared"

# 4. Delete trash items older than 30 days, for every user account.
removed=0
for base in /home/*/.local/share/Trash /root/.local/share/Trash; do
    [[ -d "$base/info" ]] || continue
    while IFS= read -r -d '' info; do
        name="$(basename "$info" .trashinfo)"
        rm -rf -- "$base/files/$name"
        rm -f  -- "$info"
        removed=$((removed + 1))
    done < <(find "$base/info" -name '*.trashinfo' -mtime +30 -print0 2>/dev/null)
done
logger -t "$tag" "Removed $removed trash item(s) older than 30 days"

# 5. Remove unused Flatpak runtimes (runtimes no installed app references).
if command -v flatpak >/dev/null 2>&1; then
    flatpak uninstall --unused --assumeyes 2>&1 | logger -t "$tag"
fi

# 6. Prune old kernels (keep the 2 newest plus the running one).
if [[ -x /usr/local/sbin/purge-old-kernels ]]; then
    /usr/local/sbin/purge-old-kernels && logger -t "$tag" "Kernel prune complete"
fi

logger -t "$tag" "System maintenance complete"
