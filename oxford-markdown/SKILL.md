---
name: oxford-markdown
description: Use when writing or polishing any Markdown. Formats it in clean, professional Oxford-style British English — em-dashes, Oxford commas, sentence-case headings from H2, and consistent list, table, code-block, and frontmatter conventions. Use this skill whenever creating, editing, or polishing any Markdown — notes, documentation, READMEs, reports, technical writing, or any `.md` file — and whenever the user asks for clean, professional, or British-style prose, even if 'Oxford' is not mentioned by name.
metadata:
  scope: professional
---

# Oxford Markdown

A house style for Markdown that is clean, professional, and unambiguous. Built on British English conventions with em-dashes as the workhorse punctuation mark, Oxford commas in lists, and a small set of structural patterns that keep documents scannable.

## Core principles

- **Clarity first** — every formatting choice serves readability. If a rule and clarity conflict, clarity wins
- **Restraint** — if the same idea reads cleanly in fewer words, cut. Style guides exist to ensure uniformity, not to add ornament
- **Consistency** — pick a convention and hold to it across the entire document
- **British English throughout** — spelling, punctuation, and conventions all align

## British English

- **Spelling** — `organise`, `colour`, `behaviour`, `centre`, `analyse`, `recognise`, `licence` (noun) / `license` (verb), `programme` (general) / `program` (computing only)
- **Quotation marks** — single quotes for primary quotation, double for nested: `'She said "yes" without hesitation'`
- **Punctuation inside quotes** — full stops and commas sit *outside* the closing quote when not part of the original quoted material (logical quotation)
- **Dates** — `14 May 2026`, not `May 14, 2026`. No ordinal suffixes (`14 May`, not `14th May`)
- **Numbers** — spell out one to ten in prose; numerals from 11 upward; always numerals with units (`5 km`, `3 GB`, `12 °C`)

## Em-dashes

The em-dash (`—`) is the workhorse punctuation mark of this style. Use it:

- **For parenthetical asides** — like this one — without spaces around the dashes (Oxford style, closed up)
- **For definitions and label-value pairs** — `Term — meaning of the term`
- **In place of colons** where the relationship is descriptive rather than introductory
- **To mark a sharp turn in thought** — the kind of break that a comma is too soft to carry

Never substitute a hyphen (`-`) or en-dash (`–`) for an em-dash. Each mark has its own role:

| Mark | Character | Use |
|---|---|---|
| Hyphen | `-` | Compound words — `well-known`, `state-of-the-art`, `high-protein` |
| En-dash | `–` | Numeric and date ranges — `pages 12–18`, `2024–2026` |
| Em-dash | `—` | Parenthetical breaks, definitions, sharp turns of thought |

**Keyboard shortcuts** — `Alt + 0151` on Windows (numpad), `Option + Shift + Hyphen` on macOS.

## Oxford comma

Always use the serial comma before the final item in a list of three or more.

- Correct — `The framework covers governance, risk, and compliance.`
- Incorrect — `The framework covers governance, risk and compliance.`

The Oxford comma resolves ambiguity in lists where the final item could otherwise be misread as an appositive of the preceding one.

## Headers

- ATX style only — use `#` characters, never the underline (`===` / `---`) form
- **Start at H2** (`##`). The document's title is supplied by the filename, frontmatter, or surrounding renderer — do not duplicate it in the body as an H1
- Never skip levels — H2 → H3 → H4, not H2 → H4
- **Sentence case** — capitalise only the first word and any proper nouns. Not Title Case
- Blank line before and after each header
- No trailing punctuation except `?` for genuine questions

## Lists

- **Unordered marker** — use `-` (hyphen) consistently. Do not mix `*` or `+`
- **Ordered lists** — only for content that is genuinely sequential (steps, ranked items). If the order does not matter, use bullets
- **Indentation** — two spaces per nesting level
- **Sentence-case items** — first word capitalised, no terminal full stop unless the item is itself a full sentence (and then apply consistently across the list)
- **Definition pattern** — `**Bold label** — explanation` is the preferred form for definition-style lists. The em-dash separates the term from its meaning

## Tables

Reach for a table when content has two or more attributes per item that benefit from column alignment — comparisons, parameter references, field summaries, side-by-side options.

- Header row required, separated by a divider row of `|---|---|`
- Sentence case in header cells
- Align columns in the source where doing so does not bloat line length
- Keep cell content short — if a cell needs more than a sentence, prefer prose

## Code blocks

- Fence with triple backticks and always tag the language — `python`, `bash`, `yaml`, `json`, `typescript`, `markdown`, `sql`
- For terminal commands, use `bash`
- For YAML frontmatter, use `yaml`
- **File label pattern** — when a code block belongs to a specific file, name the file on its own line directly above the block, as bold inline code. Never wrap the label and block in a blockquote (the `>` method) — it fails to render. Indentation *inside* the code block is fine; it is the leading `>` on each line that breaks:

**`src/auth/jwt.py`**

