---
name: ai-native-codebase-design
description: >-
  Enforces context-efficient software architecture, deep modules, strict
  information hiding, and Spec-Driven Development (SDD). Use this skill when
  designing new systems, planning refactors, reviewing module boundaries, or
  structuring multi-agent projects. Trigger keywords: architecture review,
  refactor, module design, deep modules, information hiding, complexity
  reduction, SDD contract, CLAUDE.md, codebase structure, tiered memory,
  agent context management, multi-agent orchestration.
license: MIT
compatibility: >-
  No external tools required for core architectural principles. Implementing
  Tier 3 cold memory (on-demand spec retrieval) requires an MCP-compatible
  retrieval server — only needed for large codebases adopting the full 3-tier
  context infrastructure.
metadata:
  primary_framework: "A Philosophy of Software Design (Ousterhout)"
  secondary_frameworks: "SDD, DDD, MLR"
---
# AI-Native Codebase Design

## Core Philosophy

Complexity is anything related to the structure of a software system that makes it hard to understand and modify. For AI agents, complexity translates directly to context window exhaustion and token inefficiency. The goal of this skill is to fight complexity by pulling it downwards and encapsulating it within predictable boundaries.

## Execution Workflow

When tasked with generating new features or designing architecture, follow this sequence:

1. **Spec-Driven Development (SDD) Validation**: Before writing code, establish or read a functional specification. The spec is the absolute source of truth; code is the implementation detail. Do not begin coding without clear acceptance criteria.
2. **Design It Twice**: For every major architectural decision, generate at least two fundamentally different interface designs. Weigh their pros and cons regarding cognitive load and information leakage before committing.
3. **Interface-First Generation**: Write the interface documentation (docstrings/comments) *before* the method body. If the resulting comment is overly long or difficult to write, it is a red flag indicating a flawed abstraction — stop and redesign the interface.
4. **Multi-Level Reasoning (MLR) Planning**: Decompose complex tasks into a hierarchical graph (High-Level → Intermediate-Level → Detailed-Level nodes) to map logical dependencies before execution. This prevents cascading errors and keeps reasoning modular.

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
- **Tiered Codified Context**: For large codebases, manage AI context using a 3-tier memory system:
  1. *Tier 1 (Hot):* A globally loaded constitution defining core project rules.
  2. *Tier 2 (Warm):* Specialized agent prompts invoked per task/domain.
  3. *Tier 3 (Cold):* On-demand specifications retrieved via semantic search.

## Anti-Patterns

| Anti-Pattern | Symptom | Fix |
| :--- | :--- | :--- |
| **Vibe Coding** | Guessing intent from vague prompts instead of a spec | Pause and request/generate an SDD contract |
| **Change Amplification** | Modifying multiple files to achieve a simple feature change | Encapsulate the shared knowledge into a single deep module |
| **Vague Naming** | Generic names (`count`, `x`, `result`) that force reading the implementation | Use precise names that convey exact nature without reading the function body |
| **Comment Duplication** | Comments that restate what the code already says | Interface comments explain *what*; implementation comments explain *why* |
| **Configuration Sprawl** | Exporting numerous config parameters instead of computing defaults | Pull complexity downward — determine policy automatically inside the module |

## Reference Files

> **Read `references/TIERED_MEMORY_ARCHITECTURE.md`** if any of the following are true:
> - The user wants to implement the 3-tier context system for a large codebase
> - The user asks how to set up on-demand spec retrieval, MCP memory servers, or Tier 3 cold memory
> - You need to generate a Tier 3 specification document and require the standard template
>
> Skip this reference if the task only involves applying core architectural principles (deep modules, SDD, MLR) without setting up the memory infrastructure.

> **Use `assets/constitution-template.md` as a starting point** if any of the following are true:
> - The user wants to create a project constitution (CLAUDE.md or equivalent Tier 1 hot-memory file)
> - The user asks how to structure global rules, orchestration trigger tables, or coding conventions for a multi-agent project
>
> This file is a blank template to be filled in and adapted for the user's specific project — do not read it as authoritative project guidance.
