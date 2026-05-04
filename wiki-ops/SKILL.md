---
name: wiki-ops
description: >-
  Operates the LLM wiki in the Obsidian vault at database/. Use for three
  workflows: ingest (process a raw/ file into wiki/ pages with cascading
  updates), lint (health-check the wiki for orphans, contradictions, and stale
  pages), and query-file-back (answer a question and permanently file the
  synthesis back into wiki/). Trigger keywords: ingest, lint, wiki health,
  file back, wiki query, update wiki, process notes, knowledge base, add to wiki.
---
# Wiki Ops

Operate the three core workflows of the LLM wiki. Always read `wiki/index.md` and `CLAUDE.md` before beginning any workflow.

## Workflow 1 — Ingest

Use when: the user says `ingest [filename]` or asks to process a file from `raw/`.

1. Read the source file from `raw/`
2. Classify its type using the Document Classification table in `CLAUDE.md`
3. Write a summary page to `wiki/sources/[slug].md` using the mandatory frontmatter schema
4. Identify 10–15 related concept or entity pages — update each one with new content, revised confidence scores, and cross-links
5. Add `[[wikilinks]]` throughout all affected pages; include red links for concepts that need their own pages
6. Apply `obsidian-formatting` conventions to all pages written or updated
7. Append to `wiki/log.md`:
   ```
   YYYY-MM-DD HH:MM — INGEST — [filename] — [n pages created/updated]
   ```
8. Update `wiki/index.md` with any new pages created

If the source file is large (> 500 lines), process it in sections rather than all at once.

## Workflow 2 — Lint

Use when: the user says `lint` or asks for a wiki health check.

Scan the entire `wiki/` directory for:

- **Contradictions** — claims that conflict across pages; flag with `[!contradiction]` callouts
- **Orphan pages** — pages with no inbound `[[wikilinks]]` from other wiki pages
- **Stale claims** — pages not updated in 30+ days that reference fast-moving topics (AI tooling, market data, certification timelines)
- **Concept candidates** — terms recurring across 3+ pages that lack a dedicated page
- **Red link clusters** — wikilinks pointing to non-existent pages that appear frequently enough to warrant creation

Produce a health report in this format:

```
## Wiki Health Report — YYYY-MM-DD

### Contradictions (n)
- [page]: [description of conflict]

### Orphan Pages (n)
- [path]

### Stale Claims (n)
- [page]: [claim] — last updated [date]

### Concept Candidates (n)
- [[term]] — appears in: [page1], [page2], [page3]

### Recommended Actions
1. ...
```

Offer to fix each category. Log: `YYYY-MM-DD HH:MM — LINT — [n issues found]`

## Workflow 3 — Query + File-Back

Use when: the user asks a question about content in the wiki or raw/.

1. Read `wiki/index.md` to identify the most relevant pages
2. Pull those pages and synthesise an answer
3. Deliver the answer to the user
4. Evaluate: does this synthesis produce a new insight, comparison, or analysis that would be valuable to a future session?
   - If yes — write it as a permanent wiki page in the appropriate subdirectory (`concepts/`, `comparisons/`, etc.)
   - If no — stop after answering
5. Log: `YYYY-MM-DD HH:MM — QUERY — [topic] — [new page filed: Y/N]`

## Formatting

Apply `obsidian-formatting` conventions to all content written. Every wiki page must have:
- Mandatory YAML frontmatter (title, type, tags, source_links, confidence, created, updated)
- 2–3 sentence TLDR immediately after frontmatter
- Counter-arguments and Data Gaps section
- Related section with wikilinks
