# Full-auto mode — install procedures

Both components are opt-in and travel together. Read this only after the user has accepted full-auto mode; the decision framing lives in SKILL.md.

## Full-auto component: automatic package updates

One of the two components of full-auto mode — do not enable it outside that gate, and never as a rider on the tier-1 timer (operating principle 10). It uses Mint's own built-in mechanism (ships inside the `mintupdate` package, already on every standard Mint install — nothing extra to install), not `unattended-upgrades` or any other generic Debian/Ubuntu tooling, per principle 8.

**First, check whether it's already enabled** (Phase 1 covers this). If it is, report its schedule and current scope rather than reconfiguring it.

### What it does

Two systemd timers, both shipped with `mintupdate` but disabled by default:

- `mintupdate-automation-upgrade.timer` — fires ~60 minutes after every boot, plus daily, running `mintupdate-cli upgrade --refresh-cache --yes` as root. Wraps the run in `systemd-inhibit --what=shutdown` so it can't be interrupted mid-upgrade, and skips the run entirely if the machine is on battery (checks `/sys/class/power_supply/AC/online`).
- `mintupdate-automation-autoremove.timer` — weekly `apt autoremove`, keeping the system tidy of orphaned dependencies.

Both are gated behind empty flag files that just need to exist: `/var/lib/linuxmint/mintupdate-automatic-upgrades-enabled` and `/var/lib/linuxmint/mintupdate-automatic-removals-enabled`.

### Why this is a bigger decision than the tier-1 timer

The tier-1 `system-maintenance` timer only ever touches caches, logs, and trash — everything it does is reversible and regenerating. This is different: **it installs real package upgrades with no per-run review**, on whatever scope is configured. Unscoped, that includes kernel-adjacent packages (`linux-libc-dev`, `linux-tools-common`, kernel metapackages) — not full kernel image swaps, but real system-level updates going in unattended. Present this plainly; do not undersell it as "just like the cleanup timer."

### Scope — name the default, don't ask

`mintupdate-cli upgrade` supports narrowing what an automatic run touches. State which scope you are using as part of the single full-auto offer (principle 11) and proceed; only switch if the user asks. **Default to the first option** — it is Mint's own behaviour and matches what "auto update" means to most people:

- **Everything non-blacklisted** *(default)* — what Mint does if you just flip the flag files with no config. Simplest, but includes kernel/driver-adjacent packages.
- **Security updates only** — add `-s`/`--only-security` via `/etc/mintupdate-automatic-upgrades.conf` (one CLI arg per line, read by `automatic_upgrades.py`). Safer, smaller blast radius, but non-security fixes (e.g. app updates) pile up for manual review.
- **Everything except a blacklist** — list specific source packages (one per line) in `/etc/mintupdate.blacklist` to always exclude (e.g. `linux`, `nvidia-driver-*` if the user wants to review driver/kernel updates by hand while automating the rest).

Whichever is chosen, tell the user plainly that this is Mint's own real automatic-upgrade mechanism, not a limited/simulated one — packages actually install with no prompt.

### Install steps

```bash
# Enable the upgrade timer (always)
sudo touch /var/lib/linuxmint/mintupdate-automatic-upgrades-enabled
sudo systemctl enable --now mintupdate-automation-upgrade.timer

# Enable the autoremove companion (recommended, ask first)
sudo touch /var/lib/linuxmint/mintupdate-automatic-removals-enabled
sudo systemctl enable --now mintupdate-automation-autoremove.timer

# Optional: scope to security-only instead of everything
echo "--only-security" | sudo tee /etc/mintupdate-automatic-upgrades.conf

# Optional: exclude specific source packages from ALL automatic runs
# (one source package name per line)
sudo nano /etc/mintupdate.blacklist
```

Verify with `systemctl list-timers | grep mintupdate-automation` and, after the next scheduled run, `journalctl -t mintupdate -n 50` or check `/var/log/mintupdate.log` for what it actually did.

