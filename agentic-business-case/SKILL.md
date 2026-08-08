---
name: agentic-business-case
description: Build a complete, enterprise-grade business plan for an AI agent or agentic system from a user's idea — delivered as a comprehensive markdown business plan plus a companion PowerPoint deck (with workflow and framework diagrams). Use this skill whenever the user provides an agentic AI project idea, use case, or opportunity and wants a business case, business plan, design proposal, executive pitch, or deployment blueprint built from it — including requests like "build a business plan for my agent idea", "turn this use case into a business case", "make the deck for my agent", or "apply the agentic frameworks to my project". Also trigger when the user mentions the PROFIT framework, the agentic viability checklist, the AI adoption matrix, or asks whether an agent idea is viable. Exhaustive interviewing of the user is expected to cover every detail the plan needs.
metadata:
  scope: professional
---

# Agentic business case builder

Takes a user's agentic project idea and produces two deliverables, both reaching the quality bar in `references/rubric.md`:

1. **A complete markdown business plan** — the primary deliverable. A full written business case and high-level design proposal a board member could act on, covering problem, justification, financials, design, and governance at depth.
2. **A companion PowerPoint deck** — 8–12 slides with native-shape diagrams, built on the user's own template where they have one. The markdown is the evidence base; the deck is the executive artefact.

The work applies to any enterprise. Do not assume a specific organisation, sector, or context unless the user states it. Ask for the user's deck template at the start of deck work; build from scratch only if they have none.

This skill is self-contained. Everything it needs is in `references/`; it has no external dependencies.

## Required reading before starting

Read these in order — do not skip any:

1. `references/frameworks.md` — the framework source of truth. Every framework, condensed for application. The analysis must apply all of the relevant ones, visibly and by name.
2. `references/rubric.md` — the quality bar per criterion and the failure modes to avoid.
3. `references/deck-structure.md` — slide-by-slide blueprint, template mechanics, and diagram construction code.
4. `references/formatting.md` — production rules for the deck (currency, bullet suppression, title-card colour, single calculation block, preserving user edits). Apply these whenever building the deck.
5. **Deck tooling** — if your environment provides a pptx skill (for example `/mnt/skills/public/pptx/SKILL.md`), read it before deck work; otherwise build the deck with `python-pptx` directly, following the code in `references/deck-structure.md`.
6. **Prose style** — if an oxford-markdown skill is available in your environment, follow it for prose structure; otherwise use the fallback markdown style at the end of this file. Either way, the writing rules below override conflicting style conventions for generated deliverables.

## Workflow

### Step 1 — Interview the user exhaustively

The default is to ask, not to estimate. Walk the user through every input the frameworks in the guide need, grouped so they can answer in batches. Keep asking across multiple rounds until every framework can be completed with real inputs. Do not begin analysis with gaps.

Cover at least:

- **Problem and scale** — the operational problem; affected workflow, team, or customer journey; volumes per day or month; time per task; fully-loaded staff cost; error rates; current backlog; cost of inaction
- **Strategic fit** — why this sits in the agentic cluster and not traditional AI, an LLM assistant, augmented judgement, process redesign, or hiring; which 10× vector it targets
- **Workforce** — who performs the task now, how they feel about automation, who would resist; whether the goal is automation or augmentation; performance stakes, trust, and regulatory stringency
- **Systems and data** — which platforms hold the data; whether they expose APIs; read versus write access required; data quality and structure; latency constraints; data classification and residency, and whether only organisation-approved model providers may be used
- **Financials** — budget range, acceptable payback period, existing licence costs, token and compute expectations, and the currency to use (ask; do not assume)
- **Governance and risk** — applicable regulations (GDPR, sector rules, EU AI Act exposure); who would own the agent; existing approval thresholds; risk appetite; what must never be automated
- **Design intent** — desired success metric and threshold; scope in and out; candidate platform; single-agent or multi-agent; whether external content is ingested (which forces indirect-injection testing)

If the user explicitly says to estimate a value, construct a credible estimate and label it as an assumption in both deliverables. Never volunteer an estimate as a substitute for asking. If the conversation already contains an input, use it without re-asking.

### Step 2 — Run the analysis in framework order

Work through `references/frameworks.md` top to bottom, applying each framework to the idea and recording the result. Order matters — each output feeds the next:

