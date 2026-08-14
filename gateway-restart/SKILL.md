---
name: gateway-restart
description: >-
  Restart a systemd unit from inside a process that unit runs, without the
  restart command being killed by its own unit's stop action. Use when a
  service needs to restart itself — a gateway, a daemon, a long-running
  agent — and a plain `systemctl restart` would kill the shell running it.
  Works for any systemd unit with KillMode=mixed or KillMode=control-group.
---

# Restarting a service from inside itself

A `systemctl --user restart <unit>` run from inside that unit's own process
tree kills the calling shell — the stop action sends SIGKILL to the whole
control group before the start action runs. The restart never completes and
the failure looks like a crash.

The fix is to hand the restart to `systemd-run`, which creates a transient
unit in its own control group. That unit is outside the service being
stopped, so it survives to start it again.

## Workflow

1. **Detect the restart is needed.** A service that has stopped responding
   to health checks, stalled with no error, or consumed all available
   memory — the kind of stuck that restarting resolves but the process
   itself cannot recover from.

2. **Schedule the restart through a transient unit:**

   ```bash
   systemd-run --user --collect \
     --on-active=3s \
     --unit=restart-<label> \
     systemctl --user restart <unit>
   ```

   `--collect` removes the transient unit once it has finished.
   `--on-active=3s` gives the caller a few seconds to finish its reply
   (or log its intent) before the restart fires.

3. **Say what you are doing before you call it.** If the restart is of
   your own runtime, your turn ends when it fires — the reply stops
   mid-sentence. The message goes before the command, not after.

4. **Verify the unit came back.** Check `systemctl --user is-active <unit>`
   after the delay has elapsed. It should read `active`.

## Why this works

| Problem | Cause |
|---|---|
| `systemctl restart` kills the caller | The unit's `KillMode=mixed` (or `control-group`) sends SIGKILL to the entire cgroup — including the shell the command is running from |
| `systemd-run --on-active` survives | The transient unit is placed in its own cgroup, outside the service being stopped |
| `--collect` leaves no mess | The transient unit is removed automatically after its command completes |

## Failure modes

- **systemd-run is not installed.** The command is part of systemd itself,
  but some minimal containers or chroots omit it. Check with `which
  systemd-run` before relying on this approach.

- **The unit does not exist.** `systemctl restart` on a missing unit fails
  silently. Verify the unit exists before scheduling the restart.

- **Delay too short.** An immediate restart (0s) kills the caller before
  `systemd-run` itself finishes. Use at least 1s; 3s is safer.

- **The unit has `KillMode=process`.** This mode only kills the main
  process, not the control group, so a plain `systemctl restart` would
  work. The transient-unit approach is still safe but unnecessary.

## Example

```bash
# Check the unit is alive
systemctl --user is-active my-service.service

# Schedule a restart in 3 seconds
systemd-run --user --collect --on-active=3s \
  --unit=restart-my-service \
  systemctl --user restart my-service.service

# Wait and verify
sleep 4 && systemctl --user is-active my-service.service
```

## Script

A reusable script is provided in `scripts/gateway_restart.py` that wraps
this workflow with input validation, unit existence checks, and a dry-run
mode.

## Edge cases

- **Multiple restarts in quick succession.** Each transient unit needs a
  unique name (`--unit=restart-<label>`). Reusing the same name before the
  previous transient has been collected (removed) will fail.

- **The service dies on restart.** If the unit exits immediately after
  restart, check whether a `[Unit]` drop-in sets `StartLimitIntervalSec`
  to a non-zero value and `StartLimitBurst` to a reasonable cap. Without
  a non-zero interval the start limiter is disabled, systemd retries
  forever, and the unit never reaches `failed` state — so `OnFailure`
  never fires. Add:
  ```
  [Unit]
  StartLimitIntervalSec=600
  StartLimitBurst=5
  ```