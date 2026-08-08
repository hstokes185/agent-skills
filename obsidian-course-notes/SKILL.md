---
name: obsidian-course-notes
description: >-
  Converts raw course transcripts, lecture summaries, slide text, and code
  walkthrough screenshots into clean, structured Obsidian Markdown notes ready
  to drop into a vault. Use when formatting course content, lecture notes, video
  transcripts, or educational material for Obsidian. Trigger keywords: course
  notes, lecture notes, transcript, lesson notes, walkthrough notes, learning
  notes, educational content, course formatting, video course.
metadata:
  scope: professional
---
# Obsidian Course Notes

Convert video course content (transcripts, slide text, screenshots of code walkthroughs) into well-structured Obsidian Markdown files. Notes should be concise, scannable, and useful for revision.

> **Apply `obsidian-formatting` conventions** for all formatting decisions (headers, callouts, code blocks, text style, emdashes, file naming, etc.).
> If that skill is not loaded, read `references/obsidian-formatting.md` first.

## Document Structure Patterns

Choose the pattern that matches the input type.

### Standard Lecture Note

````markdown
## Lesson Title

> [!info] Learning Objectives (estimated time)
> - Objective one
> - Objective two

Introductory paragraph explaining the topic.

### Section One
Content...

### Section Two
Content with table, code blocks, etc.

### Key Takeaways
- **Takeaway label** — description
- **Another takeaway** — description

---

### Exercises — Exercise Title (time estimate)
Exercise instructions...

### Reflection
> [!tip] Before Moving On
> - Reflection question one
> - Reflection question two
````

### Code Walkthrough

When the user provides screenshots of a step-by-step code walkthrough, return only the highlighted code from each step with brief context:

````markdown
## Walkthrough Title

### Step 1 — Step Name
Brief description of what this step does.
> `filename.py`
```python
# only the highlighted code from the screenshot
```

### Step 2 — Step Name
Brief description...
> `filename.py`
```python
# highlighted code
```
````

### Course Introduction / About Section

````markdown
## Course Title

### About This Course
Summary paragraph...
Key topics or skills covered as bullet list or table.

> [!abstract] By the End of This Course
> Summary of what you'll be able to do.
````

## Content Rules

### What to Include
- All conceptual explanations from the transcript.
- All code examples (properly tagged).
- All key takeaways.
- All exercises with full instructions.
- All reflection questions (in callouts).
- Tables where comparisons exist.
- Callouts for important warnings, tips, and notes.

### What to Transform
- Colons in definition patterns → emdashes.
- American spelling → British English.
- Inline bullet lists → tables (when 2+ attributes per item).
- Vague formatting → specific code language tags.
- Wall-of-text instructions → numbered steps.

### What NOT to Do
- Don't add content that isn't in the source material.
- Don't skip exercises or reflection sections.
