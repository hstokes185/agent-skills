# Scheduled system maintenance — script and install steps

The tier-1 maintenance timer is safe on every machine and sits outside full-auto mode. Offer it during init and cleanup alike.

## Recommended: scheduled system maintenance

Recommend this in every Phase 4 report. Tier-1 cruft — journal logs, the APT cache, dead trash, unused Flatpak runtimes, old kernels — re-accumulates no matter how thorough a one-off cleanup is. A small fortnightly `systemd` timer keeps it in check without ever touching anything that needs the user's judgement. It is opt-in: present the steps, get approval, never install it silently.

This does **not** contradict principle 9. The forbidden thing is a "clean everything now" script that skips review. A scheduled timer that runs *only* the safe, regenerating tier-1 actions below is the opposite — predictable, bounded, and reviewed once at setup.

**First, check whether one already exists** (Phase 1 covers this). If a maintenance timer is installed, report its schedule and next run instead of recommending a new one.

### What the script does

`scripts/system-maintenance.sh` performs six safe, recurring actions, logging each to the journal under the `system-maintenance` tag:

1. Check APT repo signing keys are healthy (`apt-get update`, grep for `NO_PUBKEY`/GPG errors) — **detect and log only**, never fetches or trusts a key unattended. Catches the class of bug where a single broken repo (e.g. a third-party one like Tailscale's) silently fails the whole `apt update` and, with it, every future automatic-upgrade run — see "Common failure modes to avoid".
2. Trim the systemd journal to the last 14 days.
3. Clear the APT package cache (`apt-get clean`).
4. Delete trash items that have sat in the bin for 30+ days (all user accounts).
5. Remove unused Flatpak runtimes.
6. Prune old kernels — keep the 2 newest plus the running one — by calling `purge-old-kernels`.

Every step is tier-1 or clearly-safe: caches re-download, logs are not app data, the 30-day trash window means nothing recently deleted is touched, the key check only logs, and the kernel prune never removes the running kernel. The script contains **no** app purges, no tier-3 removals, no Timeshift or Docker-volume deletion, and never fetches or trusts a signing key on its own — and must stay that way.

### Install steps

Prefer a **systemd timer over a plain cron job**: a fixed-time cron entry is skipped entirely if the machine is off at that moment, whereas a timer with `Persistent=true` catches up shortly after the next boot.

Use `scripts/install-maintenance-timer.sh` rather than doing this by hand — it places both scripts root-owned and executable, writes the `.service` and `.timer` units, enables the timer, and prints the next run. It is idempotent, so re-running it after editing a script just re-installs the current version. Show the user the command and let them approve it:

```bash
cd <skill>/scripts
sudo ./install-maintenance-timer.sh                       # fortnightly, 1st + 15th
sudo ./install-maintenance-timer.sh 'Sun *-*-* 03:00:00'  # custom OnCalendar
```

Then confirm it behaves before the first scheduled fire:

```bash
sudo systemctl start system-maintenance.service
journalctl -t system-maintenance -n 50
systemctl list-timers system-maintenance.timer
```

The units it writes set `Persistent=true` (catch up after a missed run) and `RandomizedDelaySec=15m`. If you ever need to do it manually, those two settings plus `Type=oneshot` and `WantedBy=timers.target` are the parts that matter.

Safety notes to convey: the timer only ever runs the five actions above; the kernel prune is idempotent and a no-op when there is nothing to remove; and the script is safe to run by hand at any time. Do **not** also place either script in `/etc/cron.weekly/` — registering a timer *and* a cron entry double-runs it.

### Kernel pruning on its own

If the user wants only old kernels trimmed automatically and not the rest, install `purge-old-kernels.sh` alone with its own `service`/`.timer` pair named `purge-old-kernels` (same steps, swapping the script and unit names). It keeps the `KEEP` newest kernels (default 2) plus the running one and is a no-op when fewer exist.
