# Diagnostic reference for unresponsive Hermes agents

This file carries the detail that would bloat the main skill. Read it only when
the main skill's workflow does not resolve the issue.

## agent_doctor.py check list

`~/.agents/agent-tools/agent_doctor.py` checks (in order):

| Check | What it detects |
|---|---|
| Profile directory exists | Deleted or renamed profile |
| SOUL.md is a real file, not a dangling symlink | Symlink target moved |
| Skill symlinks resolve | Skill repo moved or deleted |
| Service is active | Gateway not running |
| Restart count in last 24 h | Crash-looping gateway |
| LLM API key in process environ | Missing `env_file` or sourced wrong profile |
| Token reachability | Key is valid and the provider responds |
| User allowlist | Bot visible to users not on the allowlist |
| Home channel set | Cron delivery has nowhere to go |
| Webhook mode vs polling | Mixing webhook and polling on the same token |
| getUpdates consumer conflict | Second process calling getUpdates |
| Polling conflicts in journal | Repeated long-poll steals |
| Agent turns processed | Agent alive but not responding |
| Recent errors in journal | Application-layer failures |

Exit codes: 0 = no faults found, 1 = faults found, 2 = bad invocation.

## The four real causes — expanded

### 1. Stale session

The soul and skills are injected at session creation. A restart (`gateway restart`)
clears the Hermes process cache — the loaded prompt, the tool bindings, the skill
descriptions. A `/new` clears the conversation history that was built from the
old state. You need **both** because they fix different things. The symptom is an
agent that answers correctly but as a generic assistant — the soul is still in
memory from the previous load.

### 2. getUpdates probe

Calling Telegram's `getUpdates` to test liveness steals the gateway's long poll.
If a message arrives during the probe, the gateway never sees it. After five such
conflicts the gateway exits `status=75/TEMPFAIL` and restarts into the same fight,
because the probe runs on a timer and fires again shortly after the restart.

Two of the four unresponsive-agent incidents on 2026-08-08 were **caused by the
diagnostic itself**. The tool being debugged was also the tool destroying the
system.

**Use `sendMessage` to prove reachability.** Read everything else from
`journalctl` or `agent_doctor.py`, which reads `getWebhookInfo` (read-only,
no conflict).

### 3. hermes not on PATH

A dispatched kanban worker or a cron job runs non-interactively. It inherits a
minimal `PATH` that does not include `~/.local/bin`. An agent told to run
`hermes send` fails silently — the command is not found, the error goes to
stderr which nobody reads, and the message never arrives.

**Use absolute paths everywhere.** `~/.local/bin/hermes send ...` in skill
instructions, soul prompts, and cron prompts. The `~` expands in the shell
the worker uses, so it works regardless of how PATH was set.

### 4. New agent missing a fleet-wide change

Chiron was created after the restart/OOM drop-ins were added to the other agents.
He had none of them. This applies to any configuration change, systemd drop-in,
cron job, or environment pin that was applied across the fleet — it has to be
applied again to every new agent created afterwards.

**Before creating an agent, check what fleet-wide changes exist.** A recommended
workflow is a checklist in the agent-creation procedure that includes "apply any
outstanding fleet-wide changes."

## status=1/FAILURE on restart

```
Main process exited, code=exited, status=1/FAILURE
```

Hermes exits code `1` on SIGTERM. Every clean restart logs this. The giveaway is
the line immediately before:

```
Shutdown context: signal=SIGTERM
```

If there is no SIGTERM line, the status=1 is genuine. Investigate further.