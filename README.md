# Agent Skills

A collection of Agent Skills — reusable, self-contained instructions that teach AI coding agents how to perform specific tasks. Each skill is a directory containing a `SKILL.md` file that follows the [Agent Skills specification](https://github.com/agentskills/agentskills).

## What is an Agent Skill?

An Agent Skill is a directory with a `SKILL.md` file (and optional supporting resources like scripts, references, and assets) that teaches an AI agent how to perform a specific task. Agents load skill metadata at startup, read full instructions when activated, and pull in additional resources as needed.

## Skills

| Skill | Description |
|-------|-------------|
| [ai-native-codebase-design](./ai-native-codebase-design/) | Enforces context-efficient software architecture, deep modules, strict information hiding, and Spec-Driven Development (SDD) |
| [obsidian-course-notes](./obsidian-course-notes/) | Converts raw course transcripts, lecture summaries, and slide text into structured Obsidian Markdown notes |
| [obsidian-formatting](./obsidian-formatting/) | Formats text and documents into clean, consistent Obsidian-compatible Markdown |
| [prd](./prd/) | Generates comprehensive Product Requirements Documents with user stories, functional requirements, and phased roadmaps |
| [skill-creation](./skill-creation/) | Guide for authoring well-structured Agent Skills that follow the spec |
| [wiki-ops](./wiki-ops/) | Operates an LLM wiki with ingest, lint, and query-file-back workflows |

## Using Skills

These skills work with any agent that supports the Agent Skills specification, including Claude Code and OpenCode.

### OpenCode

```bash
# Single skill
ln -s "$(pwd)/prd" ~/.config/opencode/skills/prd

# All skills
for skill in */; do
  ln -s "$(pwd)/$skill" ~/.config/opencode/skills/"$skill"
done
```

### Claude Code (and OpenCode compatible)

```bash
# Single skill
ln -s "$(pwd)/prd" ~/.claude/skills/prd

# All skills
for skill in */; do
  ln -s "$(pwd)/$skill" ~/.claude/skills/"$skill"
done
```

## License

Apache-2.0 — see [LICENSE](./LICENSE).
