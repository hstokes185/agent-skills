# Protected paths and packages — never propose for deletion

These targets are off-limits regardless of how much space they would free, how confident the user is, or what the user explicitly asks for. If the user asks to delete something on this list, refuse, explain why, and offer an alternative.

## Filesystem locations — never touch

| Path | Why |
|------|-----|
| `/` | Root. Touching this with recursion has bricked systems since 1971. |
| `/bin`, `/sbin`, `/lib`, `/lib32`, `/lib64`, `/libx32` | Core system binaries and shared libraries. On modern Mint these are symlinks into `/usr` and equally untouchable. |
| `/boot` | Bootloader, kernel images, initramfs. Old kernels can be pruned via Update Manager or `apt`; never delete files in `/boot` directly. |
| `/dev` | Device nodes. Kernel-managed virtual filesystem. |
| `/etc` | System and application configuration. Even "obviously stale" files here often turn out to matter. |
| `/proc`, `/sys` | Kernel virtual filesystems. Not on disk; deletion attempts will either fail or do something unpredictable. |
| `/run` | Runtime tmpfs. Managed by systemd-tmpfiles. |
| `/usr` (except `/usr/local`) | OS-managed binaries, libraries, shared data. Managed by APT, never edit by hand. `/usr/local` is the local-admin domain and is fair game. |
| `/var/lib` (except documented sub-paths) | Persistent application state — databases, package manager state, container state, etc. Specific safe sub-paths are listed in `safe-targets.md`. The directory as a whole is not safe. |
| `/var/log` (live logs, current journals) | Active logs. Use `journalctl --vacuum-*` and `logrotate` instead of rm. Old rotated `*.gz` files older than ~30 days are negotiable but should still be reviewed first. |
| `/srv`, `/mnt`, `/media` | Server data, mounts. User content possibly lives here — never blanket-clean. |
| `/root` | Root user home. Treat like a user home but require extra confirmation. |
| `/snap` | Snap mount points. Managed by snapd, not by file deletion. Use `snap remove` instead. |
| `/var/lib/flatpak`, `~/.local/share/flatpak` | Flatpak storage. Managed by `flatpak uninstall --unused`, not by file deletion. |
| `/var/lib/docker`, `/var/lib/containers` | Container runtime state. Use `docker system prune` / `podman system prune`, never `rm -rf`. |
| `/timeshift` and `/run/timeshift` | Timeshift's snapshot store. Manage snapshots only through `timeshift --delete`, never raw `rm`. |

## Mint-specific protected files

These files are managed by Mint's own tooling. Edits will be overwritten on the next package update and may break `mintupdate`, `mintinstall`, or `mintsources` in the meantime.

| Path | Why |
|------|-----|
| `/etc/apt/sources.list.d/official-package-repositories.list` | Managed by `mintsources`. Required by `mintupdate` to verify policy. Edit via Software Sources GUI, not by hand. |
| `/etc/apt/preferences.d/official-package-repositories.pref` | The package-pinning rules `mintupdate` checks at startup. Missing or modified versions cause `mintupdate` to refuse to run. |
| `/usr/share/linuxmint/`, `/usr/share/mint*/` | Mint-shipped assets — themes, mint-y icons, welcome screen content. Touched by the package manager, not by hand. |
| `/etc/linuxmint/info` | Edition metadata file. Read by `mintupdate` and scripts. |

## Kernel safety

- The **running kernel** (`uname -r`) must never be removed, full stop.
- Always leave **at least one fallback kernel** installed besides the running one. If `apt autoremove` would leave only the running kernel, accept that — having a fallback is more valuable than the ~400 MB saved.
- Never delete files in `/boot` directly. Use Update Manager → Linux kernels (preferred), or `apt purge linux-image-X` as a fallback, so initramfs and GRUB are updated atomically.
- The `linux-generic` / `linux-image-generic` / `linux-headers-generic` meta-packages must remain installed. Removing the meta-package can cause `apt autoremove` to nuke the kernel on a future run.