```python
def verify_token(token: str) -> dict:
    return jwt.decode(token, SECRET, algorithms=['HS256'])
```

- **Inline code** (single backticks) — for commands, file paths, function names, parameter names, environment variables, tool names, and short literals

## Emphasis

- **Bold** — for the first introduction of a key term, and for labels in definition lists. Do not bold entire paragraphs
- *Italic* — for emphasis in running prose, example user prompts, quoted speech, and the titles of works
- Avoid combining bold and italic in the same span — pick one
- Asterisks are the default marker for both bold (`**`) and italic (`*`). Underscore form is acceptable, but be consistent within a document

## YAML frontmatter

Every Markdown file written for an Obsidian vault **must** open with frontmatter — Obsidian reads it as the note's Properties. Place it at the very top, fenced by `---` on its own lines, before any content:

```yaml
---
title: Document title
aliases:
  - Alternative name
created: 2026-05-14
updated: 2026-05-14
tags:
  - finance
  - governance/compliance
source:
---
```

**Obsidian-specific rules** — these keys have special meaning to Obsidian and must follow its conventions:

- **`tags`** — a YAML list, lowercase, hyphenated. No `#` prefix in frontmatter (the `#` form is only for inline tags). No spaces inside a tag — use `-` within a word and `/` for nesting (`governance/compliance`)
- **`aliases`** — a YAML list of alternative titles; Obsidian resolves `[[wiki-links]]` against these as well as the filename
- **`cssclasses`** — a YAML list, only when a note needs specific styling; omit otherwise
- **`created` / `updated`** — ISO dates (`YYYY-MM-DD`). Obsidian renders these as date properties
- **Quote text values containing YAML-special characters** — wrap any value that contains a colon, `#`, `[`, `]`, `{`, `}`, `,`, or a leading `>`, `|`, `*`, `&`, `!`, `%`, `@`, or backtick in double quotes (`title: "Stoicism: a primer"`). An unquoted colon-plus-space is the most common cause of a silently broken Properties block — when in doubt, quote
- **Wiki-links in frontmatter must be quoted** — `source: "[[Source note]]"`, never bare `[[...]]`, which breaks YAML parsing
- **Empty values are valid** — leave a key with no value (`source:`) rather than deleting it, so the property still appears in Obsidian's Properties panel

Standard ISO date format (`YYYY-MM-DD`) throughout. Keep keys lowercase. Do not invent keys beyond what the note genuinely needs.

## Horizontal rules

Use `---` on its own line to separate major sections — for example, between body content and exercises, or between distinct topics in a long document. Surround with blank lines above and below. Never stack horizontal rules; a single break is enough.

## Links and images

- **Link text** — descriptive and meaningful. Never `click here`, `read more`, or bare URLs in running prose
- **Reference-style links** — use for URLs that repeat across the document
- **Internal links** — Markdown anchor syntax `[text](#anchor)` for portable cross-document linking; wiki-links (`[[Note title]]`) for linking between notes in a connected vault
- **Images** — always provide meaningful alt text. Decorative-only images are rare in technical writing

## Final polish

Before considering a document finished, sweep for:

- No trailing whitespace on any line
- Single blank line between paragraphs and sections — never two or more
- File ends with exactly one newline
- Every code block has a language tag
- All em-dashes are em-dashes (`—`), not hyphens (`-`) or en-dashes (`–`)
- All links have descriptive text
- British spelling consistent throughout (mental check for `-ize`, `color`, `behavior`, `analyze` — none should appear)
- Oxford comma applied in every three-or-more-item list

---

## Worked example

**Request** — write a short note explaining what a JSON Web Token is.

**Output**:

```markdown
---
title: JSON Web Tokens
aliases:
  - JWT
created: 2026-05-14
updated: 2026-05-14
tags:
  - security/authentication
source:
---

## JSON Web Tokens

A **JSON Web Token** (JWT) — a compact, URL-safe means of representing claims passed between two parties. JWTs are signed, optionally encrypted, and self-contained, which makes them well-suited to stateless authentication across services.

### Structure

A JWT has three parts separated by full stops:

- **Header** — algorithm and token type
- **Payload** — the claims (subject, scopes, expiry)
- **Signature** — verifies the token has not been tampered with

### When to reach for one

| Use case | Suitable? |
|---|---|
| Stateless API authentication | Yes |
| Storing sensitive personal data in the payload | No — payloads are base64-encoded, not encrypted |
| Single sign-on across services | Yes |

### A note on secrets

Never put secrets in a JWT payload — anyone holding the token can decode it.
```

Notice — Obsidian frontmatter with `tags` as a hyphenated list and an empty `source:` key, H2 entry point (the title lives in frontmatter, not an H1), em-dashes throughout, Oxford comma in `signed, optionally encrypted, and self-contained`, British spelling (`well-suited`, `tampered`), bold-on-first-use for the term **JSON Web Token**, and the bold-label-em-dash definition pattern in the Structure list.
