---
name: hermes-agents
description: >-
  Use when creating, configuring, or maintaining a Hermes agent — adding a new
  agent, writing its SOUL.md, attaching skills, wiring a messaging gateway,
  scheduling its work, or retiring it. Covers profiles, personality files,
  skill sharing, kanban orchestration, and the failure modes that look like
  bugs but are configuration. Applies to any Hermes Agent installation.
metadata:
  scope: professional
---

# Managing Hermes agents

One agent per **profile**. A profile is its own Hermes home — config, secrets, personality, memory, skills, sessions, scheduled jobs. Never point two agents at one profile: both write memory automatically and each loads the other's writes at session start.

## Creating an agent

```bash
hermes profile create <name> --no-skills \
  --description "What this agent is for, written as a job spec"
hermes --profile <name> config set model.default "<provider/model>"
```

`--no-skills` matters. The bundled set loads its descriptions into context on **every turn**, so a fresh profile carries a standing cost before it has done anything. Start empty and attach only what the agent needs.

**The `--description` is the routing table.** `hermes kanban decompose` assigns work by matching against it, not by name. Write it as a job spec: what this agent does, and what it does not.

## Personality

`SOUL.md` in the profile root is the system prompt. It sits first in the prompt's stable tier, so it is read before anything else on every turn.

### Traits and principles, not a ruleset

Write what the agent **is**, then what it **holds true** — each principle with the reason attached. A list of prohibitions produces an agent that complies rather than one that behaves, and it fails in two ways:

- **Rules do not generalise.** They cover the cases the author imagined. Anything unlisted falls back to a stock assistant
- **Banning creates a vacuum.** "No filler, no flattery, numbers rather than impressions" yields something clipped and cold, because the bans removed a voice without supplying one

State a constraint as something the agent holds, with its reason: *"You don't write your own tools… an unreviewed script run across the whole vault wrecks a lot of files very fast"* generalises to cases nobody listed. *"Never write code"* does not.

### What goes where

| `SOUL.md` | A skill |
|---|---|
| Identity and voice | Procedure and workflow |
| Constraints that must hold on every turn | Command reference, formats, templates |
| Paths it needs — its data, its tools | How to use them |
| Numbers that are policy | Numbers that are detail |

> [!important] A rule in a skill is conditional on that skill loading
> Skills load on trigger; the soul loads always. If the agent needs something *before deciding what to do*, it belongs in the soul — including its working directory, its tool paths, its batch limits, and a one-line note of what each of its skills is for.

### Writing rules

- **No facts that rot.** File counts, dates, "four scripts". Policy numbers are fine; state descriptions are not
- **No grandiosity.** An agent reading portentous prose writes portentous prose
- **Apply anti-AI-speak rules to the soul itself.** Contrastive negation and rhetorical triplets creep into the very sections banning them. Phrase everything positively
- **A soul buys coherence, not sincerity.** One thing to be beats fifty things to check. Say that honestly rather than writing warmth instructions that produce a performance

### `USER.md`

Hermes loads `<profile>/memories/USER.md` as persistent memory, authoritative even after context compression. It describes the person the agent works for — without it, an agent told to be devoted has nothing to be devoted to.

It is **per profile**, and **agents can write to it**. Keep one canonical copy under version control and symlink it into each profile, so an agent's edit shows in `git status` rather than vanishing. `SOUL.md` stays per profile: that is the agent's own identity.

Check `memories/MEMORY.md` after any rule change. Agents write their own memories, and a memory learned under old rules will contradict the new ones.

## Skills

Symlink **individual** skills into `<profile>/skills/`, never the whole library — every skill's description is carried on every turn.

```bash
ln -sfn /path/to/library/<skill> ~/.hermes/profiles/<name>/skills/<skill>
```

> [!warning] Skill descriptions are truncated in the prompt
> Only the first ~60 characters survive into the agent's skill list. Trigger guidance placed at the end of a description never reaches the agent that has to choose. **Open every description with when to use it**, then say what it does.

## Messaging gateway

Adapters activate on environment variables alone — there is no enable step. For Telegram, set `TELEGRAM_BOT_TOKEN` and `TELEGRAM_ALLOWED_USERS` (numeric IDs) in the profile `.env`, then:

```bash
hermes --profile <name> gateway install
hermes --profile <name> gateway start
```

Write the token without it reaching a transcript or shell history:

