# Tiered Memory Architecture & MCP Setup

## 1. The 3-Tier Context Philosophy

To prevent context window exhaustion and ensure AI agents produce consistent, convention-adherent code, this project organises knowledge into a three-tier "codified context" infrastructure. The tiers map directly onto the progressive disclosure pattern that agent-skill runtimes (Claude Code, Microsoft Agent Framework, and others) now implement natively.

- **Tier 1: Hot Memory (Constitution):** Always loaded. Contains global rules, orchestration protocols, and trigger tables. Publish as `AGENTS.md` (the open cross-agent standard) with `CLAUDE.md` pointing to it, so every agent vendor reads the same file.
- **Tier 2: Specialized Skills & Agents:** Invoked per task. Contains deep, project-specific domain knowledge and symptom-cause-fix tables for specific subsystems.
- **Tier 3: Cold Memory (Knowledge Base):** Retrieved on demand. Contains explicit subsystem specifications, file paths, and architectural rules.

## 2. Progressive Disclosure Budgets (Tier 2)

Skill runtimes load in stages; budget each stage deliberately:

| Stage | What loads | Budget |
|-------|-----------|--------|
| Advertise | Name + description (frontmatter only), injected at session start | ~100 tokens per skill |
| Load | Full SKILL.md body, on task match | Under ~5,000 tokens / 500 lines |
| Reference | `references/*.md` files, on demand | Unbounded, but single-subsystem scoped |

Consequences: dozens of skills can be advertised for less context than one activated skill costs; put procedure in SKILL.md and detail in references; write descriptions as trigger conditions, since they are the only thing the router sees.

**Skill trust:** treat third-party skills as dependencies. Audit before install (empirical analyses find a substantial share of community-contributed skills contain vulnerabilities), pin versions, and re-review on update.

## 3. Tier 3: Cold Memory Guidelines

Cold memory consists of living specification documents written specifically for **AI consumption**, not human readers.

- **Explicit Details:** Always include explicit code patterns, exact file paths, parameter names, and expected behaviors.
- **Single Subsystem Scope:** Each document must be strictly scoped to a single subsystem to enable precise, targeted retrieval.
- **Zero Drift Tolerance:** Specifications are load-bearing. If a subsystem's implementation changes, its specification must be updated in the same session to prevent the AI from generating code based on stale information.
- **Testable Criteria:** Where a spec states behaviour, phrase it in EARS form ("WHEN [trigger], the [system] SHALL [response]") so it can be mapped one-to-one to a test.

## 4. MCP Retrieval Server (Tier 3 prerequisite)

Tier 3 cold memory requires an MCP-compatible retrieval server that can perform semantic search over your spec documents. This is only needed when the codebase is large enough that loading all specs into context at once would be wasteful.

The server should expose at minimum:
- A semantic search tool (e.g., `search_specs(query)`) for targeted spec retrieval
- A suggest tool (e.g., `suggest_agent(task_description)`) for routing to the correct Tier 2 specialist when the trigger table in the constitution doesn't cover the current task

Without an MCP server, Tier 3 cold memory degrades gracefully — agents can still follow Tier 1 and Tier 2 principles, and load spec documents manually as needed.

## 5. Standard Tier 3 Specification Template

When generating a new Tier 3 specification document, use the following structure:

```markdown
# [Subsystem Name] Specification

## Core Mechanism
[Brief description of what the subsystem does, including specific file paths
and primary functions/classes.]

## Correctness Pillars
| Pillar | Requirement |
|--------|-------------|
| [Concept] | [Strict rule the AI must follow, e.g., "Use GetSyncedTime(), NOT Date.now()"] |

## Known Failure Modes
| Symptom | Cause | Fix |
|---------|-------|-----|
| [Observable error] | [Underlying code issue] | [Specific architectural fix] |
```
