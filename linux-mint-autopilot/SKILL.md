---
name: linux-mint-autopilot
description: >-
  Set up, automate, and maintain a personal Linux Mint machine so it looks after itself. Three modes: init 
  (configure a new install), full-auto (opt-in passwordless auth plus unattended updates), and cleanup (audit 
  and declutter an existing machine). Trigger on any request to set up, initialise, or automate a new or 
  freshly-installed Mint machine (e.g. "I just bought a laptop, set it up"); to tidy, declutter, audit, or 
  free up space even when "cleanup" is not used (e.g. "what's eating my disk", "minimise this laptop"); or to 
  stop Mint asking for a password repeatedly — sudo, the "Authentication is required" polkit dialog, screen 
  unlock, keyring (e.g. "only make me type my password at login"). Scoped to Linux Mint: Cinnamon, MATE, Xfce, 
  and LMDE.
metadata:
  scope: professional
---

# Linux Mint Autopilot

Sets up a personal Linux Mint machine, automates its upkeep, and audits it when cruft accumulates — always under user supervision. Tailored to Mint's specific tooling and conventions: Cinnamon/MATE/Xfce on Ubuntu LTS, plus LMDE on Debian Stable. The skill prioritises **minimalism**, **transparency**, and **reversibility** — every recommendation explains what it changes, why it is safe, and what it costs or reclaims.

## Operating principles

These principles apply throughout the workflow. Do not deviate from them.