## Packages — never propose removing

**Core Mint packages** (removing these breaks the desktop, the package management, or both):

- `mint-meta-core`, `mint-meta-cinnamon` / `mint-meta-mate` / `mint-meta-xfce` (whichever edition is installed)
- `mint-common`, `mint-info-*`, `mint-mirrors`, `mint-translations`, `mint-themes`, `mint-l10n`, `mint-x-icons`, `mint-y-icons`
- `mintupdate`, `mintinstall`, `mintsources`, `mintwelcome`, `mintdrivers`, `mintbackup`, `mintstick`, `mintreport`, `mintnanny`, `mintwizard`
- `cinnamon`, `cinnamon-control-center`, `cinnamon-session`, `nemo` (on Cinnamon edition)
- `mate-desktop`, `caja`, `marco`, `mate-session-manager` (on MATE edition)
- `xfce4`, `thunar`, `xfwm4`, `xfce4-session` (on Xfce edition)
- `lightdm`, `lightdm-gtk-greeter`, `lightdm-settings` — display manager
- `network-manager`, `network-manager-gnome` / `nm-applet`
- `pulseaudio` / `pipewire`, `policykit-1`, `gvfs`

**Debian/Ubuntu base** that you would never remove on any Debian-family system:

- Anything tagged "Essential: yes" in dpkg.
- `apt`, `dpkg`, `apt-utils`, `aptitude`, `software-properties-common`.
- `systemd`, `sysvinit-utils`, `init-system-helpers`.
- `sudo`, `openssh-server` (if present — be very cautious on remote machines).
- The kernel meta-packages noted above.

**General rule**: if you cannot explain why a package is safe to remove and what it does, do not propose removing it. Forum advice along the lines of "you can totally uninstall X" is frequently wrong on Mint specifically — what works on bare Ubuntu often breaks Mint because of mint-meta dependencies.

## User-home paths — handle with extreme care

These live under `$HOME` but are not "cache" or "junk" despite sometimes looking like it. Do not propose blanket deletion:

- `~/.ssh` — SSH keys and config. Never.
- `~/.gnupg` — GPG keys.
- `~/.config/<app>` — Application configuration. Specific cache sub-folders inside may be cleanable but the parent is not.
- `~/.local/share/<app>` — Application data. Often contains the actual user data (email, notes, chat history, app databases). Same rule as `.config`.
- `~/.cinnamon`, `~/.config/cinnamon-session`, `~/.config/dconf` — Cinnamon settings, panel layout, applets, keyboard shortcuts. Deleting these resets the desktop to defaults and is usually not what the user wants.
- `~/.mozilla`, `~/.thunderbird` — Profile data including bookmarks, passwords, mail. Only the `Cache*` sub-directories are safe.
- `~/.var/app/<id>` — Per-Flatpak user data. Tied to a specific Flatpak; remove via `flatpak uninstall --delete-data <id>`, not manually.
- `~/Documents`, `~/Pictures`, `~/Videos`, `~/Music` — User content. Out of scope for cleanup automation. The user may identify specific large old files for manual removal, but the skill never proposes deletion here unprompted.
- Dotfile directories the user has under version control (often signalled by a `.git` inside). Treat as source code, not waste.
- `~/.password-store`, `~/.aws`, `~/.kube`, `~/.docker/config.json` — credentials and cluster configs.

## The "I know better" override

The user may insist on touching something on this list. When that happens:

1. State clearly that this path/package is on the protected list and **why**.
2. Ask them to confirm they understand the specific risk (e.g. "removing `mint-meta-core` will pull half the desktop with it on the next autoremove").
3. If they still want to proceed, suggest a safer alternative first (e.g. for an unwanted Mint app: hide it from the menu via Menu editor rather than uninstalling the package; for a large Flatpak: uninstall *just that Flatpak* rather than removing the Flatpak infrastructure).
4. Only proceed if no safer alternative exists and they have confirmed the risk. Take a Timeshift snapshot first.

Some cleanup is best left undone.
