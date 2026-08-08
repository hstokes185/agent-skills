# Deck structure — slide blueprint and diagram guidance

## The template

`assets/Generative_and_Agentic_AI_Assessment_Template.pptx` — 16:9 (13.33in × 7.5in), 7 slides:

| Slide | Content | Action |
|---|---|---|
| 1 | Title | Replace placeholder with project title, organisation, author, date |
| 2 | "How to use this template" instructions | **Delete this slide** in the final deck |
| 3 | Context & problem definition prompts | Replace prompt text with answers |
| 4 | Strategic justification prompts | Replace prompt text with answers |
| 5 | Financial rationale prompts | Replace prompt text with answers |
| 6 | High-level system design prompts | Replace prompt text with answers |
| 7 | Risk assessment & governance prompts | Replace prompt text with answers |

Target 8–12 slides, so each of the five sections typically expands to two slides. Build new slides by copying the section-slide layout ("Picture with Caption" layout in the template) so fonts and styling stay consistent. Keep the template's heading placeholder for section titles.

Delete the instructions slide safely, and delete it LAST. Add every new slide first, then delete, then reorder. python-pptx names new slide parts by current slide count, so adding after a deletion reuses the deleted part name and corrupts the saved file with duplicate parts. Removal needs both the ID entry and the relationship:

```python
def delete_slide(prs, index):
    rId = prs.slides._sldIdLst[index].rId
    prs.part.drop_rel(rId)
    del prs.slides._sldIdLst[index]

# 1. fill template slides  2. add all new slides  3. delete_slide(prs, 1)  4. reorder _sldIdLst
```

Reorder by collecting the sldId elements, removing them all, and re-appending in target order. Verify the saved file reopens with python-pptx and emits no duplicate-name warnings before delivering.

## Target structure (10–11 slides)

1. **Title** — project name, organisation, strapline stating the core value claim
2. **Context & problem definition** — the organisation, the bottleneck (quantified), affected workflows/data streams, stakeholders and how their roles change
3. **Strategic justification I — why agentic** — AI adoption matrix position (visual), rejected alternatives (other clusters + non-AI), rule-of-ten claim
4. **Strategic justification II — viability and workforce** — 7-point viability checklist scored (table/checkmarks), feasibility–desirability quadrant placement, workforce trust/desirability evidence, known limitations
5. **Financial rationale I — value creation** — benefit vectors with figures (savings, efficiency, risk reduction), PROFIT-stage labels
6. **Financial rationale II — costs, ROI, payback** — upfront vs ongoing table (include token/compute, data preparation, governance, maintenance), ROI and payback period, do-nothing baseline, stated assumptions
7. **System design I — mandate and architecture** — operational mandate, measurable success criterion, in/out of scope, named systems and APIs with read/write levels, build-vs-buy recommendation, MCP/A2A architecture note
8. **System design II — workflow diagram** — the full end-to-end diagram (see below); HITL thresholds called out with exact values
9. **Risk assessment** — risk register: six governance vectors filtered to those relevant, plus instruction injection; likelihood/impact if useful
10. **Governance & mitigations** — risk → control mapping table; governance lifecycle (register, scope, sandbox testing protocol, monitoring, kill switch + rollback); named owner and HITL accountability
11. **Deployment & restraint** (optional but strong) — phased rollout, what is deliberately not automated, pre-deployment checklist status

Slides 2–3 of any pair can be merged if content is tight; never exceed 12.

## Writing style on slides

- Short declarative statements, 3 to 6 bullets per slide, each one line where possible
- Numbers over adjectives ("$140k/yr analyst time" not "significant cost")
- Frameworks named in slide headings or labels so reviewers see them applied
- Single currency throughout (USD unless the user specifies otherwise)
- British English, sentence case headings
- The writing rules in SKILL.md apply in full: no em-dashes, no contrastive negation, no significance inflation, no rhetorical triplets, no "serves as". Slide titles carry no separator punctuation

## Building the workflow diagram (slide 8)

Build it with native python-pptx shapes so it is editable — do not paste a raster image.

Layout pattern (left to right):

1. **Trigger** (rounded rectangle, left edge) — the event that wakes the agent
2. **Processing nodes** (rectangles) — each major step
3. **Decision diamonds** — each decision point, with labelled Yes/No connectors
4. **Iteration loop** (connector arcing back) — where the agent requests missing information
5. **HITL gate** (distinct colour, e.g. amber) — escalation with the exact threshold printed in the shape ("> $1,000 → human approval")
6. **External systems** (cylinders or rectangles in a second row below) — databases/APIs touched, dashed connectors to the steps that use them, labelled R or R/W
7. **Outputs** (rounded rectangle, right edge) — final systemic action and confirmation

python-pptx essentials:

```python
from pptx.util import Inches, Pt, Emu
from pptx.enum.shapes import MSO_SHAPE, MSO_CONNECTOR
from pptx.dml.color import RGBColor

shape = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(0.4), Inches(2.0), Inches(1.6), Inches(0.8))
shape.text_frame.text = "Trigger:\nemail received"
shape.text_frame.word_wrap = True
for p in shape.text_frame.paragraphs:
    p.font.size = Pt(10)

conn = slide.shapes.add_connector(MSO_CONNECTOR.STRAIGHT, Inches(2.0), Inches(2.4), Inches(2.5), Inches(2.4))
conn.line.width = Pt(1.5)

# Decision diamond
d = slide.shapes.add_shape(MSO_SHAPE.DIAMOND, Inches(2.5), Inches(1.9), Inches(1.3), Inches(1.0))

# HITL gate styling
g = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(7.0), Inches(0.6), Inches(2.0), Inches(0.9))
g.fill.solid(); g.fill.fore_color.rgb = RGBColor(0xF5, 0xA6, 0x23)
```

Plan coordinates on paper first: usable canvas is roughly x 0.4–12.9in, y 1.4–7.1in below the heading. Keep 5–8 main-row shapes maximum; if the workflow has more steps, group sub-steps into one node and detail them in the markdown document instead. Label every connector that leaves a diamond.

## Matrix and checklist visuals (slides 3–4)

- **AI adoption matrix**: 2×2 of rectangles with quadrant labels; a star or highlighted cell marking the proposal's position
- **Viability checklist**: a 7-row table, criterion | ✓/✗ | one-line evidence. Use `slide.shapes.add_table`
- **Feasibility–desirability**: a 2×2 with green/red/amber fills and the use case plotted as a labelled dot

These can be small (half-slide) — pair each with the prose bullets answering the section's questions.

## Risk → control mapping (slide 10)

A two-column table scores strongly against criterion 4:

| Risk (named vector) | Control (named mechanism) |
|---|---|
| Indirect instruction injection via ingested emails | Input sanitisation + perception-layer injection testing in sandbox |
| Errors at scale (machine-speed propagation) | Rate limiting + boundary violation monitoring + kill switch |
| Accountability gap | Central agent register, named owner, immutable audit logging |

Always include: audit logging, kill switch + rollback plan, sandbox protocol matched to privilege level, and the AI-disclosure transparency obligation.
