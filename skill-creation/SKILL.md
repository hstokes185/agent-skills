---
name: skill-creation
description: Guide for authoring well-structured Agent Skills that follow the Agent Skills specification. Use this skill whenever someone wants to create, write, or scaffold a new agent skill, write a SKILL.md file, set up a skill directory structure, validate frontmatter fields, or understand best practices for skill design. Also trigger when the user mentions "agent skill", "SKILL.md", "skill spec", "skill format", or asks how to package instructions for an AI agent.
license: Apache-2.0
metadata:
  author: community
  version: "1.0"
  spec-version: "1.0"
---
# Skill Creation

Create Agent Skills that are well-structured, easy for agents to consume, and follow the Agent Skills specification.

## What is an Agent Skill?

An Agent Skill is a directory containing a `SKILL.md` file (and optionally supporting resources) that teaches an AI agent how to perform a specific task. The agent loads the skill's metadata at startup, reads the full instructions when the skill is activated, and pulls in additional resources only as needed.

## Directory Structure

Every skill starts as a directory whose name matches the `name` field in the frontmatter:

```
skill-name/
├── SKILL.md              # Required — frontmatter + instructions
├── scripts/              # Optional — executable code the agent can run
├── references/           # Optional — additional docs loaded on demand
└── assets/               # Optional — templates, images, data files
```

The only required file is `SKILL.md`. Add subdirectories only when they serve a clear purpose.

## Step-by-Step: Writing a New Skill

### 1. Define the scope

Before writing anything, answer these questions:

- **What task does this skill perform?** Be specific. "Process PDFs" is vague; "Extract text and tables from PDFs, fill PDF forms, and merge multiple PDFs" is actionable.
- **When should an agent activate this skill?** Think about the phrases, keywords, and contexts a user might mention.
- **What does success look like?** Describe the expected outputs or behaviors.

A skill should do one thing well. If you find yourself describing two unrelated capabilities, consider splitting into two skills.

### 2. Write the frontmatter

The YAML frontmatter block is the skill's identity. It sits at the top of `SKILL.md` between `---` fences.

#### Required fields

```yaml
---
name: my-skill-name
description: >-
  A clear description of what this skill does and when to use it.
  Include specific trigger keywords and contexts.
---
```

**`name`** — The skill's identifier.

- 1–64 characters, lowercase alphanumeric and hyphens only (`a-z`, `0-9`, `-`)
- Cannot start or end with a hyphen
- No consecutive hyphens (`--`)
- Must match the parent directory name exactly

Examples of valid names: `pdf-processing`, `code-review`, `data-analysis`

**`description`** — The primary trigger mechanism. Agents read this to decide whether to activate the skill. Up to 1024 characters.

Write the description as if you're answering two questions in one paragraph: "What does this skill do?" and "When should the agent use it?" Include specific keywords that a user might say. Err on the side of being slightly broad — agents tend to under-trigger rather than over-trigger.

Good:
```yaml
description: >-
  Extract text and tables from PDF files, fill PDF forms, and merge
  multiple PDFs. Use when working with PDF documents or when the user
  mentions PDFs, forms, document extraction, or asks to combine files.
```

Poor:
```yaml
description: Helps with PDFs.
```

#### Optional fields

```yaml
---
name: cloud-deploy
description: ...
license: Apache-2.0
compatibility: Requires git, docker, and internet access
metadata:
  author: your-org
  version: "1.0"
allowed-tools: Bash(git:*) Bash(docker:*)
---
```

| Field           | When to include                                             |
| --------------- | ----------------------------------------------------------- |
| `license`       | When distributing publicly or when terms apply              |
| `compatibility` | Only if the skill needs specific tools, packages, or access |
| `metadata`      | For author, version, or custom key-value pairs              |
| `allowed-tools` | Experimental — pre-approve specific tools the skill may use |

Most skills only need `name` and `description`.

### 3. Write the instruction body

The Markdown body after the frontmatter is where you teach the agent how to perform the task. There are no rigid format requirements — write whatever helps the agent succeed.

#### Recommended structure

1. **Brief overview** — One or two sentences summarizing the skill's purpose (the agent has already read the description, so keep this concise).
2. **Step-by-step instructions** — The core workflow, written in imperative form ("Extract the text...", "Check for errors...", "Save the output to...").
3. **Output format** — If the skill produces structured output, define the expected format with a template or example.
4. **Examples** — Show realistic input/output pairs so the agent understands what good results look like.
5. **Edge cases and troubleshooting** — Address common failure modes and how to handle them.

#### Writing tips

**Use imperative voice.** "Extract the text from each page" is clearer than "The text should be extracted from each page."

**Explain the why, not just the what.** Agents are smart — when they understand the reasoning behind an instruction, they generalize better to novel situations. Instead of "ALWAYS use UTF-8 encoding", try "Use UTF-8 encoding because input files may contain non-ASCII characters that would be corrupted otherwise."

