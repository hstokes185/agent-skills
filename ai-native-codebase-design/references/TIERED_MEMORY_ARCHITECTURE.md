# Tiered Memory Architecture & MCP Setup

## 1. The 3-Tier Context Philosophy

To prevent context window exhaustion and ensure AI agents produce consistent, convention-adherent code, this project organises knowledge into a three-tier "codified context" infrastructure.

- **Tier 1: Hot Memory (Constitution):** Always loaded. Contains global rules, orchestration protocols, and trigger tables.
- **Tier 2: Specialized Agents:** Invoked per task. Contains deep, project-specific domain knowledge and symptom-cause-fix tables for specific subsystems.
- **Tier 3: Cold Memory (Knowledge Base):** Retrieved on demand. Contains explicit subsystem specifications, file paths, and architectural rules.

## 2. Tier 3: Cold Memory Guidelines

Cold memory consists of living specification documents written specifically for **AI consumption**, not human readers.

- **Explicit Details:** Always include explicit code patterns, exact file paths, parameter names, and expected behaviors.
- **Single Subsystem Scope:** Each document must be strictly scoped to a single subsystem to enable precise, targeted retrieval.
- **Zero Drift Tolerance:** Specifications are load-bearing. If a subsystem's implementation changes, its specification must be updated in the same session to prevent the AI from generating code based on stale information.

## 3. MCP Retrieval Server (Tier 3 prerequisite)

Tier 3 cold memory requires an MCP-compatible retrieval server that can perform semantic search over your spec documents. This is only needed when the codebase is large enough that loading all specs into context at once would be wasteful.

The server should expose at minimum:
- A semantic search tool (e.g., `search_specs(query)`) for targeted spec retrieval
- A suggest tool (e.g., `suggest_agent(task_description)`) for routing to the correct Tier 2 specialist when the trigger table in the constitution doesn't cover the current task

Without an MCP server, Tier 3 cold memory degrades gracefully — agents can still follow Tier 1 and Tier 2 principles, and load spec documents manually as needed.

## 4. Standard Tier 3 Specification Template

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
