---
name: prd
description: >-
  Generate a comprehensive Product Requirements Document (PRD) for a software
  project or feature. Interviews the user, then produces a structured document
  with user stories, functional requirements, acceptance criteria, non-goals,
  and a phased roadmap. Use when the user says "write a PRD", "document
  requirements", "plan this feature", "spec this out", or wants to capture
  what to build before building it.
---

# PRD Generator

Interview the user, then produce a structured PRD that is detailed enough for
an AI agent or junior developer to implement from scratch without follow-up questions.

**Important:** Do NOT start implementing. Only produce the PRD document.

---

## Phase 1: Discovery Interview

Before writing anything, ask the user clarifying questions. Use lettered options
so they can reply with shorthand like "1B, 2A, 3C".

Only ask questions where the answer genuinely changes the PRD. A minimal set of
critical questions is better than an exhaustive list. Focus on:

- **Problem/Goal** — What pain point does this solve? Why now?
- **Users** — Who uses this, and in what context?
- **Scope** — What is explicitly out of scope for this version?
- **Success** — How do we know it worked? What are the measurable outcomes?
- **Constraints** — Tech stack, deadlines, budget, regulatory requirements?

### Question format

```
1. What is the primary goal?
   A. [Option]
   B. [Option]
   C. [Option]
   D. Other: [please specify]

2. Who is the target user?
   A. [Option]
   B. [Option]
```

Do not write the PRD until you have answers. If the user's initial description
already answers a question clearly, skip it.

---

## Phase 2: Scoping

Before drafting, synthesize the answers:

- Identify dependencies and hidden complexity the user may not have considered
- Define the user flow end-to-end
- Decide what is MVP vs. later phases
- List explicit non-goals to protect scope

---

## Phase 3: PRD Document

Save the final document to `tasks/prd-[feature-name].md` (kebab-case filename).

Use this exact structure:

---

```markdown
# PRD: [Feature Name]

## 1. Executive Summary

**Problem:** [1–2 sentences on the pain point.]
**Solution:** [1–2 sentences on the proposed fix.]
**Success Criteria:**
- [Measurable KPI 1]
- [Measurable KPI 2]
- [Measurable KPI 3]

---

## 2. Users & Context

**Target Users:** [Personas — who uses this and in what situation?]

---

## 3. User Stories

Each story must be small enough to implement in one focused session (INVEST: Independent, Negotiable, Valuable, Estimable, Small, Testable).

### US-001: [Title]
**Priority:** P0 / P1 / P2 / P3
> P0 = must have · P1 = should have · P2 = nice to have · P3 = out of scope

**Description:** As a [role], I want [feature] so that [benefit].

**Acceptance Criteria:**
- [ ] [Specific, verifiable criterion — not "works correctly"]
- [ ] [Another criterion]
- [ ] Typecheck/lint passes
- [ ] **[UI only]** Visually verified in browser

### US-002: [Title]
...

---

## 4. Functional Requirements

Numbered, unambiguous statements of what the system must do.

- **FR-1:** The system must [action] when [trigger].
- **FR-2:** When a user [does X], the system must [respond Y].

---

## 5. Non-Goals

What this version will NOT include. Be explicit — this protects scope.

- [Thing we are not building]
- [Thing deferred to a later phase]

---

## 6. Technical Considerations

- Known constraints or dependencies
- Integration points (APIs, databases, auth)
- Performance requirements (e.g., "must respond within 200ms at p95")
- Security / data handling requirements

> If unknown, label as **TBD** — never invent constraints.

---

## 7. AI / External Service Requirements *(omit if not applicable)*

- Tools or APIs required
- How to evaluate output quality (benchmarks, pass rates, accuracy thresholds)

---

## 8. Phased Roadmap

| Phase | Scope | Stories |
|-------|-------|---------|
| MVP   | [Core value delivered] | US-001, US-002 |
| v1.1  | [Next increment] | US-003 |
| v2.0  | [Future vision] | TBD |

---

## 9. Open Questions

- [Unresolved decision or dependency]
- [Question that needs an answer before implementation]
```

