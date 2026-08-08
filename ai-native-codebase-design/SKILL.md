---
name: ai-native-codebase-design
description: >-
  Enforces context-efficient software architecture, deep modules, strict
  information hiding, and Spec-Driven Development (SDD). Use this skill when
  designing new systems, planning refactors, reviewing module boundaries, or
  structuring multi-agent projects. Trigger keywords: architecture review,
  refactor, module design, deep modules, information hiding, complexity
  reduction, SDD contract, spec-driven, AGENTS.md, CLAUDE.md, codebase
  structure, tiered memory, context engineering, context rot, agent context
  management, multi-agent orchestration.
license: MIT
compatibility: >-
  No external tools required for core architectural principles. Implementing
  Tier 3 cold memory (on-demand spec retrieval) requires an MCP-compatible
  retrieval server — only needed for large codebases adopting the full 3-tier
  context infrastructure.
metadata:
  scope: professional
  version: "1.1.0"
  primary_framework: "A Philosophy of Software Design (Ousterhout)"
  secondary_frameworks: "SDD (spec-anchored), DDD, MLR, progressive disclosure"
---
# AI-Native Codebase Design

## Core Philosophy

Complexity is anything related to the structure of a software system that makes it hard to understand and modify. For AI agents, complexity translates directly to context window exhaustion, context rot (degraded output quality as irrelevant context accumulates), and token inefficiency. The goal of this skill is to fight complexity by pulling it downwards and encapsulating it within predictable boundaries — and to load context progressively, so the agent holds only what the current task phase requires.

## Execution Workflow

When tasked with generating new features or designing architecture, follow this sequence:

1. **Spec-Driven Development (SDD) Validation**: Before writing code, establish or read a functional specification. Practice **spec-anchored** SDD: the spec declares intent and acceptance criteria and is version-controlled alongside the code; code plus tests remain the enforcement layer. Do not begin coding without clear acceptance criteria. Write acceptance criteria in a testable form (EARS-style: "WHEN [trigger], the [system] SHALL [response]") so each criterion maps to an executable test.
2. **Three-Phase Decomposition**: Follow the specify → plan → tasks sequence now standard across SDD tooling (Spec Kit, Kiro, OpenSpec): produce the spec, derive an implementation plan with conventions applied, then break the plan into atomic tasks implemented independently. Code generation comes last.
3. **Design It Twice**: For every major architectural decision, generate at least two fundamentally different interface designs. Weigh their pros and cons regarding cognitive load and information leakage before committing.
4. **Interface-First Generation**: Write the interface documentation (docstrings/comments) *before* the method body. If the resulting comment is overly long or difficult to write, it is a red flag indicating a flawed abstraction — stop and redesign the interface.
5. **Multi-Level Reasoning (MLR) Planning**: Decompose complex tasks into a hierarchical graph (High-Level → Intermediate-Level → Detailed-Level nodes) to map logical dependencies before execution. This prevents cascading errors and keeps reasoning modular.

## Architectural Rules

### 1. Module & Interface Constraints

- **Build Deep Modules**: Maximize functionality while minimizing the interface. A module is a good abstraction only if a small fraction of its internal complexity is visible to its users.
- **Practice Strict Information Hiding**: Encapsulate design decisions entirely within a single module. Avoid "temporal decomposition" where operations are split simply because they happen at different times.
- **Pull Complexity Downwards**: It is more important for a module to have a simple interface than a simple implementation. If complexity is unavoidable, handle it inside the module so callers do not have to.

### 2. Functional & Layer Constraints

- **Different Layer, Different Abstraction**: Every layer must provide a distinct abstraction. Avoid pass-through methods that do nothing but invoke another method with the same signature.
- **Define Errors Out of Existence**: Reduce exception handling by redefining operation semantics so normal behavior covers edge cases (e.g., deleting a non-existent file simply returns success).
- **Resist Over-Decomposition**: Do not blindly break code into tiny fragments. Keep related code together if separating it creates entanglement that forces the reader to jump between methods to understand state.

