#!/usr/bin/env python3
"""Restart a systemd unit from inside itself, without being killed first.

A plain `systemctl --user restart <unit>` run from inside the unit's own
control group kills the caller: the stop action SIGKILLs the cgroup before
the start action runs. This hands the work to a transient unit, which
systemd places in its own control group — outside the unit being stopped.

    gateway_restart.py my-service.service
    gateway_restart.py my-service.service --delay 5 --dry-run

Say what you are doing before calling this if the unit is your own runtime;
the reply stops when the restart fires.

Exit codes: 0 = restart scheduled (or rehearsed under --dry-run),
2 = refused or bad invocation.
"""

from __future__ import annotations

import argparse
import re
import shutil
import subprocess
import sys

UNIT_RE = re.compile(r"^[a-z0-9_.@-]+\.service$")


def die(message: str) -> int:
    print(f"gateway_restart: {message}", file=sys.stderr)
    return 2


def main() -> int:
    ap = argparse.ArgumentParser(
        description="Restart a systemd unit from inside it, without being killed."
    )
    ap.add_argument("unit", help="unit to restart, e.g. my-service.service")
    ap.add_argument(
        "--delay",
        type=int,
        default=3,
        help="seconds before the restart fires, so the caller can finish (default 3)",
    )
    ap.add_argument(
        "--dry-run",
        action="store_true",
        help="print the command that would run and change nothing",
    )
    args = ap.parse_args()

    if not UNIT_RE.match(args.unit):
        return die(f"{args.unit!r} is not a valid unit name; expected <name>.service")
    if args.delay < 1:
        return die("--delay must be at least 1 second; an immediate restart kills the caller")

    unit_exists = subprocess.run(
        ["systemctl", "--user", "cat", args.unit],
        capture_output=True,
        text=True,
    ).returncode == 0

    if shutil.which("systemd-run") is None:
        return die("systemd-run is not available; cannot detach the restart")

    label = args.unit[:-len(".service")]
    cmd = [
        "systemd-run",
        "--user",
        "--collect",  # remove the transient unit once it has finished
        f"--on-active={args.delay}s",
        f"--unit=restart-{label}",
        "systemctl",
        "--user",
        "restart",
        args.unit,
    ]

    # A rehearsal shows what would run and changes nothing, so it must not
    # depend on the unit existing — otherwise the tool can only be tested on
    # a host where the service happens to be installed.
    if args.dry_run:
        print(" ".join(cmd))
        if not unit_exists:
            print(f"note: {args.unit} does not exist on this host", file=sys.stderr)
        return 0

    if not unit_exists:
        return die(f"no such unit: {args.unit}")

    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        return die(result.stderr.strip() or "systemd-run failed")

    print(
        f"{args.unit} will restart in {args.delay}s, from a transient unit outside "
        f"this control group.\n"
        f"If this is your own runtime, your turn ends when it fires."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
