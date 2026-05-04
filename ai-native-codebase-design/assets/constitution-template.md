# Project Constitution (Tier 1: Hot Memory)

## 1. Project Objectives & Tech Stack
**Mission:** To build highly maintainable, AI-native software using Spec-Driven Development (SDD) and Domain-Driven Design (DDD). 
**Core Stack:** [Insert Language/Frameworks, e.g., TypeScript, Node.js, React]
**Build/Test Commands:** 
*   Test: `npm run test`
*   Lint: `npm run lint`
*   Build: `npm run build`

## 2. Core Architectural Directives
All agents MUST adhere to these global principles before writing any code:
*   **Complexity is the Enemy:** Do not push complexity upwards. Handle unavoidable complexity inside the module so the caller's interface remains simple (Pull Complexity Downwards).
*   **Deep Modules:** Maximize functionality while minimizing the interface. A module is only a good abstraction if a small fraction of its internal complexity is visible to its users.
*   **Spec-Driven Execution:** No "vibe coding." You must retrieve and read the relevant Tier 3 specifications via semantic search before modifying domain logic.
*   **Read-Before-Write:** Always read dependency files and construct a Multi-Level Reasoning (MLR) plan before executing destructive file modifications.

## 3. Orchestration & Trigger Tables
Do not attempt to solve every problem with a general-purpose approach. Consult this trigger table before making changes and invoke the appropriate Domain Specialist (Tier 2) based on the files or systems you are modifying.

| Trigger Signal (Files/Domain) | Required Agent | Action / Phase |
| :--- | :--- | :--- |
| `src/network/*`, sync logic | `network-protocol-designer` | Pre-change |
| `src/core/coordinates/*`, camera | `coordinate-wizard` | Pre-change |
| `src/domain/abilities/*` | `ability-designer` | Pre-change |
| Global architecture, module boundaries | `systems-designer` | Post-change |
| Complex UI State, React Components | `frontend-specialist` | Pre/Post-change |

*Note: If exploring unfamiliar code that is not listed here, use the `suggest_agent(task_description)` tool via the MCP retrieval server to find the correct specialist.*

## 4. Coding Conventions & Standards
### 4.1 Comments and Documentation
*   **Write Comments First:** Interface comments must be written *before* the code body to act as a design tool. 
*   **Interface vs. Implementation:** Interface comments must describe *what* a module does and omit *how* it does it. Implementation comments go inside the method body to explain *why* the code is doing something.
*   **Do Not Repeat Code:** Comments must describe things that aren't obvious from the code. Do not just restate the method name in a sentence.

### 4.2 Naming & Obviousness
*   **Precise Naming:** Choose highly precise and consistent names. Avoid generic names like `result`, `x`, or `count`. Code must be "obvious" so that a reader's first guess about its behavior is correct.
*   **Eliminate Special Cases:** Design the normal case in a way that automatically handles edge conditions. 
*   **Define Errors Out of Existence:** Instead of throwing exceptions for expected edge cases, redefine the semantics of the operation so the normal behavior handles it natively (e.g., deleting a file that doesn't exist simply returns success).

## 5. Standard Checklists
### Pre-Commit / Pre-Completion Checklist
Before marking a task as complete, the agent MUST verify:
- [ ] Have I consulted the relevant Tier 3 specification document?
- [ ] Is the module interface smaller and simpler than its implementation?
- [ ] Are all side effects (DB, API) pushed to the boundaries (Functional Core, Imperative Shell)?
- [ ] Have I written tests that fail (RED), implemented the code (GREEN), and checked for cleanliness (REFACTOR)?
- [ ] Did I run the build and test commands successfully?

## 6. Known Global Failure Modes (Symptom / Cause / Fix)
| Symptom | Cause | Fix |
| :--- | :--- | :--- |
| Test suite fails after unrelated change | Information leakage / Shared global state | Encapsulate the shared knowledge into a single deep module. |
| Cascading `try/catch` blocks | Punting complexity upwards | Redefine operation semantics to naturally cover the edge case. |
| Agent context window overflows | Reading too many files without a specific plan | Use semantic search to target exact dependencies and rely on Tier 3 summaries. |

---
*Reference: For detailed subsystem behavior, trigger the MCP retrieval service to fetch specific architectural documents from the `docs/specs/` directory (Tier 3).*