```bash
read -rsp "Token: " TOK && echo && \
  printf 'TELEGRAM_BOT_TOKEN=%s\n' "$TOK" >> ~/.hermes/profiles/<name>/.env && unset TOK
```

Set `TELEGRAM_HOME_CHANNEL` so scheduled output has somewhere to go.

## Scheduled work

```bash
hermes --profile <name> cron create "0 7 * * *" "<prompt>" \
  --name <job> --deliver telegram --skill <skill>
```

> [!warning] A job's prompt outranks the agent's standing rules
> The prompt is a direct instruction and the soul is background. Change a rule and you must sweep the scheduled jobs too, or the agent will keep obeying an instruction that has been revoked everywhere else.

Delivery only happens for gateway-executed runs. `hermes cron run <id>` from the CLI tests the work and **not** the delivery — it runs in its own process, outside the gateway that owns the messaging connection. To test delivery, set the schedule a couple of minutes ahead and let it fire.

A CLI-triggered run also fails with `No LLM provider configured` unless the environment is sourced first, because a non-interactive shell does not read the profile's environment.

## Orchestration

Two mechanisms, routinely confused:

| | `delegate_task` | Kanban board |
|---|---|---|
| Who executes | A subagent under the **calling** profile | The **named assignee**, with its own soul and skills |
| Reaches another agent | No | Yes |
| Record | None | Events, runs, output — all queryable |
| Good for | Self-contained subtasks, parallel lookups | Anything writing, auditable, or needing another agent |

Delegation spawns copies of the caller. Worded as an errand for someone else, it produces the caller doing that agent's job without its tooling or its limits — and it often returns a plausible answer, which hides the mistake.

> [!important] Kanban tools are gated on a toolset
> Board tools are invisible unless the profile opts in, leaving the agent to improvise with the shell:
>
> ```bash
> hermes --profile <name> config set toolsets "hermes-cli,kanban"
> ```

**A crashed run is not a failed task.** The board re-claims and retries; a run that crashes is often followed by one that completes. Read `hermes kanban show <id>` before concluding anything.

## Costs and limits

- **Each running gateway costs roughly 150 MB.** Kanban workers exit after dispatch and do not count
- **Pin the auxiliary and compression models.** Left unset, auxiliary tasks fall back to whatever the provider chain offers, and the compression summariser — which rewrites the agent's own history — runs on a model nobody chose:

```bash
hermes --profile <name> config set auxiliary.openrouter_model "<provider/model>"
hermes --profile <name> config set compression.summary_model "<provider/model>"
```

- A `payment / credit error` in the logs usually means *not authenticated* for a provider that was never configured. Read the next line before checking a balance

## Diagnostics that mislead

| Symptom | Actual meaning |
|---|---|
| Agent gives generic answers after a config change | Stale session. Restart clears the process cache; `/new` clears the conversation. **Both are needed** |
| `Main process exited, code=exited, status=1/FAILURE` | Hermes exits `1` on `SIGTERM`. Every clean restart logs it |
| `status=75/TEMPFAIL` | Polling retries exhausted, almost always because something else called `getUpdates` on the same bot |
| `Telegram polling conflict` | A second poller stole the long poll. If a health check just ran, that was the health check |

> [!warning] Never poll a live bot's `getUpdates` as a health check
> It steals the long poll and can consume pending messages before the gateway sees them. Use `sendMessage` to prove reachability, and read the journal for everything else.

## Renaming and retiring

The systemd unit name derives from the profile name, so rename in this order or an orphaned unit is left behind:

```bash
hermes --profile old gateway stop
hermes --profile old gateway uninstall
hermes profile rename old new
hermes --profile new gateway install && hermes --profile new gateway start
```

A Telegram bot's `@username` **cannot be changed** — only its display name. Changing the handle means a new bot, a new token, and swapping it into the profile.

## The root profile

`default` is not an agent: it resolves to the Hermes home itself, holding the installation, the shared task board, credentials, and every other profile. Hermes refuses to delete it.

Do not run an agent there. Sessions and memory would mix with shared state, and `profile create --clone` copies from the **active** profile, so an agent living at the root is inherited by everything created afterwards.

Instead, set a real agent as the sticky default and make the root refuse:

```bash
hermes profile use <name>
```

Replace the root `SOUL.md` with an instruction to decline, name the available agents, and stop. The hazard is a stock assistant answering plausibly when a command lost its `--profile`; a refusal turns a silent misroute into an obvious error.