**Avoid over-constraining.** Heavy-handed MUST/NEVER/ALWAYS rules in all-caps tend to make agents brittle. Reserve strong constraints for things that genuinely matter (e.g., security boundaries, data integrity). For stylistic preferences, explain why and let the agent exercise judgment.

**Include examples.** A single concrete example often communicates more than a paragraph of abstract instructions:

```markdown
## Commit message format

**Example 1:**
Input: Added user authentication with JWT tokens
Output: feat(auth): implement JWT-based authentication

**Example 2:**
Input: Fixed crash when uploading empty file
Output: fix(upload): handle empty file gracefully
```

**Define output formats explicitly when they matter:**

```markdown
## Report structure

Use this template for all generated reports:

# [Title]
## Executive summary
## Key findings
## Recommendations
```

### 4. Add supporting resources (if needed)

Use the progressive disclosure principle: keep the main `SKILL.md` focused, and move supplementary material into subdirectories.

#### scripts/

Put executable code here when the agent needs to run deterministic or repetitive operations. Scripts should be self-contained, include error handling, and document their dependencies.

```
scripts/
├── extract_tables.py    # Pulls tables from PDFs
└── merge_pdfs.sh        # Combines multiple PDF files
```

Reference scripts from your SKILL.md with clear guidance on when to use them:

```markdown
For PDFs with complex tables, run the extraction script:
scripts/extract_tables.py --input <file> --output <dir>
```

> **Read `references/scripts.md` before writing or describing any scripts** if any of the following are true:
> - The skill will include a `scripts/` directory with bundled executables
> - The skill instructs the agent to run shell commands or package-manager tools (`uvx`, `npx`, `go run`, etc.)
> - You need guidance on inline dependency declarations, one-off commands, or how to design scripts for agentic consumption (structured output, `--help` conventions, exit codes, idempotency, dry-run flags)
>
> Skip this reference if the skill contains no executable components.

#### references/

Store additional documentation that the agent loads on demand. This is ideal for domain-specific guides, API references, or detailed technical notes that would bloat the main file.

```
references/
├── aws.md       # AWS-specific deployment steps
├── gcp.md       # GCP-specific deployment steps
└── azure.md     # Azure-specific deployment steps
```

In `SKILL.md`, point the agent to the right file:

```markdown
Based on the user's cloud provider, read the relevant guide:
- AWS → references/aws.md
- GCP → references/gcp.md
- Azure → references/azure.md
```

Keep individual reference files focused. Agents load these into context, so smaller files mean less wasted tokens. For files over 300 lines, include a table of contents at the top.

#### assets/

Static resources like templates, images, or lookup tables go here:

```
assets/
├── report-template.docx
├── logo.png
└── country-codes.json
```

### 5. Review and refine

Before considering the skill complete, check these:

**Size check:**
- Is `SKILL.md` under 500 lines? If not, move detailed content to `references/`.
- Is the frontmatter `description` under 1024 characters?

**Naming check:**
- Does the `name` field match the directory name?
- Is the name lowercase with hyphens only, no leading/trailing/consecutive hyphens?

**Trigger check:**
- Would an agent reading only the `description` know when to activate this skill?
- Are relevant keywords and user phrasings mentioned?

**Instruction check:**
- Can the agent follow the instructions from top to bottom without ambiguity?
- Are edge cases addressed?
- Are examples included for non-obvious outputs?

**Reference check:**
- Are all file references using relative paths from the skill root?
- Are references one level deep (no deeply nested chains)?

## Quick-Start Template

Use this as a starting point for new skills:

```yaml
---
name: your-skill-name
description: >-
  [What this skill does]. Use when [specific trigger contexts,
  keywords, and user phrasings that should activate this skill].
---
```

```markdown
# [Skill Title]

[One-sentence overview of what this skill does.]

## Workflow

1. [First step — imperative voice]
2. [Second step]
3. [Third step]

## Output Format

[Define expected output structure if applicable.]

## Examples

**Example 1:**
Input: [realistic input]
Output: [expected output]

## Edge Cases

- [Common issue]: [How to handle it]
- [Another issue]: [How to handle it]
```

## Common Mistakes

- **Description too vague.** "Helps with data" won't trigger reliably. Be specific about what tasks and contexts the skill covers.
- **Instructions too long.** A 1000-line SKILL.md wastes context. Split into a focused SKILL.md and reference files.
- **No examples.** Abstract instructions are ambiguous. One good example eliminates an entire class of misunderstandings.
- **Rigid over-constraining.** Walls of MUST/NEVER make agents fragile. Explain reasoning instead, and save strong constraints for things that genuinely matter.
- **Name doesn't match directory.** The `name` field and the parent directory must be identical. `pdf-tools/SKILL.md` with `name: pdf-processing` will fail validation.
- **Deeply nested references.** Keep file references one level deep from SKILL.md. If file A references file B which references file C, the agent will struggle to follow the chain.

## Validation

If you have access to the [skills-ref](https://github.com/agentskills/agentskills) validation tool, run it to check your skill:

```bash
skills-ref validate ./your-skill-name
```

This verifies frontmatter validity, naming conventions, and structural requirements.