### Pair it with the repo signing-key check

A single broken repo key (see "Common failure modes to avoid") silently fails the `apt update` this depends on, **every time**, with no visible error — the symptom is exactly "I keep having to manually open Update Manager and enter my password" despite automation being correctly configured. The tier-1 `system-maintenance` timer's step 1 now checks for this and logs a warning; make sure that timer is installed (or at least mention the check) whenever you set up automatic package updates, so a future silent failure gets caught.

### Safety notes to convey

- It skips runs while on battery, so it won't drain a laptop mid-upgrade. Say this as a **trade-off, not a pure benefit** — on a laptop that mostly lives unplugged it is also the most likely reason automatic updates silently never happen (see "Common failure modes to avoid").
- It blocks shutdown while running (`systemd-inhibit`), so it can't be interrupted halfway.
- It never asks for a password interactively — it runs as a root systemd service, not through the GUI/polkit.
- Recommend the user also has Timeshift snapshots scheduled (check in Phase 1) as a rollback safety net, since unattended upgrades with no snapshot safety net is a bigger risk than unattended upgrades with one.
- This is opt-in and reversible: `sudo rm /var/lib/linuxmint/mintupdate-automatic-upgrades-enabled` (and/or `systemctl disable --now mintupdate-automation-upgrade.timer`) turns it back off at any time.

## Full-auto component: reduce password prompts to login only

The password is required **only** at the login screen — never again for `sudo`, never for the grey "Authentication is required" dialog, never on unlock.

One of the two components of full-auto mode. It can also be requested on its own ("stop asking for my password"), in which case do just this section and do not upsell the update half.

**This is the part of the skill that weakens security rather than tidying.** Treat it accordingly:

- **Never recommend it proactively.** It does not belong in the Phase 4 report.
- **State the trade-off once, plainly, then do the work.** The honest version: any process running as the user can become root with no prompt, so a malicious script or a bad download no longer hits a password wall. A sentence or two — do not moralise, and do not re-litigate it once the user has asked.
- **Always give the undo command** alongside each change.

### Diagnose before changing anything

There are **four independent layers**, and users conflate them. Check all four first and report which are already handled — frequently `sudo` and the screen lock are already done and only polkit is actually prompting.

| Layer | What it gates | Check |
|---|---|---|
| **sudo** | `sudo` in a terminal | `sudo -l` — look for `NOPASSWD: ALL`. Note `sudo -n true` alone is unreliable: it succeeds off a cached timestamp. Run `sudo -K` first to clear the cache, then re-test. |
| **polkit** | GUI "Authentication is required" dialogs — Update Manager, Software Manager, Timeshift, Disks, GParted, mounting internal drives, Users and Groups | `pkaction --version`; `sudo ls /etc/polkit-1/rules.d/` (needs sudo — the dir is `root:polkitd 750`) |
| **Screen lock** | Unlocking after idle or suspend | `gsettings get org.cinnamon.desktop.screensaver lock-enabled` and `gsettings get org.cinnamon.settings-daemon.plugins.power lock-on-suspend` (MATE/Xfce use different schemas) |
| **Keyring** | gnome-keyring unlock prompts for saved Wi-Fi and app passwords | See "Keyring" below |

### sudo

If `sudo -l` does not already show `NOPASSWD: ALL`, add a drop-in — **never hand-edit `/etc/sudoers`**, a syntax error there locks the user out of root entirely:

```bash
echo "$USER ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/99-nopasswd-$USER
sudo chmod 440 /etc/sudoers.d/99-nopasswd-$USER
sudo visudo -c        # MUST pass before you walk away
```

Validating with `visudo -c` is not optional. Undo: `sudo rm /etc/sudoers.d/99-nopasswd-$USER`.

### polkit — the one people miss

