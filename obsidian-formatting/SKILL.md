---
name: obsidian-formatting
description: >-
  Formats text, notes, and documents into clean, consistent Obsidian-compatible
  Markdown. Apply this skill when writing or converting any content for an
  Obsidian vault. Trigger keywords: Obsidian, markdown formatting, vault notes,
  callouts, obsidian syntax, format notes, obsidian markdown, emdash, British
  English, code block tagging.
---
# Obsidian Formatting

Apply these conventions when writing or converting any content for an Obsidian vault.

## Headers

- All headers start at level 2 (`##`) — never use `#` (H1). Obsidian uses the filename as H1.
- Use `###` for subsections, `####` for sub-subsections.
- Use emdashes (—) instead of colons in header-style definitions where natural.

## Text Style

- Use emdashes (—) instead of colons for definitions and label-value pairs throughout.
- Use italics for example user prompts or quoted speech.
- Use inline code for commands, file paths, function names, class names, parameters, and tool names.
- Use bold for key terms on first introduction and for list item labels.
- British English spelling (organise, colour, behaviour, etc.).

## Lists

- Use bold label + emdash pattern for definition-style lists:
  - **Label** — Description text here
- Use numbered lists only for sequential/ordered workflows.
- Use bullet points for unordered collections.

## Tables

Use tables for:
- Comparisons between features, tools, or options.
- Quick-reference summaries (e.g., metadata fields, message types, method signatures).
- Side-by-side pairs (e.g., request → result, pros vs cons).
- Any content with 2+ attributes per item that benefits from column alignment.

## Code Blocks

- Always tag with language — `python`, `javascript`, `typescript`, `yaml`, `json`, `bash`.
- For YAML frontmatter examples, use the `yaml` tag.
- For terminal commands, use the `bash` tag.
- When showing which file a code block comes from, use a blockquote label above it:

> `server.py`
```python
# code here
```

## Callouts

Use Obsidian callout syntax. Choose the type based on content:

| Callout | Use For |
|---|---|
| `[!info]` | Learning objectives at the top of a lesson |
| `[!note]` | General supplementary information |
| `[!tip]` | Helpful advice, reflection prompts, exercise guidance |
| `[!important]` | Key points that are easy to miss or carry forward |
| `[!warning]` | Cautions, gotchas, deprecation notices |
| `[!abstract]` | Key takeaways, summaries, TLDRs |
| `[!example]` | Worked examples, sample answers |
| `[!question]` | Questions for reflection |

Callouts can have custom titles:
> [!tip] Before Moving On

Multi-line callouts — every line must start with `>`:
> [!tip] Custom Title
> First line of content
> - Bullet inside callout
> - Another bullet

## Horizontal Rules

Use `---` to separate major sections (e.g., between distinct topics, before exercises).

## File Naming

- All lowercase, hyphens between words.
- Match the note title — `creating-your-first-skill.md`, `the-stdio-transport.md`.

## What NOT to Do

- Don't use H1 headers.
- Don't use emojis (exception — ✅/❌ in comparison tables for supported/unsupported features).
- Don't leave code blocks untagged.
- Don't use colons where an emdash fits naturally.

## Example Transformations

**Input — Definition list with colons**
```
Context window: The amount of text a model can work with
Emergent capabilities: Abilities that arise from scale
```

**Output — Bold label + emdash**
- **Context window** — The amount of text a model can work with in a single interaction
- **Emergent capabilities** — Abilities that arise from scale that weren't explicitly programmed

---

**Input — Feature comparison as prose**
```
CLAUDE.md loads into every conversation. Skills load on demand. Slash commands require explicit typing.
```

**Output — Table**
| Mechanism | When It Loads | Use Case |
|---|---|---|
| **CLAUDE.md** | Every conversation | Always-on project standards |
| **Skills** | On demand, when matched | Task-specific knowledge |
| **Slash commands** | Explicit invocation | Manual workflow triggers |

---

**Input — Important caveat buried in paragraph**
```
The MCP SDK doesn't automatically enforce root restrictions. You need to implement this yourself.
```

**Output — Callout**
> [!important]
> The MCP SDK doesn't automatically enforce root restrictions — you need to implement this yourself.