---

## Quality Rules

**Acceptance criteria must be verifiable, not vague:**

| Bad | Good |
|-----|------|
| "The system should be fast" | "API responds within 200ms at p95 for 10k records" |
| "Make it user-friendly" | "Task can be completed in ≤3 clicks with no tooltip" |
| "Works correctly" | "Submit button shows spinner; on success, redirects to /dashboard" |

**Completeness check — every requirement should answer:**
- What: clear description of the feature
- Why: business value or problem solved
- Who: target user or system actor
- When: priority level (P0–P3)
- How (high-level): approach if already known
- Acceptance: verifiable done criteria
- Scope: what is NOT included

---

## Pre-Save Checklist

Before saving the PRD:

- [ ] Asked clarifying questions with lettered options and incorporated answers
- [ ] User stories follow US-001 format and are small enough for one session
- [ ] Every acceptance criterion is specific and verifiable
- [ ] Functional requirements are numbered and unambiguous
- [ ] Non-goals section is explicit
- [ ] TBD used for any unknown constraints (nothing invented)
- [ ] Saved to `tasks/prd-[feature-name].md`

---

## Example

```markdown
# PRD: Task Priority System

## 1. Executive Summary

**Problem:** Users have no way to distinguish urgent tasks from low-priority ones, causing important work to be missed.
**Solution:** Add priority levels (high/medium/low) to tasks with visual indicators and filtering.
**Success Criteria:**
- Users can change priority in ≤2 clicks
- High-priority tasks visible at top of list without filtering
- No regression in task list load time (< 300ms p95)

---

## 2. Users & Context

**Target Users:** Individual productivity users managing 10–100 tasks per week.

---

## 3. User Stories

### US-001: Store task priority in database
**Priority:** P0
**Description:** As a developer, I need to persist task priority so it survives page refreshes.
**Acceptance Criteria:**
- [ ] Add `priority` column to tasks table: `'high' | 'medium' | 'low'`, default `'medium'`
- [ ] Migration runs without errors
- [ ] Typecheck passes

### US-002: Display priority badge on task cards
**Priority:** P0
**Description:** As a user, I want to see priority at a glance so I know what needs attention.
**Acceptance Criteria:**
- [ ] Colored badge on every card: red=high, yellow=medium, gray=low
- [ ] Visible without hover or click
- [ ] Typecheck passes
- [ ] Visually verified in browser

### US-003: Filter tasks by priority
**Priority:** P1
**Description:** As a user, I want to filter to only high-priority tasks when focused.
**Acceptance Criteria:**
- [ ] Filter dropdown: All | High | Medium | Low
- [ ] State persists in URL params
- [ ] Empty state message when no tasks match
- [ ] Typecheck passes
- [ ] Visually verified in browser

---

## 4. Functional Requirements

- **FR-1:** Add `priority` field to tasks table (`'high' | 'medium' | 'low'`, default `'medium'`)
- **FR-2:** Display colored priority badge on each task card
- **FR-3:** Include priority selector in the task edit modal
- **FR-4:** Add priority filter dropdown to task list header
- **FR-5:** Sort by priority within each column (high → medium → low)

---

## 5. Non-Goals

- No priority-based notifications or reminders
- No automatic priority assignment based on due date
- No priority inheritance for subtasks

---

## 6. Technical Considerations

- Reuse existing badge component with color variants
- Filter state via URL search params (no extra state library)
- Priority stored in DB, not computed at runtime

---

## 8. Phased Roadmap

| Phase | Scope | Stories |
|-------|-------|---------|
| MVP | Store and display priority | US-001, US-002 |
| v1.1 | Filtering and sorting | US-003 |
| v2.0 | Keyboard shortcuts, bulk edit | TBD |

---

## 9. Open Questions

- Should priority affect ordering within a Kanban column?
- Do we need keyboard shortcuts for priority changes in v1?
```