### 3. Context & Domain Constraints

- **Functional Core, Imperative Shell**: Isolate pure business logic from external side effects (database queries, APIs).
- **Domain-Driven Boundaries**: Treat different business areas as Bounded Contexts with their own models and ubiquitous language.
- **Tiered Codified Context (progressive disclosure)**: For large codebases, manage AI context using a 3-tier memory system aligned to the progressive disclosure pattern now standard in agent-skill runtimes:
  1. *Tier 1 (Hot):* A globally loaded constitution defining core project rules. Publish it as **AGENTS.md** (the open cross-agent standard) with CLAUDE.md pointing to it for compatibility. Keep it lean and strictly non-obvious: exact build/test commands, hard constraints, trigger tables. Nothing the agent can read from the repo itself.
  2. *Tier 2 (Warm):* Specialized skills and agent prompts invoked per task/domain. Advertise cheaply (name plus description, ~100 tokens), load fully only on trigger, keep each SKILL.md body under ~500 lines / ~5k tokens, and push detail into reference files loaded on demand.
  3. *Tier 3 (Cold):* On-demand specifications retrieved via semantic search.
- **Load by Phase, Not Upfront**: Prefer index-first loading (read a table of contents, then fetch the needed section) and phase-based loading (planning context during planning, implementation detail during implementation). Over-fetching "just in case" causes context rot as reliably as under-fetching causes hallucinated APIs.

## Anti-Patterns

| Anti-Pattern | Symptom | Fix |
| :--- | :--- | :--- |
| **Vibe Coding** | Guessing intent from vague prompts instead of a spec | Pause and request/generate an SDD contract with testable acceptance criteria |
| **Change Amplification** | Modifying multiple files to achieve a simple feature change | Encapsulate the shared knowledge into a single deep module |
| **Context Rot** | Output quality degrades as the session grows; agent cites irrelevant files | Progressive disclosure: index-first and phase-based loading, compact or restart long sessions |
| **Agent-File Duplication** | AGENTS.md/CLAUDE.md restates what the repo already says | Keep constitution files strictly non-obvious; generated agent files that duplicate repo content measurably reduce success rates and raise cost — generate as a draft, then aggressively trim by hand |
| **Spec Drift** | Spec and implementation disagree; agent codes against stale intent | Zero drift tolerance: update the spec in the same session as the change, enforce with tests |
| **Skill Sprawl** | Dozens of overlapping, unvetted skills loaded into every session | Curate a small trusted set; audit third-party skills before install (a large share of community skills contain vulnerabilities) and version them like dependencies |
| **Vague Naming** | Generic names (`count`, `x`, `result`) that force reading the implementation | Use precise names that convey exact nature without reading the function body |
| **Comment Duplication** | Comments that restate what the code already says | Interface comments explain *what*; implementation comments explain *why* |
| **Configuration Sprawl** | Exporting numerous config parameters instead of computing defaults | Pull complexity downward — determine policy automatically inside the module |

## Reference Files

> **Read `references/TIERED_MEMORY_ARCHITECTURE.md`** if any of the following are true:
> - The user wants to implement the 3-tier context system for a large codebase
> - The user asks how to set up on-demand spec retrieval, MCP memory servers, or Tier 3 cold memory
> - You need to generate a Tier 3 specification document and require the standard template
> - You need the progressive disclosure token budgets or the skill trust checklist
>
> Skip this reference if the task only involves applying core architectural principles (deep modules, SDD, MLR) without setting up the memory infrastructure.

> **Use `assets/constitution-template.md` as a starting point** if any of the following are true:
> - The user wants to create a project constitution (AGENTS.md, CLAUDE.md, or equivalent Tier 1 hot-memory file)
> - The user asks how to structure global rules, orchestration trigger tables, or coding conventions for a multi-agent project
>
> This file is a blank template to be filled in and adapted for the user's specific project — do not read it as authoritative project guidance.
