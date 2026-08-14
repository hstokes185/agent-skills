# Agent skills

Portable skills for AI coding agents. Each directory is a self-contained `SKILL.md` bundle following the Agent Skills format — copy the ones you want into your agent's skills directory.

| Skill | Description |
|---|---|
| `agentic-business-case` | Build an enterprise-grade business plan for an AI agent or agentic system from a user's idea, delivered as a markdown business case plus a companion PowerPoint deck. |
| `agentic-governance` | Build and continuously run a complete governance programme for an agentic AI project. |
| `ai-native-codebase-design` | Enforces context-efficient software architecture, deep modules, strict information hiding, and Spec-Driven Development (SDD). |
| `gateway-restart` | Restart a systemd unit from inside itself — a gateway, daemon, or agent — without the restart command being killed by its own unit's stop action. |
| `linux-mint-autopilot` | Set up, automate, and maintain a personal Linux Mint machine so it looks after itself. |
| `obsidian-course-notes` | Converts raw course transcripts, lecture summaries, slide text, and code walkthrough screenshots into clean, structured Obsidian Markdown notes ready to drop into a vault. |
| `oxford-markdown` | Format Markdown in clean, professional Oxford-style British English — em-dashes, Oxford commas, sentence-case headings from H2, and consistent list, table, code-block, and frontmatter conventions. |
| `project-setup` | Scaffold new projects with zero technical debt from the first commit — quality gates, secrets discipline, lockfiles, CI, and an eval harness before any feature code. |
| `skill-creation` | Guide for authoring well-structured Agent Skills that follow the Agent Skills specification. |

## Install

```bash
git clone https://github.com/hstokes185/agent-skills.git
cp -r agent-skills/<skill> ~/.claude/skills/
```