This is almost always the remaining gap once `sudo` is done. Mint 22.x ships **polkit 124**, which reads JavaScript rules from `/etc/polkit-1/rules.d/`. (`/etc/polkit-1/localauthority/` with `.pkla` files is the *old* pre-0.106 mechanism — it may not exist, and writing `.pkla` files on polkit 124 silently does nothing. Use `.rules`.)

```javascript
// /etc/polkit-1/rules.d/49-nopasswd-sudo-group.rules
polkit.addRule(function(action, subject) {
    if (subject.isInGroup("sudo") && subject.local && subject.active) {
        return polkit.Result.YES;
    }
});
```

Details that matter:

- **Filename must sort before `50-default.rules`** — rules are evaluated in lexical order and the first to return wins. Use a `49-` prefix or lower.
- **Keep `subject.local && subject.active`.** This limits the bypass to a physically-present, active session, so an SSH session still has to authenticate. Dropping it hands passwordless root to every remote session — only do so if the user asks for it specifically.
- Install as `root:root` mode `644`: `sudo install -o root -g root -m 644 <file> /etc/polkit-1/rules.d/49-nopasswd-sudo-group.rules`
- `sudo systemctl restart polkit`, then **check the journal**: `sudo journalctl -u polkit -n 15 --no-pager`. A JS syntax error shows up here as a compile failure, and the rule is silently skipped — a clean run logs `Finished loading, compiling and executing N rules`.
- **Verify for real**: `timeout 10 pkexec --disable-internal-agent /bin/true`. `--disable-internal-agent` prevents it hanging on a terminal password prompt in a non-interactive session; wrap in `timeout` regardless.

Undo: `sudo rm /etc/polkit-1/rules.d/49-nopasswd-sudo-group.rules && sudo systemctl restart polkit`

### Screen lock

```bash
gsettings set org.cinnamon.desktop.screensaver lock-enabled false
gsettings set org.cinnamon.settings-daemon.plugins.power lock-on-suspend false
```

No sudo needed — these are per-user. Suspend/resume is the common complaint, and `lock-on-suspend` is a separate key from `lock-enabled`; set both.

### Keyring

Usually **already fine** — check before touching it. PAM (`pam_gnome_keyring.so` in `/etc/pam.d/lightdm`) auto-unlocks the `login` keyring using the login password, and on most Mint installs everything else is unlocked too.

```bash
busctl --user call org.freedesktop.secrets /org/freedesktop/secrets \
  org.freedesktop.DBus.Properties Get ss org.freedesktop.Secret.Service Collections
busctl --user get-property org.freedesktop.secrets \
  /org/freedesktop/secrets/collection/<name> org.freedesktop.Secret.Collection Locked
```

Gotcha: **collection D-Bus paths escape non-alphanumeric characters as `_<hex>`**. A keyring named `Default_keyring` lives at `/org/freedesktop/secrets/collection/Default_5fkeyring` (`_` → `_5f`). Querying the unescaped name returns "Object does not exist" and looks like a missing keyring when it is not. Enumerate `Collections` first and use the paths it returns verbatim.

If a collection genuinely reports `Locked: true` and prompts, the clean fix is making the auto-unlocked `login` keyring the default (Passwords and Keys → right-click → *Set as default*) rather than stripping the password off the existing one, which stores its secrets unencrypted on disk.

### What you cannot remove — say so rather than hunting

- **LUKS full-disk-encryption passphrase at boot.** Pre-login, by design; removing it defeats the encryption.
- **Browser and application master passwords.** Not system auth; out of scope.
- **`su`** still prompts (it wants the *target* account's password). `sudo -i` is the passwordless equivalent.

### Cross-check against the broken-signing-key failure mode

If the user's complaint is specifically **"Update Manager keeps asking for my password"**, do not reach for this section first. That exact symptom is more often a broken APT repo signing key silently failing `mintupdate`'s automatic upgrades — see "Common failure modes to avoid". Diagnose that first: disabling authentication prompts would hide the symptom while leaving updates still broken.
