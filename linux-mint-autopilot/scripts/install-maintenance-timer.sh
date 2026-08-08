#!/bin/bash
#
# install-maintenance-timer — install the fortnightly system-maintenance timer
# and the kernel-prune helper it calls.
#
# Idempotent: safe to re-run. Overwrites the installed scripts and unit files
# with the current versions, then re-enables the timer. Re-running never
# double-schedules and never removes anything from the system.
#
# Usage (as root):
#   sudo ./install-maintenance-timer.sh                       # fortnightly, 1st + 15th
#   sudo ./install-maintenance-timer.sh 'Sun *-*-* 03:00:00'  # custom OnCalendar
#
# Installs:
#   /usr/local/sbin/system-maintenance
#   /usr/local/sbin/purge-old-kernels
#   /etc/systemd/system/system-maintenance.service
#   /etc/systemd/system/system-maintenance.timer
#
set -euo pipefail

SCHEDULE="${1:-*-*-01,15 00:00:00}"
src="$(dirname "$(readlink -f "$0")")"

if (( EUID != 0 )); then
    echo "error: must run as root (use sudo)" >&2
    exit 1
fi

for f in system-maintenance.sh purge-old-kernels.sh; do
    if [[ ! -f "$src/$f" ]]; then
        echo "error: cannot find $src/$f — run this from the skill's scripts/ directory" >&2
        exit 1
    fi
done

# A cron entry AND a timer would run the same job twice. The skill never
# installs a cron entry, but a hand-rolled one from an earlier setup might
# still be lying around.
for stale in /etc/cron.weekly/system-maintenance /etc/cron.daily/system-maintenance \
             /etc/cron.weekly/purge-old-kernels /etc/cron.daily/purge-old-kernels; do
    if [[ -e "$stale" ]]; then
        echo "warning: $stale exists and would double-run this job." >&2
        echo "         Remove it before relying on the timer." >&2
    fi
done

install -o root -g root -m 755 "$src/system-maintenance.sh"  /usr/local/sbin/system-maintenance
install -o root -g root -m 755 "$src/purge-old-kernels.sh"   /usr/local/sbin/purge-old-kernels
echo "installed: /usr/local/sbin/system-maintenance, /usr/local/sbin/purge-old-kernels"

cat >/etc/systemd/system/system-maintenance.service <<'UNIT'
[Unit]
Description=Routine system maintenance (journal, APT cache, trash, flatpak, kernels)
Documentation=file:///usr/local/sbin/system-maintenance
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/sbin/system-maintenance
UNIT

cat >/etc/systemd/system/system-maintenance.timer <<UNIT
[Unit]
Description=Run system maintenance on a schedule

[Timer]
OnCalendar=$SCHEDULE
# Catch up shortly after boot if the machine was off when the timer was due.
Persistent=true
# Avoid every machine firing at exactly midnight.
RandomizedDelaySec=15m

[Install]
WantedBy=timers.target
UNIT

echo "installed: system-maintenance.service, system-maintenance.timer (OnCalendar=$SCHEDULE)"

systemctl daemon-reload
systemctl enable --now system-maintenance.timer

echo
systemctl list-timers system-maintenance.timer --no-pager
echo
echo "Done. Test it now with:  sudo systemctl start system-maintenance.service"
echo "Then read the log with:  journalctl -t system-maintenance -n 50"