1. **Audit before action.** Always begin with read-only discovery. Never run a destructive command before presenting findings and getting explicit approval.
2. **Recommend, do not assume.** Present each cleanup target as a discrete recommendation the user can accept, reject, or defer. Group related actions but never bundle a destructive command into something framed as "just an audit".
3. **Touch user-space, leave system-space alone.** The targets in `references/safe-targets.md` are the only categories you may propose. Anything in `references/protected-paths.md` is off-limits regardless of how much space it would free. This includes Mint-specific protected files like `/etc/apt/sources.list.d/official-package-repositories.list`.
4. **British English in user-facing prose.** Cleanup, optimise, behaviour, prioritise.
5. **Offer a Timeshift snapshot before tier-2 work.** Mint ships Timeshift for exactly this purpose. Before any kernel pruning, package autoremove, or large multi-step cleanup, offer to trigger a fresh snapshot so the user has a clean rollback point. They can decline.
6. **Quantify everything.** Every recommendation should be accompanied by either an actual measurement (du, df, `docker system df`, Timeshift's own size figure) or a clearly-labelled estimate. Do not promise space savings you cannot evidence.
7. **Recommend reversibly, execute thoroughly.** Always present and get approval before acting — that is where reversibility is protected. But *once the user has approved removing an app*, `apt purge` it rather than `apt remove`: removing the package while leaving its system configuration behind in the `rc` state just creates the residual-config cruft the audit flags later. A half-removed app is itself clutter. Empty trash last, after the user has confirmed nothing valuable is in it.
8. **Use mint-native tooling when it exists.** For kernel removal, prefer the Update Manager's kernel screen over manual `apt purge linux-image-*` — it understands which kernels are safe to remove and updates GRUB correctly. For app removal, `apt` is fine, but flag that `mintinstall` (Software Manager) can also do it with the same effect.
9. **No unattended automation of judgement calls — but recommend scheduled maintenance.** A one-shot "run this to clean everything now" script removes the user's review opportunity; build one only if the user explicitly asks after seeing the full audit. A *scheduled* maintenance timer is different: it is worth recommending in every report (see "Recommended: scheduled system maintenance"), because it stops tier-1 cruft from re-accumulating. But it may automate **only tier-1 and clearly-safe recurring actions** — journal vacuum, APT cache clean, expiry of long-dead trash, unused Flatpak runtimes, old-kernel pruning. Never put tier-3 judgement calls, app purges, Timeshift deletion, or Docker volume pruning on a timer.
10. **Full-auto mode is one opt-in gate, and the tier-1 timer is never inside it.** Passwordless auth and unattended package updates travel together as "full-auto mode" (see that section) because they answer the same wish — *stop interrupting me*. One yes/no turns the pair on. But the tier-1 `system-maintenance` timer stays **outside** the bundle: it only touches caches, logs, and trash, it is safe on every machine, and it belongs on a machine whether or not full-auto is wanted. Never fold it in, and never infer "yes to full-auto" from "yes to the maintenance timer".

11. **A bundle may not hide what it switched on.** Full-auto is one *decision*, not one *disclosure*. Before applying it, state both consequences plainly — root without a password prompt, and real package upgrades installing unattended — and name the update scope it will use, defaulting to Mint's own (everything non-blacklisted) rather than stopping to ask. Say it once, in a few lines, then do the work: do not repeat the warning, moralise, or make the user argue for it. Afterwards the report must list every change with its undo command. Never volunteer full-auto proactively — it must not appear in a Phase 4 cleanup report, and is only ever acted on when the user asks for it or accepts the single offer in init mode.

## Mint-specific quirks to keep in mind

Before you run anything, internalise these — they catch out generic Ubuntu cleanup advice when applied to Mint:

- **Software Manager defaults to Flatpak for many apps.** Users frequently install a 1 GB+ Flatpak version of a small utility without realising they could have installed a tiny `.deb` instead. When auditing installed apps, separate Flatpak entries clearly and call attention to large ones — these are often the single biggest reclamation opportunity on a Mint desktop.
- **Timeshift can silently consume 30-100+ GB.** Snapshots use hard links so deleting the *latest* one frees very little, but deleting older ones combined with reducing the retention count frees real space. Failed Timeshift snapshots sometimes disappear from the GUI but stay on disk under `/timeshift/snapshots/` — these need filesystem inspection, not just `timeshift --list`.
- **`apt-xapian-index` (used by Synaptic and Software Sources) caches 100-500 MB in `/var/cache/apt-xapian-index/`.** Safe to clear; rebuilds automatically. Optional to uninstall entirely if Synaptic searches a few seconds slower is an acceptable tradeoff.
- **Mint pins `/etc/apt/sources.list.d/official-package-repositories.list` and `/etc/apt/preferences.d/official-package-repositories.pref`.** These are managed by the `mintsources` package and required by `mintupdate`. Never edit or delete them; they will be overwritten on the next `mintsources` update anyway.
- **Removing "core Mint" packages breaks the system.** `mint-meta-core`, `mint-common`, `mint-info-*`, `mint-themes`, `mint-translations`, `mintupdate`, `mintinstall`, `mintsources`, `mintwelcome`, `mint-mirrors`, `cinnamon` (or `mate`/`xfce4` depending on edition) — leave these alone. Forum advice to "just remove mint-welcome" often cascades through dependencies and removes things the user actually needs.
- **The Update Manager handles old kernels.** Open Update Manager → View → Linux kernels. This is safer than manual `apt purge` and is the recommended Mint workflow.
- **LMDE differs.** Linux Mint Debian Edition has no snap support by default and uses Debian's APT repositories rather than Ubuntu's. Detect which edition is in use before recommending snap cleanup.

## Choosing a mode

Two entry points, plus one optional bundle that either can lead to. Decide before doing anything.

- **Cleanup mode** (default) — an existing machine that has accumulated cruft. Run the phases below in order.
- **Init mode** — a new or freshly-installed machine. Jump to "Init mode — new machine setup". Signals: "just bought a laptop", "fresh install", "set up a new machine", or an audit that comes back near-empty on a recent install.
- **Full-auto mode** — not an entry point. An optional opt-in bundle (passwordless auth + unattended updates) offered once during init mode, or applied when the user asks for it directly. Never reached by drifting there from a cleanup.

When in doubt, run Phase 1 first — the environment summary makes it obvious which applies. A machine with a few hundred MB of reclaimable cruft and no maintenance timer is an init-mode machine, whatever the user called it.

## Workflow

Cleanup mode. Run the phases in order. Do not skip the audit even if the user asks to "just clean it up".

### Phase 1 — Confirm the environment

Even though we know it is Mint, confirm:

- Edition and version: `cat /etc/linuxmint/info` (or `lsb_release -a` as fallback)
- Desktop environment: Cinnamon, MATE, or Xfce — the DE-specific meta-package must not be touched
- LMDE vs Ubuntu-based: `cat /etc/os-release` — LMDE shows Debian; standard Mint shows an Ubuntu LTS codename
- Kernel: `uname -r` (the **running kernel** — never propose removing this)
- Mint tools installed: `dpkg -l | grep -E "^ii\s+mint"` should list mintupdate, mintinstall, mintsources, mintwelcome, mint-meta-* etc.
- Timeshift installed and snapshot location: `timeshift --list` (needs sudo) and `df -h /` (snapshots usually live on root unless reconfigured)
- Snap presence: `which snap` (often present on standard Mint, absent on LMDE)
- Flatpak presence: `which flatpak` (present by default; Software Manager uses it)
- Container runtimes: `docker`, `podman`
- Existing maintenance automation: check whether a maintenance timer is already installed — `systemctl list-timers --all | grep -Ei 'maintenance|cleanup|purge-old-kernels'` and `ls /usr/local/sbin/system-maintenance /usr/local/sbin/purge-old-kernels 2>/dev/null`. If one exists, report its schedule and next run rather than recommending a new one.
- Existing automatic package updates: `mintupdate` ships this built in (present on every standard Mint install, no extra package needed) — it's just gated behind two flag files and timer enablement. Check `ls /var/lib/linuxmint/mintupdate-automatic-upgrades-enabled /var/lib/linuxmint/mintupdate-automatic-removals-enabled 2>/dev/null` and `systemctl is-enabled mintupdate-automation-upgrade.timer mintupdate-automation-autoremove.timer 2>/dev/null`. If already enabled, report its schedule (`systemctl list-timers | grep mintupdate-automation`) and current scope (`cat /etc/mintupdate-automatic-upgrades.conf 2>/dev/null` — empty/missing means unrestricted scope) rather than recommending it again. **A healthy-looking timer is not evidence it is working** — on a laptop, also check `grep -c "Power supply not connected" /var/log/mintupdate.log` against `apt list --upgradable | tail -n +2 | wc -l`, per "Common failure modes to avoid".

Report this back as a short environment summary so the user knows what surface area you are working with.

### Phase 2 — Run the audit

Use `scripts/audit.sh` (read-only, makes no changes) to gather a structured picture of where space is going. The audit covers:

- Overall disk and inode usage
- Top-level directory sizes under `/`, `/var`, `/home`
- Top 20 largest directories in `$HOME`
- **Timeshift snapshot inventory and total size**
- **APT repo signing-key health** — a missing/expired key on *any* configured repo (including third-party ones like Tailscale's) fails the whole `apt update`, which silently breaks `mintupdate`'s automatic-upgrade timer too. Surface this prominently if found; see "Common failure modes to avoid" for the fix pattern.
- APT cache size, autoremovable packages, residual configs
- **`apt-xapian-index` cache size**
- **Flatpak apps with per-app sizes (often the largest single targets on Mint)**
- Snap revisions and per-snap size (Ubuntu-based Mint only)
- Installed kernels (with current kernel flagged)
- Journal log size
- Developer cache sizes: `~/.cache`, `~/.npm`, `~/.cargo`, `~/.gradle`, etc.
- Docker disk usage (`docker system df` if present)
- Trash and thumbnail cache
- AppImage files in common locations
- Manually installed binaries in `/usr/local/bin` and `/opt`
- Large files (>100MB) in `$HOME` modified more than 6 months ago
- Manually-installed-vs-auto-installed `apt` package counts via `apt-mark`

If `ncdu` is installed, mention it as an option for the user to drill into specific directories interactively. Do **not** launch it automatically — it is interactive and will hang non-interactive sessions.

### Phase 3 — Categorise findings

Sort what the audit returned into the categories below. Discard anything that falls under `protected-paths.md`. For each remaining category, prepare a recommendation row with: **what**, **command**, **estimated reclaim**, **reversibility**, **risk note**.

The categories, in roughly the order to present them (low-risk first, higher-risk last):

| Tier | Category | Risk |
|------|----------|------|
| 1 | APT cache (`apt clean`) | Trivial — caches re-download on demand |
| 1 | `apt-xapian-index` cache | Trivial — rebuilds automatically |
| 1 | Journal logs older than N days | Low — logs only, no app data |
| 1 | Thumbnail cache, browser caches | Low — regenerated automatically |
| 1 | Trash | Low *once user has reviewed it* |
| 1 | Orphaned dependencies (`apt autoremove`) | Low — only removes packages nothing depends on |
| 1 | APT repo signing-key problems (detect only) | Low to detect — logging a warning is automatic; the fix (re-fetching a key) is always shown to the user first, never applied unattended |
| 2 | Excess Timeshift snapshots (keep 2-3) | Medium — review carefully; oldest snapshot often largest |
| 2 | Old kernels via Update Manager | Medium — wrong kernel removal = unbootable system |
| 2 | Unused flatpak runtimes, old snap revisions | Medium — usually safe but can break offline-edge cases |
| 2 | Developer caches (pip, npm, cargo, gradle, go) | Medium — caches rebuild but next build is slow |
| 2 | Docker images/containers/volumes/build cache | Medium — `--volumes` can destroy persistent data |
| 2 | Residual configs (`dpkg -l \| grep '^rc'`) | Medium — config gone for good |
| 3 | Large Flatpak apps replaceable with `.deb` | User judgement required |
| 3 | User-installed apps the user no longer uses | User judgement required |
| 3 | Large old files in `$HOME` (downloads, ISOs, old projects) | User judgement required |
| 3 | AppImages and `/opt` installs no longer in use | Medium — manual reinstall to restore |
| 3 | Extra localisation files via `localepurge` | Medium — only if user is single-locale |

See `references/safe-targets.md` for the full command reference for each.

### Phase 4 — Present the recommendation report

Output a single structured report. Do not interleave it with destructive commands. Format:

```
# Mint Cleanup recommendation report

## Environment
<edition, DE, kernel, total/used/free disk, Timeshift status>

## Findings summary
- Tier 1 (low risk): X items, ~Y MB reclaimable
- Tier 2 (medium risk): X items, ~Y GB reclaimable
- Tier 3 (judgement call): X items, ~Y GB reclaimable
- Total potential reclaim: ~Z GB

## Recommendations
<table or list, tier 1 first, with command + estimate + reversibility>

## Ongoing maintenance
Recommend a scheduled system-maintenance timer (see "Recommended: scheduled system
maintenance"). State whether one is already installed: if so, give its schedule and
next run; if not, recommend setting one up. Opt-in — needs approval to install.

## Pre-execution: Timeshift snapshot
Offer to trigger a fresh Timeshift snapshot before tier 2 work begins.

## Decision needed
Reply with the tiers/items you want me to proceed with, e.g. "tier 1 all, plus items 2a and 2c, skip the rest".
```

Stop after this. Wait for the user.

### Phase 5 — Execute approved actions

Once the user approves specific items:

1. **If the user wants any tier-2 actions, offer a Timeshift snapshot first**: `sudo timeshift --create --comments "pre-cleanup-$(date +%F)"`. They can decline; do not force it.
2. **Show the exact commands first**, then run them one tier at a time. For approved app removals, use `apt purge` (not `apt remove`) so configuration is cleared too — confirm first that the user is genuinely done with the app, not just freeing space temporarily. After purging, offer to remove any leftover user-level config directories (`~/.config/<app>`, and `~/.var/app/<id>` for Flatpak) so nothing is left behind.
3. For any command involving `rm -rf`, `purge`, `prune --volumes`, or kernel removal, repeat the target back to the user and confirm a second time before running.
4. Capture `df -h /` before and after each tier so the user sees the actual reclaim, not the estimate.
5. If a command fails, **stop**. Do not rampage on to the next tier — diagnose first.
6. Never chain destructive commands with `&&` in a single line unless the user has explicitly asked for a script. Run them as separate steps so partial progress is visible.

### Phase 6 — Verify and report

After execution:

- Final `df -h /` and `df -i /` (inodes can be the actual constraint).
- For each tier executed, the actual reclaim vs estimated reclaim.
- A short note on what was deliberately **not** done, so the user has a record.
- If a Timeshift snapshot was taken at Phase 5, remind the user it exists and can be deleted later if everything is working.
- Recommend the scheduled system-maintenance timer if one is not already installed — see "Recommended: scheduled system maintenance". Present the install commands and let the user approve them; never install it silently.

## Optional: full-auto mode

The machine stops asking permission. One opt-in, two components:

| Component | Effect | Detail |
|---|---|---|
| Passwordless auth | No password for `sudo` or the "Authentication is required" dialog | "Full-auto component: reduce password prompts to login only" |
| Unattended updates | Real package upgrades install on a timer with no review | "Full-auto component: automatic package updates" |

**Not in the bundle:** the tier-1 `system-maintenance` timer (operating principle 10). It is safe, reversible, and belongs on every machine — offer it separately and never let it ride in on a full-auto yes.

### Preconditions — check both before offering

Full-auto on a machine that fails either of these produces something worse than doing nothing, because it *looks* automated while being broken or unrecoverable:

1. **`apt update` must be clean.** A broken repo signing key silently fails every unattended upgrade forever, with no visible error (see "Common failure modes to avoid"). Fix it first.
2. **Timeshift must be configured with at least one snapshot.** Unattended upgrades with no rollback point is a materially different risk from unattended upgrades with one. If Timeshift is absent, set it up first, or say plainly that full-auto is being enabled without a safety net.

### Making the offer

Once, in a few lines — then act on the answer. Per operating principle 11, the bundle is one decision but not one disclosure:

> Full-auto mode does two things. **One:** your password is needed only at login — anything running as you can become root with no prompt, so a bad script or download no longer hits a password wall. **Two:** package updates install by themselves on a timer, including kernel-adjacent packages, with no per-run review. I'll use Mint's default scope (everything except anything blacklisted); say the word if you'd rather have security-only. Both are one-command reversible. Enable it?

Do not ask a second question about scope — name the default and move on. If the user wants security-only or a blacklist, they will say so; the alternatives are in the component section.

### Applying it

Order matters — do passwordless first, so the update work that follows does not sit behind prompts:

1. Work through "Full-auto component: reduce password prompts to login only" (sudo, polkit, screen lock, keyring).
2. Work through "Full-auto component: automatic package updates" at the agreed scope.
3. Verify both for real: `timeout 10 pkexec --disable-internal-agent /bin/true` returns cleanly, and `systemctl list-timers | grep mintupdate-automation` shows a next run.
4. Report every change with its undo, and state when the update timer next fires. A machine that upgrades itself at 3am should not be a surprise in a month.

### Undo — keep this together

Full-auto is the most reversible-on-paper and least-remembered thing the skill does. Always hand back the complete block:

```bash
# Passwordless auth
sudo rm /etc/sudoers.d/99-nopasswd-$USER
sudo rm /etc/polkit-1/rules.d/49-nopasswd-sudo-group.rules
sudo systemctl restart polkit
gsettings set org.cinnamon.desktop.screensaver lock-enabled true
gsettings set org.cinnamon.settings-daemon.plugins.power lock-on-suspend true

# Unattended updates
sudo rm /var/lib/linuxmint/mintupdate-automatic-upgrades-enabled
sudo rm /var/lib/linuxmint/mintupdate-automatic-removals-enabled
sudo systemctl disable --now mintupdate-automation-upgrade.timer
sudo systemctl disable --now mintupdate-automation-autoremove.timer
```

## Recommended: scheduled system maintenance

A fortnightly timer that clears caches, logs, and trash. Safe on every machine and **never** part of the full-auto bundle — offer it independently. Script and install steps: `references/maintenance-timer.md`.

## Full-auto components — install procedures

Both components (unattended package updates, and reducing password prompts to login only) are documented in `references/full-auto.md`. Read it only once the user has accepted full-auto mode.

## Init mode — new machine setup

Takes a fresh Mint install and applies the skill's full recommended baseline in one pass, so the machine starts out maintained rather than being rescued later. This is the setup half of the skill; cleanup mode is the rescue half.

**Scope — what init mode does and does not do.** It configures *this skill's* recommendations: repo-key health, a first full upgrade, Timeshift, the maintenance timer, automatic package updates, and (opt-in) password-prompt reduction. It does **not** install applications, restore dotfiles, configure git or SSH, or clone another machine's package set. If the user wants those, that is a different job — say so rather than improvising it here.

**Idempotent by design.** Every step checks for existing state before acting and reports "already configured" rather than redoing it. Re-running init mode on a half-set-up machine is safe and is the intended way to finish an interrupted run.

### Ordering constraints — do not resequence

The order below is load-bearing:

1. **Repo signing keys and the first full upgrade come first.** Everything downstream depends on a working `apt update`. If a third-party repo has a broken key, automatic upgrades will fail silently forever and the machine looks configured while being stale — the exact failure documented in "Common failure modes to avoid". Fix it here or nothing else is trustworthy.
2. **Timeshift is configured and takes its first snapshot before any system-changing step.** A fresh install is the single best rollback point the machine will ever have. Capture it.
3. **The maintenance timer goes in before full-auto is offered**, so its repo-key health check is already running when unattended upgrades start depending on `apt update`. It is also why the timer must be offered on its own first — bundling it would make declining full-auto silently cost the user their tier-1 housekeeping (principle 10).
4. **The baseline audit runs last, not first.** A fresh box has nothing to clean; the audit's value here is as a "this is what clean looks like" record for future comparison, not a cleanup input.

### Steps

**Step 1 — Environment.** Run Phase 1 in full. Confirm edition, DE, LMDE-vs-Ubuntu base, running kernel, and which of Timeshift / snap / flatpak / docker are present. Report the summary before doing anything.

**Step 2 — Repo keys and first upgrade.**
```bash
sudo apt update            # read the output; do not skip past it
sudo apt full-upgrade
```
Inspect the `apt update` output for `NO_PUBKEY`, `EXPKEYSIG`, or GPG errors. If any repo is broken, fix it now using the pattern in "Common failure modes to avoid" — show the user the repo and the exact key command first, since importing a signing key is a trust decision. Do not continue until `apt update` is clean. A reboot is warranted here if the upgrade pulled a new kernel.

**Step 3 — Timeshift.** Check whether it is configured (`sudo timeshift --list`). If not, set it up: choose a snapshot location (a separate disk or partition is better than root, but root is acceptable on a single-disk laptop), set a schedule, and set the retention count to 2–3 to prevent the 30–100 GB creep documented in "Mint-specific quirks". Then take the baseline snapshot:
```bash
sudo timeshift --create --comments "fresh-install-baseline-$(date +%F)"
```

**Step 4 — Maintenance timer.** Install with the helper rather than by hand:
```bash
cd <skill>/scripts
sudo ./install-maintenance-timer.sh                       # fortnightly, 1st + 15th
sudo ./install-maintenance-timer.sh 'Sun *-*-* 03:00:00'  # or a custom schedule
```
It installs both scripts and the systemd units, enables the timer, and prints the next run. It is idempotent and warns if a stale cron entry would double-run the job. Then prove it works before trusting it:
```bash
sudo systemctl start system-maintenance.service
journalctl -t system-maintenance -n 50
```

**Step 5 — Offer full-auto mode.** This is the one place in the skill where full-auto is offered rather than waited for, and it is still a single yes/no — do not apply it silently because the user asked for a "full setup". Both preconditions are already satisfied by steps 2 and 3, so make the offer exactly as scripted in "Optional: full-auto mode", using the default update scope. If they accept, apply both components; if they decline or don't answer, skip it and record that in the report. Never ask twice, and never split it back into two questions.

**Step 6 — Baseline audit.** Run `scripts/audit.sh` and keep the output as the machine's clean-state reference. On a fresh install expect it to be near-empty; that is the point. Flag anything unexpectedly large, since on a new machine that usually means a misconfiguration rather than accumulated cruft.

**Step 7 — Verify and report.** Use the template below.

### Init mode report

```
# Mint init report

## Environment
<edition, DE, kernel, disk total/free>

## Configured
| Item | Status | Detail |
|------|--------|--------|
| Repo signing keys | OK / fixed | <which repo, if fixed> |
| First full upgrade | done | <packages upgraded, reboot needed?> |
| Timeshift | configured | <location, schedule, retention, baseline snapshot name> |
| Maintenance timer | enabled | <schedule, next run, test-run result> |
| Full-auto mode | enabled / declined | <if enabled: both components, update scope, next update run> |

## Baseline audit
<summary — expected to be near-empty on a fresh install>

## Deliberately not done
Applications, dotfiles, git/SSH config, and package-set cloning are out of scope
for init mode.

## Undo
<one line per change, so every step is reversible>
```

Close by telling the user which automation is now running unattended and when it next fires. A machine that quietly maintains itself should not be a surprise later.

## Reference files

- `references/protected-paths.md` — Paths, packages, and Mint-specific files that must never be proposed for deletion. Consult before suggesting anything outside the standard safe targets.
- `references/safe-targets.md` — The full menu of cleanup actions with Mint-specific commands, expected reclaim ranges, and rationale.
- `scripts/audit.sh` — Read-only audit script tuned for Mint. Always run this in Phase 2.
- `scripts/system-maintenance.sh` — Fortnightly housekeeping script (journal, APT cache, old trash, Flatpak runtimes, kernels) for the scheduled-maintenance timer; see "Recommended: scheduled system maintenance".
- `scripts/purge-old-kernels.sh` — Kernel auto-prune script; called by `system-maintenance.sh`, or installed standalone.
- `scripts/install-maintenance-timer.sh` — Idempotent installer for the two scripts above plus the systemd service and timer. Needs root. Takes an optional `OnCalendar` expression as its first argument. Used by both the scheduled-maintenance recommendation and init mode step 5.

## Common failure modes to avoid

- **Removing the running kernel.** Always cross-check `uname -r` before any kernel removal. Prefer Update Manager → Linux kernels over manual `apt purge`.
- **Editing `/etc/apt/sources.list.d/official-package-repositories.list` or `/etc/apt/preferences.d/official-package-repositories.pref`.** These are mintsources-managed; manual edits will be overwritten and may break `mintupdate`'s policy check in the meantime.
- **Removing core Mint packages.** `mint-meta-*`, `mintupdate`, `mintinstall`, `mintsources`, the DE meta-package — leaving these alone is non-negotiable.
- **`docker system prune --volumes` on a dev box with named volumes holding databases.** Volumes can contain irreplaceable local state. Default to `docker system prune` without `--volumes` and only add it after explicit confirmation that no named volumes hold data the user needs.
- **Purging an app the user actually intends to reinstall.** Purge is the correct, default action for an approved removal — it clears configuration so nothing is left behind. The only trap is purging an app the user is merely clearing out *temporarily*; confirm they are genuinely finished with it before purging, since the system-level config will be gone.
- **Cleaning `~/.config` or `~/.local/share` wholesale.** These hold real application data. Only target *known* cache sub-paths inside them.
- **Deleting Timeshift snapshots via `rm -rf /timeshift/snapshots/`.** Use `timeshift --delete --snapshots '<name>'` so Timeshift's database stays consistent.
- **Removing a Flatpak app and forgetting `~/.var/app/<id>`** if the user wants the data gone too. `flatpak uninstall --delete-data <id>` handles both.
- **On a laptop that lives on battery, automatic upgrades abort every time and report success.** `mintupdate`'s automation checks `/sys/class/power_supply/AC/online` and bails immediately if the machine is unplugged — deliberate, since a laptop dying mid-upgrade is how you get a broken system. But the *timer* still records a successful run, `systemctl list-timers` looks healthy, and nothing warns the user. On a laptop that is rarely plugged in, updates can go months without installing while every surface says the automation is working. Diagnose by counting the bail-outs rather than trusting the timer:
  ```bash
  grep -c "Power supply not connected" /var/log/mintupdate.log   # times it aborted
  tail -5 /var/log/mintupdate.log                                # what it last actually did
  apt list --upgradable 2>/dev/null | tail -n +2 | wc -l         # what is waiting
  ```
  Interpret the two numbers **together** — a high bail count with nothing upgradable is harmless (it aborted on runs with no work to do); a high bail count with a real backlog is the failure. The fix is behavioural, not technical: tell the user to plug in occasionally, and give them the `grep` above so they can check. Do **not** patch out the AC check — it lives in `mintupdate`'s `automatic_upgrades.py` and any edit is overwritten by the next `mintupdate` release, leaving a laptop that upgrades itself flat on battery.
- **A broken signing key on one repo silently kills `apt update` for every repo, which silently kills `mintupdate`'s automatic-upgrade timer.** If a third-party repo (Tailscale, Docker, a PPA, etc.) has a missing or expired key, `apt update` errors out entirely rather than just skipping that repo — and `mintupdate-automation-upgrade.service` calls `mint-refresh-cache` before it installs anything, so it fails too, every time it fires, with no visible error to the user. Symptom: the user reports "I keep having to open Update Manager and enter my password" even though automatic updates are correctly configured — the automation isn't broken, its prerequisite (`apt update`) is. Diagnose with `sudo apt update` and look for `NO_PUBKEY <keyid>` or a GPG error naming the repo. Fix by re-fetching that repo's key to the exact path its `/etc/apt/sources.list.d/*.list` entry already references (check the `signed-by=` path in the file), using the correct distro codename (`lsb_release -cs` gives the Ubuntu base codename, e.g. `noble` — LMDE/Mint's own codename like `zena` is a different thing and not what the key URL wants). Example pattern:
  ```bash
  curl -fsSL https://pkgs.example.com/<dist>/<codename>.noarmor.gpg | sudo tee /usr/share/keyrings/<name>-archive-keyring.gpg >/dev/null
  sudo apt update   # confirm the error is gone before relying on it
  ```
  Never auto-fetch a replacement key unattended — show the user the broken repo and the exact command first, since importing a signing key is a trust decision.

## When the user just wants the report

If the user asks for an audit only — "tell me what's eating my Mint laptop" — stop after Phase 4. Do not push them toward execution. They set their own pace.