1. AI adoption matrix → the chosen cluster and why the others are rejected
2. Feasibility–desirability matrix → quadrant placement with workforce reasoning
3. 7-point viability checklist → explicit score out of 7 with one-line evidence per criterion
4. Rule of ten → the targeted 10× vector, quantified
5. PROFIT → the structured case, including a do-nothing baseline and token/compute costs
6. Hidden costs → the items that will actually dominate spend
7. Build-versus-buy → recommendation with the two or three driving factors
8. Five-phase design → mandate and success metric; workflow map with HITL gates at exact thresholds; named systems and APIs with read/write levels; platform; governance design; MCP/A2A note
9. Risk vectors and attack vectors → filtered to those genuinely relevant (always include indirect instruction injection if the agent ingests external content)
10. Governance lifecycle and testing → register, scope, sandbox protocol matched to privilege, monitoring, kill switch, rollback

If a framework genuinely disqualifies the idea (viability below 4, red-zone placement, rule of ten clearly unreachable), tell the user before building and propose a reframed scope that passes. Restraint is part of a strong case, not a weakness.

### Step 3 — Write the markdown business plan

The primary deliverable. Structure it around the five core sections and answer every prompt at full depth:

```
# [Project name] — agentic AI business plan
## Executive summary
## Context and problem definition
## Strategic justification
## Financial rationale and value creation
## High-level system design
## Risk assessment and governance
## Implementation and ownership
## Appendix: framework worksheets
```

The appendix carries the full worksheets — the scored viability checklist, the PROFIT stage-by-stage analysis, the build-versus-buy factor table, the risk → control mapping, and the pre-deployment checklist with status per item. Use tables for parallel comparisons and the `**Term**: definition` pattern for definitions. Derive every figure from a single calculation block so changes cascade. State assumptions explicitly and show sensitivity at conservative and expected volumes.

### Step 4 — Build the deck

Follow `references/deck-structure.md` and `references/formatting.md` exactly: copy the template, delete any instruction slides last, fill the five section slides, add expansion slides by copying the section layout, and build the workflow diagram with native python-pptx shapes (never a raster image).

Non-negotiables:

- Every section of the plan represented somewhere in the deck
- Frameworks named visibly (slide labels, table headings)
- Workflow diagram with HITL gates showing exact thresholds (amounts, confidence scores)
- Risk → control mapping table including audit logging, kill switch, and sandbox protocol
- One restraint statement — something deliberately not automated or deferred
- 8–12 slides, short declarative bullets, numbers over adjectives, one currency throughout, British English, sentence-case headings
- Apply the formatting rules: suppress bullets explicitly, cap heading size, remove stale template instruction shapes, keep the single calculation block, and preserve any user edits to a supplied deck

### Step 5 — Audit and deliver

Audit both artefacts against `references/rubric.md` line by line. Check specifically:

- [ ] Alternatives critically appraised
- [ ] Token/compute and ongoing costs itemised; assumptions stated; ROI and payback present with a do-nothing baseline
- [ ] Named systems with access levels; exact HITL thresholds; workflow diagram present
- [ ] Instruction injection addressed; audit logging, kill switch, and sandbox protocol named
- [ ] Narrative thread: the design solves the stated problem, risks map to the design, financials price the design
- [ ] Restraint demonstrated; phased rollout; named owner

Fix every gap before presenting. Deliver both files with a short summary of the headline numbers (ROI, payback, viability score) and any assumptions the user should verify. If a governance plan or ongoing governance is also wanted, point the user to a companion governance skill (`agentic-governance`).

## Writing rules for all output — avoid common AI language, ticks, and style

These rules apply to everything generated for the user (the business plan, the deck, and any summary text). They override conflicting conventions in any other style guide, including oxford-markdown. The test: a reader should hear an analyst, not a language model.

Banned constructions:

- **Em-dashes** anywhere. Use commas, colons, parentheses, or restructure. Headings carry no separator punctuation; definitions use `**Term**: definition`
- **Contrastive negation** — "not X, but Y", "it's less about X than Y", "rather than X, this is Y". State the positive claim directly
- **Rhetorical triplets** deployed for cadence. Lists of three are fine when the content genuinely has three items
- **Significance inflation** — crucial, critical, robust, comprehensive, seamless, transformative, game-changing, cutting-edge, unlock, leverage (as a verb), delve, landscape, journey, empower
- **Copula avoidance** — "serves as", "stands as", "acts as", "functions as". Write "is"
- **Meta-signposting and hedged emphasis** — "It's worth noting", "Importantly", "In essence", "Notably", "Let's explore"
- **"Not only X but also Y"**

Write plain declarative sentences, concrete numbers, and verbs that name the actual action.

## Fallback markdown style (if no oxford-markdown skill present)

British English throughout. Oxford commas. Sentence case for all headings; `#` for the document title only, `##` for sections, `###` for subsections. Tables for parallel comparisons. `**Term**: definition` with no terminal full stop. Concise prose, no walls of text, no marketing inflation. No frontmatter on the generated business plan unless the user asks for it. All writing rules above apply.
