# Obsidian Formatting Rules

## Headers
- All headers start at level 2 (`##`) — never use `#` (H1). Obsidian uses the filename as H1.
- Use `###` for subsections, `####` for sub-subsections.

## Text Style
- Use emdashes (—) instead of colons for definitions and label-value pairs.
- Use italics for example user prompts or quoted speech.
- Use inline code for commands, file paths, function names, class names, parameters, and tool names.
- Use bold for key terms on first introduction and for list item labels.
- British English spelling (organise, colour, behaviour, etc.).

## Lists
- Bold label + emdash pattern for definition-style lists — **Label** — Description
- Numbered lists for sequential workflows only.
- Bullet points for unordered collections.

## Tables
Use tables for comparisons, quick-reference summaries, side-by-side pairs, or any content with 2+ attributes per item.

## Code Blocks
- Always tag with language — `python`, `javascript`, `typescript`, `yaml`, `json`, `bash`.
- Use a blockquote label above the block to indicate the source file:
> `filename.py`
```python
# code here
```

## Callouts

| Callout | Use For |
|---|---|
| `[!info]` | Learning objectives |
| `[!note]` | Supplementary information |
| `[!tip]` | Advice, reflection prompts |
| `[!important]` | Key points easy to miss |
| `[!warning]` | Cautions, gotchas |
| `[!abstract]` | Takeaways, TLDRs |
| `[!example]` | Worked examples |
| `[!question]` | Reflection questions |

Multi-line callouts — every line must start with `>`:
> [!tip] Custom Title
> Line one
> - Bullet inside callout

## What NOT to Do
- Don't use H1 headers.
- Don't use emojis (exception — ✅/❌ in comparison tables).
- Don't leave code blocks untagged.
- Don't use colons where an emdash fits naturally.

## File Naming
All lowercase, hyphens between words, match the note title — `lesson-one-intro.md`.
