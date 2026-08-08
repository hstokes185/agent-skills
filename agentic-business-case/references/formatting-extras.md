# Formatting extras

Supplementary rules for the agentic business case builder, drawn from production experience building the Calero MDM Invoice Loader deck. These sit alongside `SKILL.md` and `deck-structure.md` and take precedence where they conflict.

## Currency

Default to USD throughout unless the user specifies otherwise. State the conversion rate and date whenever any original figure is denominated in a different currency (e.g. "£40k salary equivalent, converted at 1.3382 on 10 June 2026 = $53.5k"). Place the conversion note on the costs slide. Keep one currency across all slides — never mix symbols.

## Title card text colour

The template's title slide uses a dark navy background. Detect the background before setting text colour. Use white for the main title and subtitle. Use the template's amber accent for the value strapline. Never apply dark text to a dark background — the text becomes invisible in the rendered file.

## Bullet suppression

The template injects bullets on all left-column placeholders. The writing rules say no bullets, but suppression must be applied explicitly or the template overrides the content. Call `no_bullets()` on every `text_frame` written to, including all captions set via the template's placeholder shapes. The function must zero both the bullet mark and the hanging indent:

```python
def no_bullets(tf):
    for p in tf.paragraphs:
        pPr = p._p.get_or_add_pPr()
        for tag in ('a:buChar', 'a:buAutoNum', 'a:buNone'):
            for el in pPr.findall(qn(tag)):
                pPr.remove(el)
        pPr.append(pPr.makeelement(qn('a:buNone'), {}))
        pPr.set('marL', '0')
        pPr.set('indent', '0')
```

## Heading font size

Cap all section heading placeholders at 20pt bold. Do not allow the heading placeholder to auto-size upward — at larger sizes it overflows into the body area on content-heavy slides.

## Removing stale template shapes

Before writing content to any template slide, iterate over its existing shapes and remove any that carry placeholder instruction text. Shapes whose text begins with "Note:" or contains the template's original instructional prompts must be deleted before the slide is populated:

```python
for sh in list(slide.shapes):
    if sh.has_text_frame and sh.text_frame.text.strip().startswith("Note:"):
        sh._element.getparent().remove(sh._element)
```

## Caption prose style

Caption text in the left-hand column must read as continuous prose. Do not write label-colon fragments. "Amber: the human gate. Every invoice passes through it." is the failure mode — write what is happening in plain sentences instead: "Every invoice passes through the amber human review gate before anything is staged."

## Derived figures: single calculation block

Define all derived figures in one calculation block at the start of the build script. Never place raw arithmetic inline across multiple slides. Every figure that appears in the deck should reference that block. When a source figure changes (e.g. daily token cost), the cascade — annual ceiling, year 1 net benefit, payback period, unit cost reduction multiple — updates automatically.

```python
# Example calculation block
DAILY_BENEFIT = 80          # $ operator saving per day
DAYS = 252
BUILD_COST = 500            # $ one-off
DAILY_TOKEN = 5             # $ per day ceiling
ANNUAL_BENEFIT = DAILY_BENEFIT * DAYS           # 20,160
ANNUAL_TOKEN = DAILY_TOKEN * DAYS               # 1,260
NET_Y1 = ANNUAL_BENEFIT - ANNUAL_TOKEN - BUILD_COST  # 18,400
NET_DAILY = ANNUAL_BENEFIT / DAYS - DAILY_TOKEN  # 74.84, round to 75
PAYBACK_DAYS = round(BUILD_COST / NET_DAILY)    # 7
UNIT_BEFORE = DAILY_BENEFIT / 12               # 6.67
UNIT_AFTER = DAILY_TOKEN / 12                  # 0.42
MULTIPLIER = round(UNIT_BEFORE / UNIT_AFTER)   # 16
```

## Preserving user edits

If the user supplies an edited version of the deck, extract all their text first and treat it as canonical. Apply only the specific changes requested. Do not touch surrounding wording. Use `run_replace()` for targeted string substitutions and `rewrite_box()` only for boxes that must be fully replaced. Preserve the user's phrasing, column headings, parentheticals, and any factual additions they have made.
