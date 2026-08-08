---
name: okf-authoring
description: >-
  Use when writing or checking anything in the Open Knowledge Format — OKF
  bundles, concept documents, index.md or log.md files, converting an existing
  note collection, or checking whether frontmatter conforms. OKF is the
  vendor-neutral Markdown specification for giving AI agents curated context.
  Covers required and reserved fields, bundle structure, and the rules
  producers and consumers must follow.
metadata:
  scope: professional
---

# OKF authoring

Open Knowledge Format v0.2, published by Google Cloud (June 2026). A bundle is a directory of Markdown files with YAML frontmatter, readable by humans and consumable by agents without translation.

## The one rule people get wrong

**`type` is the only always-required field.** A concept document carrying nothing but `type` is fully conformant.

Everything else — `title`, `description`, `resource`, `tags` — is *recommended*, not required. Any stricter schema is a house standard, and should be described as such rather than presented as conformance.

## Concept documents

Every `.md` file in a bundle is a concept document **unless it is named `index.md` or `log.md`**.

```yaml
---
type: concept
title: Retrieval-augmented generation
description: Retrieving documents at query time to ground a model's answer.
resource: https://example.com/papers/rag
tags:
  - retrieval
  - grounding
---
```

| Field | Status | Meaning |
|---|---|---|
| `type` | **Required**, non-empty | What kind of thing this is |
| `title` | Recommended | Human-readable display name |
| `description` | Recommended | Single-sentence summary |
| `resource` | Recommended | URI identifying the underlying asset |
| `tags` | Recommended | YAML list for categorisation |

Optional field families: **provenance** (`sources`, `usage_window`), **trust** (`generated`, `verified`), **lifecycle** (`status`, `stale_after`), and **computation** — `runtime`, `parameters`, `computation`, `executor`, `attester` — which apply only to the Attested Computation type.

**Producers may add arbitrary keys. Consumers must preserve and tolerate unknown fields.** So a bundle can carry an existing vault's own conventions alongside the reserved names without breaking conformance.

## `type` is free-form

The specification is explicit: type values are **not registered centrally**. Producers *should* pick values that are descriptive and self-explanatory; consumers **must** tolerate unknown types gracefully.

There is no enum. Do not invent one and present it as the standard — and be wary of tooling that validates against a fixed list, because that list is somebody's opinion rather than the spec.

Consistency still has value: a vocabulary applied consistently is what makes the field worth querying. That is a choice a producer makes, not a rule the format imposes.

## `index.md` and `log.md`

Neither is a concept document, and **neither carries frontmatter**.

**`index.md`** — the entry point, giving progressive disclosure of a directory's contents. Body is sections of links with short descriptions. The **bundle-root** `index.md` may carry one optional key:

```yaml
---
okf_version: "0.2"
---
```

**`log.md`** — change history. No frontmatter. Date-grouped entries in ISO 8601 `YYYY-MM-DD` order, with prose describing what changed.

```markdown
## 2026-08-08

Added twelve concepts on retrieval. Retired the deprecated chunking note.
```

Adding a schema block to either file is the most common conversion error.

## Bundle structure

- A bundle is a directory (the "root") containing Markdown files
- Directory hierarchy is **producer-defined** — the format imposes none
- `references/` is a naming convention for external material, not a requirement
- Declare a target version with `okf_version: "0.2"` in the bundle-root `index.md`

## Converting an existing note collection

1. Add `type` to every note that lacks it. This alone brings the collection to conformance
2. **Strip frontmatter from any `index.md` or `log.md`** — these are structural files
3. Map existing keys to reserved names where they mean the same thing, or keep your own and let consumers ignore them. `source` → `resource` and `created`/`updated` → lifecycle fields are common mappings
4. Add a bundle-root `index.md` if there is no entry point
5. Leave the rest alone. Conformance does not require a full schema on every note

Do not bulk-apply one `type` value across a whole collection to clear a checker. A field whose value is identical almost everywhere carries no information and costs whatever it took to write.

## Validating

Check in this order — the first is the only hard requirement:

- Every concept document has a non-empty `type`
- No `index.md` or `log.md` carries frontmatter, except optional `okf_version` at the bundle root
- Frontmatter parses as YAML. Quote any value containing a colon followed by a space, which is the most common silent breakage
- Reserved keys are used with their spec meanings rather than repurposed

Anything beyond this is a house rule. Say which is which when reporting, so a producer can tell a conformance failure from a preference.

## Sources

- [OKF v0.2 specification](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md)
- [Google Cloud — how the Open Knowledge Format can improve data sharing](https://cloud.google.com/blog/products/data-analytics/how-the-open-knowledge-format-can-improve-data-sharing)
