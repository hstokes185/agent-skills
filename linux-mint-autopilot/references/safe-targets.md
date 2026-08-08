# Safe cleanup targets — the menu (Linux Mint)

Every entry here is a category of cleanup the skill may propose on a Mint system. Each entry gives the commands, the typical reclaim range, the reversibility characteristic, and any Mint-specific nuances.

Always **measure before** proposing (use `du -sh` or the manager's `df` equivalent) so the estimate is grounded. The reclaim ranges below are typical observations, not guarantees.

---

## Tier 1 — Low risk, regenerable

These are the first recommendations to make. They free meaningful space, fail safely, and the cleaned data regenerates from upstream or is reproduced by normal use.

### 1a. APT cache

```bash
# Inspect
du -sh /var/cache/apt/archives/
du -sh /var/cache/apt/archives/partial/

# Clean — removes all cached .deb files
sudo apt clean

# Lighter alternative — keeps current versions, removes superseded only
sudo apt autoclean
```

Typical reclaim: 200 MB – 2 GB. Fully reversible (packages re-download from repos when next needed).

### 1b. `apt-xapian-index` cache (Mint-specific)

The Synaptic search index. Often 100-500 MB on a long-lived install.

```bash
# Inspect
du -sh /var/cache/apt-xapian-index/

# Force a rebuild from scratch (clears stale data)
sudo update-apt-xapian-index -f

# Or simply remove the cached database; will rebuild on next Synaptic search
sudo rm -rf /var/cache/apt-xapian-index/index*

# Nuclear: uninstall the indexer entirely (Synaptic still works, searches slower)
# Only do this if the user has confirmed they rarely use Synaptic
sudo apt purge apt-xapian-index
```

Typical reclaim: 100 MB – 500 MB. Auto-rebuilds on next Synaptic launch unless uninstalled.

### 1c. Other miscellaneous `/var/cache` directories

```bash
# Font cache — rebuilds on next fc-cache run
sudo du -sh /var/cache/fontconfig
# Safe to clear; rebuilds automatically:
# sudo rm -rf /var/cache/fontconfig/*

# Locate database (only if mlocate/plocate installed)
sudo du -sh /var/cache/locate
# Typically 50-200 MB; rebuilds on next `updatedb` (daily cron).

# debconf state — DO NOT touch /var/cache/debconf, system needs it
```

Typical reclaim: 50 MB – 300 MB combined.

### 1d. Journal logs

```bash
# Current size
journalctl --disk-usage

# Trim to last 7 days (adjust as appropriate for a personal machine)
sudo journalctl --vacuum-time=7d

# Or cap total size
sudo journalctl --vacuum-size=500M
```

Typical reclaim: 100 MB – 2 GB. For a machine being debugged, keep longer.

### 1e. Thumbnail cache

```bash
du -sh ~/.cache/thumbnails/
rm -rf ~/.cache/thumbnails/*
```

Typical reclaim: 50 MB – 1 GB. Regenerates on demand when browsing image directories in Nemo/Caja/Thunar.

### 1f. Browser caches

```bash
# Firefox (Mint's default browser)
rm -rf ~/.cache/mozilla/firefox/*/cache2/
# Chrome / Chromium
rm -rf ~/.cache/google-chrome/Default/Cache/
rm -rf ~/.cache/chromium/Default/Cache/
```

**Important**: target the `Cache` subdirectories only, never the profile directory itself (which holds bookmarks, sessions, history, logins). Typical reclaim: 200 MB – 2 GB.

### 1g. General `~/.cache` review

```bash
du -sh ~/.cache/* | sort -h | tail -20
```

After review, individual sub-directories may be safe to clean. Do not blanket `rm -rf ~/.cache` — some apps store recoverable session state there.

### 1h. Trash

```bash
du -sh ~/.local/share/Trash/
# After user review:
rm -rf ~/.local/share/Trash/files/*
rm -rf ~/.local/share/Trash/info/*
# Or just use the Nemo/Caja "Empty Trash" GUI option
```

Always have the user review the trash contents first. Permanent.

### 1i. Orphaned dependencies (`apt autoremove`)

```bash
# Preview first
apt autoremove --dry-run

# Execute
sudo apt autoremove

# Stronger — also removes leftover config files for autoremoved packages
sudo apt autoremove --purge
```

Typical reclaim: 100 MB – 3 GB. Always show the list before removing — `autoremove` occasionally targets things the user actively wants. On Mint specifically, double-check the list does not include `mint-meta-*` or DE meta-packages (it shouldn't, but verify).

---

## Tier 2 — Medium risk, recoverable with effort

### 2a. Timeshift snapshots (Mint flagship feature, often biggest single reclaim)

```bash
# List all snapshots with sizes
sudo timeshift --list

# Inspect raw storage (catches failed/orphaned snapshots not in the GUI)
sudo ls -la /timeshift/snapshots/ 2>/dev/null
sudo du -sh /timeshift/snapshots/*/ 2>/dev/null
```

**Understand the hard-link behaviour before deleting**: Timeshift snapshots share unchanged files via hard links. The *oldest* snapshot holds the most unique data; deleting the *newest* often frees almost nothing. To reclaim real space, delete older snapshots and reduce the retention count in Timeshift settings.

```bash
# Delete a specific snapshot (use the exact name from --list)
sudo timeshift --delete --snapshot '2026-04-15_03-00-01'

# Delete all snapshots (extreme — leaves no rollback)
sudo timeshift --delete-all

# Reduce future retention (open Timeshift GUI → Settings → Schedule)
# Or edit /etc/timeshift/timeshift.json directly:
# Keep: 5 daily, 2 weekly, 1 monthly is a sane personal default
```

If `timeshift --list` shows fewer snapshots than `ls /timeshift/snapshots/`, there are orphaned/failed snapshots. These can be removed by deleting the folder directly **only if** Timeshift's database is clearly out of sync — but prefer running `sudo timeshift --check` first.

Typical reclaim: 5 GB – 80 GB. Frequently the single largest cleanup category on a Mint machine.

**Recommend afterwards**: move Timeshift's snapshot location to a separate partition or external drive if possible, so the root partition cannot fill from snapshots in future.

### 2b. Old kernels — prefer Update Manager

Mint's Update Manager has a dedicated kernel screen that handles selection, dependency resolution, and GRUB regeneration correctly. **This is the recommended Mint workflow.**

```
Open Update Manager → View → Linux kernels
```

Kernels marked "Remove" are safe to remove (the running kernel and the most recent are never marked). Hit "Continue" and Update Manager handles the rest.

CLI fallback:

```bash
# Currently running — NEVER remove this
uname -r

# List installed kernels
dpkg --list | grep -E "linux-image-[0-9]"

# Safest CLI path: let autoremove handle it
sudo apt autoremove --purge
```

Manual removal of specific kernels is high-risk. If the user insists, **always leave the running kernel plus one fallback**. After removal, regenerate GRUB:

```bash
sudo update-grub
```

Typical reclaim: 300 MB per kernel.

### 2c. Snap old revisions (Ubuntu-based Mint only)

```bash
# Limit retained revisions (must be ≥ 2)
sudo snap set system refresh.retain=2

# Remove disabled (old) revisions explicitly
snap list --all | awk '/disabled/{print $1, $3}' | \
  while read name rev; do sudo snap remove "$name" --revision="$rev"; done
```

Typical reclaim: 1 GB – 5 GB. LMDE has no snap by default — check `which snap` first.

### 2d. Flatpak unused runtimes

This is **especially important on Mint** because Software Manager defaults to Flatpak.

```bash
# Inspect
flatpak list --runtime --columns=application,version,size
du -sh ~/.local/share/flatpak /var/lib/flatpak 2>/dev/null

# List what would be removed
flatpak uninstall --unused --assumeno

# Execute
flatpak uninstall --unused

# Also drop user data for already-uninstalled apps
flatpak uninstall --unused --delete-data
```

Typical reclaim: 500 MB – 3 GB.

### 2e. Residual configs

Packages removed without `--purge` leave config marked `rc` in dpkg:

```bash
# List
dpkg -l | grep '^rc'

# Remove the residual configs only (the packages are already gone)
sudo apt purge $(dpkg -l | awk '/^rc/{print $2}')
```

Typical reclaim: 10 MB – 200 MB. Worth doing for tidiness more than space.

### 2f. Old rotated logs

```bash
# Inspect
sudo du -sh /var/log/* | sort -h | tail -10

# Compressed rotations older than 30 days
sudo find /var/log -type f -name "*.gz" -mtime +30 -delete
sudo find /var/log -type f -name "*.[0-9]" -mtime +30 -delete
```

Typical reclaim: 50 MB – 500 MB. Do not touch live `.log` files — services hold open handles.

### 2g. Developer caches

```bash
# pip
pip cache dir
pip cache purge

# npm
npm cache verify   # or: npm cache clean --force

# Yarn
yarn cache clean

# Cargo (Rust)
du -sh ~/.cargo/registry/cache ~/.cargo/registry/src
# Manually clean older crates or use cargo-cache:
cargo install cargo-cache && cargo cache --autoclean

# Go
go clean -cache
go clean -modcache   # nuclear: rm all module download cache

# Gradle
du -sh ~/.gradle/caches/
rm -rf ~/.gradle/caches/<specific old version>

# Maven
du -sh ~/.m2/repository/
# Selective cleanup advised — full nuke means very slow next build

# Conda
conda clean --all
```

Typical reclaim varies enormously: a few hundred MB to 10+ GB depending on what languages the user works in. Caches rebuild but the next build of each project will be slow — flag this so the user is not surprised.

### 2h. Docker / Podman cleanup

```bash
# Inspect first — this is the most important command in Docker cleanup
docker system df
docker system df -v   # verbose, per-image/per-volume breakdown

# Safe: dangling images, stopped containers, unused networks
docker system prune

# More aggressive: all unused images (not just dangling)
docker system prune -a

# Build cache only
docker builder prune
docker builder prune --keep-storage 5g

# Volumes — DANGEROUS if user has named volumes with data
docker volume ls
docker volume prune   # only after confirming volumes are throwaway
```

Equivalent for Podman: `podman system df`, `podman system prune`, etc.

Typical reclaim: 5 GB – 50+ GB on developer machines.

**Critical caveat**: `docker volume prune` and `docker system prune --volumes` can destroy persistent local state (databases, generated artefacts) that lives in named volumes. Always list volumes first, identify which hold real data, and only prune after explicit confirmation.

---

## Tier 3 — Judgement calls

These require the user to decide what they actually use. The agent's job is to surface the candidates clearly, not decide for them.

### 3a. Large Flatpak apps that have native `.deb` equivalents

Software Manager often offers both. Users frequently end up with a 1-2 GB Flatpak when a 50 MB `.deb` exists. Flag these in the audit. Example pattern:

```bash
flatpak list --app --columns=application,name,size | sort -k3 -h
# For each large one, check whether a .deb exists:
apt-cache search <name>
```

Removal:
```bash
flatpak uninstall <app-id>
flatpak uninstall --delete-data <app-id>   # also drops ~/.var/app/<id>
sudo apt install <native-package>           # if user wants the native version
```

Typical reclaim: 500 MB – 3 GB per swapped app.

### 3b. User-installed applications no longer in use

Inventory commands by manager:

```bash
# apt — manually installed (not pulled in as dependencies)
apt-mark showmanual | sort

# Snaps
snap list

# Flatpaks
flatpak list --app

# pip user installs
pip list --user

# npm globals
npm list -g --depth=0

# Cargo binaries
ls ~/.cargo/bin/

# Manual installs in /usr/local
ls -la /usr/local/bin/
ls -la /opt/

# AppImages (common locations)
find ~ -maxdepth 3 -name "*.AppImage" 2>/dev/null
find /opt -name "*.AppImage" 2>/dev/null
```

Present this list grouped by manager. **Filter out core Mint packages from the apt list** before showing it — `mint-meta-*`, the DE meta-package, `mintupdate/install/sources/welcome` etc. (see `protected-paths.md`). Ask which the user no longer uses. For each:

- apt: `sudo apt purge <pkg>` (then `sudo apt autoremove --purge`) — purge once the user has approved the removal, so configuration is cleared too and no `rc`-state residue is left behind
- snap: `sudo snap remove <name>`
- flatpak: `flatpak uninstall --delete-data <app-id>` (drops `~/.var/app/<id>` too)
- pip user: `pip uninstall <pkg>`
- npm global: `npm uninstall -g <pkg>`
- cargo: `cargo uninstall <pkg>` or `rm ~/.cargo/bin/<name>`
- AppImage: just `rm` the file, then check `~/.config/<app>` and `~/.local/share/<app>` for leftovers
- `/opt` or `/usr/local`: read the app's own uninstall docs; if it had a Makefile install, look for `make uninstall`

Always verify with `which <name>` and `whereis <name>` after removal — multi-manager installs (e.g. an app installed via both apt and Flatpak) can leave a stale binary on PATH.

### 3c. Large old files in `$HOME`

```bash
# Files over 100MB in home, sorted by size
find ~ -type f -size +100M -not -path "*/.*" 2>/dev/null | \
  xargs -I{} du -h {} 2>/dev/null | sort -h

# Files over 100MB not accessed in 6 months
find ~ -type f -size +100M -atime +180 2>/dev/null
```

Common culprits: old ISOs in `~/Downloads`, leftover Steam/game installs, VM disk images, archived backups, video files, training datasets, old project build artefacts.

Present the list. Do not delete unprompted — user content is sacred until they say otherwise.

### 3d. Project build artefacts

```bash
# Find node_modules directories (often huge)
find ~ -type d -name "node_modules" -prune 2>/dev/null

# Rust target directories
find ~ -type d -name "target" -prune 2>/dev/null

# Python venvs and __pycache__
find ~ -type d -name "__pycache__" 2>/dev/null
find ~ -type d -name ".venv" -o -name "venv" 2>/dev/null
```

These regenerate from `package.json` / `Cargo.toml` / `requirements.txt`. Often safe to remove from inactive projects, but ask the user which projects are inactive.

### 3e. Extra localisations (`localepurge`)

For single-locale users, all the non-English man pages and translation files add up:

```bash
sudo apt install localepurge
# Configuration prompts; select only the locales you want to keep (e.g. en_GB, en_US, C)
sudo localepurge
```

Typical reclaim: 200 MB – 800 MB. Only recommend if the user is genuinely single-locale; restoring a removed locale requires reinstalling the affected packages.

### 3f. AppImage and `/opt` installs no longer in use

AppImages are just files — `rm` is enough, plus checking `~/.config/<app>` and `~/.local/share/<app>` for stale settings.

`/opt` installs vary: many ship with an uninstall script in the install directory; others just need `sudo rm -rf /opt/<name>` plus any `.desktop` files in `/usr/share/applications/` and any `/etc/cron.*` entries the installer dropped.

---

## Recommended maintenance cadence (if user asks)

For a personal Mint machine, sensible rhythms are:

| Frequency | Action |
|-----------|--------|
| Weekly | `sudo apt autoremove && sudo apt clean`, `journalctl --vacuum-time=14d`, check Update Manager |
| Monthly | Review Timeshift snapshot list, `flatpak uninstall --unused`, browser cache review, `docker system prune` on dev boxes |
| Quarterly | Full audit (this skill), kernel pruning via Update Manager, developer cache review, large-file review in `$HOME`, `apt-xapian-index` rebuild |
| As needed | Tier 3 application uninstalls when the user notices they have not opened something in months |

Suggest cron / systemd-timer wiring only if the user explicitly asks. A scheduled job that silently deletes things removes the review opportunity that makes manual cleanup safe.
