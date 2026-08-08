# agentic-business-case

An Agent Skill that turns an agentic AI project idea into a complete, enterprise-grade business plan, plus a companion PowerPoint deck. It interviews the user exhaustively, applies a full set of agentic-AI evaluation frameworks, and produces a board-ready case with a do-nothing baseline, itemised costs, a workflow design with human-in-the-loop gates, and a governance section.

## When to use it

Use it whenever someone has an agent idea or use case and wants a business case, business plan, design proposal, executive pitch, or deployment blueprint built from it. It also triggers on mentions of the PROFIT framework, the agentic viability checklist, or the AI adoption matrix, or when someone asks whether an agent idea is viable.

## What it produces

1. A complete markdown business plan (the primary deliverable) covering context and problem, strategic justification, financial rationale, high-level system design, risk and governance, implementation and ownership, and a framework-worksheet appendix.
2. A companion PowerPoint deck (8 to 12 slides) built on the included template, with native-shape diagrams.

## How to invoke it

This is an Agent Skill. Place the directory where your agent runtime discovers skills, then ask the agent for a business case or business plan for your agent idea. The agent reads `SKILL.md` and follows it. The skill is self-contained: everything it needs is in this directory.

## Files

| Path | Purpose |
|---|---|
| `SKILL.md` | The instructions the agent follows: interview, analysis, plan, deck, audit |
| `references/frameworks.md` | The framework source of truth, condensed for application |
| `references/rubric.md` | The quality bar per criterion and the failure modes to avoid |
| `references/deck-structure.md` | Slide-by-slide blueprint and python-pptx diagram code |
| `references/formatting.md` | Deck production rules (currency, bullets, calculation block, user edits) |

## Writing style

Output follows an analyst register, not a marketing one. The skill bans em-dashes, contrastive negation, rhetorical triplets, significance inflation (crucial, robust, seamless, transformative, leverage, delve, landscape, journey, empower, and similar), copula avoidance (serves as, stands as), and meta-signposting (It's worth noting, Importantly, Notably). The test: a reader should hear an analyst, not a language model.

## Frameworks used

Every framework the skill applies, with a short description. Full definitions are in `references/frameworks.md`; the quality bar is in `references/rubric.md`.

| Framework | Description |
|---|---|
| AI adoption matrix | Maps a deployment by task complexity and integration level into four clusters (traditional AI, LLM assistants, agentic AI, LLM-augmented judgement) to justify why an agent fits and which alternatives are rejected |
| Feasibility–desirability matrix | Plots a workflow by technical feasibility against workforce desirability into green, red, opportunity, and low-priority zones, populated through dialogue with the workforce |
| 7-point agentic viability checklist | Scores whether a workflow suits autonomous execution: multi-step, information-heavy, flexible decision rules, high variation, digital I/O, tool access, high volume; five or more signals a strong candidate |
| The rule of ten | Tests whether the agent delivers a 10x improvement in cost, speed, or capacity; if not, the complexity overhead rarely justifies an agent |
| PROFIT framework | A six-stage business case: Problem, Research, Options (including do-nothing), Financials, Implementation, Team and decisions |
| Build-versus-buy | A factor table (complexity, time, data and integration, internal capability, cost) that drives a build, buy, or hybrid recommendation |
| Hidden costs of deployment | The items that usually dominate spend: data pipelines, broken-process stabilisation, the edge-case penalty, and regulatory friction |
| Five-phase agent design | Operational parameters, workflow architecture, ecosystem integration, platform selection, and governance design |
| Principle of Least Privilege (PoLP) | Grant the minimum systemic access required for the mandate; sandbox execution to contain the blast radius of a hallucination |
| Workflow mapping | Trigger, execution steps, decision points, iteration loops, escalation gates, and outputs; a human operator must be able to follow the map |
| Governance lifecycle (five steps) | Establish ownership, define scope and boundaries, test before deployment, monitor continuously, prepare for failure |
| Six governance risk vectors | Autonomy and loss of control, real-world impact, complexity and opacity, accountability, data access and security, errors at scale |
| Four red-team attack vectors | Goal hijacking, tool orchestration abuse, memory poisoning, indirect instruction injection |
| Three layers of autonomy | Test perception, reasoning, and action independently rather than only the final output |
| Testing methodologies and metrics | LLM-as-a-judge, adversarial crescendo testing, golden datasets; metrics for tool-call reliability, boundary-violation rate, step efficiency, sub-goal completion, and Pass@k |
| Simulation environments | Shadow mode, digital twin, and meta-testing (agent-vs-agent), with rigour proportional to privilege |
| Regulatory landscape and deployment liability | Existing law applies in full (GDPR, CCPA, IP, product liability, sector rules); the EU AI Act sets the template; liability shifts to the deployer once a model is integrated |
| MCP and A2A | Model Context Protocol (agent-to-tool) and Agent-to-Agent (agent-to-agent coordination); name whether integrations are MCP-based and whether the architecture is single-agent or supervisor–worker |
| Pre-deployment checklist | An eight-point final verification before an agent is built or deployed |
| Quality rubric | Six criteria (problem definition, financial rationale, agent design, risk and governance, strategic communication, realism and judgement) used to audit the finished plan |

## References

- Anthropic — Schluntz, E. and Zhang, B. (2024) 'Building effective agents'.
- Armanios, D.; Shao, Y. et al. (2025) 'Future of work with AI agents: auditing automation and augmentation potential across the U.S. workforce'.
- Hacker, P. and Holweg, M. (2026) 'A pragmatic approach to regulating AI agents'.
- Pearl, J. and Mackenzie, D. (2019) _The Book of Why: The New Science of Cause and Effect_.
- Sapkota, R., Roumeliotis, K. I. and Karkee, M. (2025) 'AI agents vs. agentic AI: a conceptual taxonomy, applications and challenges', _Information Fusion_, 126.
- Teller, A. (2013) '10X thinking'.
- Wolpert, D. H. and Macready, W. G. (1997) 'No free lunch theorems for optimization', _IEEE Transactions on Evolutionary Computation_, 1(1).
- Wooldridge, M. (2020) _The Road to Conscious Machines: The Story of AI_.
- Yao, S. et al. (2023) 'ReAct: Synergizing Reasoning and Acting in Language Models'.
- EU AI Act — transparency, risk-based oversight, and disclosure obligations (Article 13).

## Attribution

Frameworks are drawn from practitioner and academic sources, including the works below. the sources listed above. The bundled PowerPoint template is the only organisation-specific asset; all instructional content is generic and applies to any enterprise.
