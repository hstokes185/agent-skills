---
name: project-setup
description: >-
  Scaffold new projects with zero technical debt from the first commit —
  quality gates, secrets discipline, lockfiles, CI, and an eval harness
  before any feature code. Covers a Python track (uv, src layout,
  pydantic-settings, ruff, mypy, pytest) and a TypeScript/React track
  (pnpm, Vite, strict tsconfig, Vitest, React Testing Library), plus
  monorepos combining both. Use when the user wants to create a new
  project, set up a repo from scratch, bootstrap a service or web UI, or
  asks about project scaffolding, uv init, pnpm create vite, project
  structure, CI/CD setup, pre-commit setup, tsconfig strictness, or eval
  harness bootstrapping. Also trigger on "scaffold a project", "set up a
  new repo", "project foundations", or "start this right".
license: MIT
metadata:
  scope: professional
  version: "2.0.0"
  supersedes: python-project-setup 1.x
---

# Project Setup

Scaffold a production-quality project in one pass. The order is the point:
gates before code. Every convention here exists to make the first commit
and the thousandth commit pass the same checks, so debt never gets a
foothold.

Two tracks share one set of foundations. Apply the foundations always,
then the track(s) matching the stack. For architecture and agent-context
conventions (AGENTS.md constitution, deep modules, spec-anchored SDD),
apply the companion `ai-native-codebase-design` skill — this skill sets
up the repo; that one governs how code gets designed inside it.

## Shared foundations (any language)

These are language-independent rules. Each track below implements them
with specific tools.

1. **Pin the toolchain**: interpreter/runtime version pinned in a
   committed file. New machines get the same version without thinking.
2. **Commit the lockfile**: the manifest declares intent; the lockfile
   pins the exact resolved tree with hashes. Both are committed. This
   eliminates "works on my machine" at the dependency level.
3. **Secrets discipline from minute one**: `.env` git-ignored,
   `.env.example` committed with every key and no values, a secret
   scanner (gitleaks) in pre-commit. Secrets never reach Git — this is
   cheaper to enforce from commit zero than to remediate after a leak.
4. **One typed config module**: all environment access flows through a
   single validated settings module. No scattered `os.getenv()` /
   `process.env` reads. Required keys fail loudly at startup.
5. **Split runtime and dev dependencies**: production installs stay lean;
   tooling never ships.
6. **Quality gates before the first real commit**: formatter, linter,
   type-checker, and test runner configured and passing on the empty
   project. Adding a formatter after two hundred files creates one
   enormous reformatting commit that tangles history.
7. **CI on the first commit**: a workflow that mirrors the local gate
   sequence exactly. If it passes locally, it passes on the server. CI
   is always there, not a deferred chore.
8. **First trivial eval**: a parametrised test over a small hand-written
   `CASES` dataset — data, not code — wired into the standard test
   runner so CI already runs it. The shape is right from day one; only
   the contents deepen. Grow it every time the system gets something
   wrong.
9. **One formatter per repo**: never mix competing formatters. Pick one,
   enforce it in CI, and let pre-commit apply it.

## Python track

### 1. Scaffold with uv

```bash
uv init --package --name <importable-package-name> <project-dir>
cd <project-dir>
uv python pin 3.12
```

`--package` gives the src layout — code lives under `src/<pkg>/` and
nothing can import it until properly installed, catching packaging
misconfiguration during development rather than after release.

### 2. Generate the .gitignore

```bash
curl -sL "https://www.toptal.com/developers/gitignore/api/python,node,linux,visualstudiocode" -o .gitignore
```

Verify these entries are present — add them if missing:

```text
.env
.env.*
!.env.example
.venv/
__pycache__/
*.pyc
node_modules/
```

The `!.env.example` re-includes the example template even though `.env.*`
ignores everything else.

### 3. Environment-based config with pydantic-settings

```bash
uv add pydantic-settings
```

Create `.env.example` (committed, no values) and `.env` (git-ignored,
real values). Write the settings loader at `src/<pkg>/config.py`
following `references/python/config.py`: a `Settings` class with
`SettingsConfigDict(env_file=".env")`, required keys without defaults,
optional keys with defaults, and a module-level singleton
`settings = Settings()`. Everything else
imports `settings` — one import, one source of truth.

### 4. Dependencies, sorted into groups

```bash
uv add <runtime-deps>
uv add --dev ruff mypy pytest pre-commit
```

`uv sync --no-dev` for the production image, `uv sync` for development.
`uv add` writes both `pyproject.toml` and `uv.lock`; commit both.

Next, configure the tool tables in `pyproject.toml` — `[tool.mypy]`,
`[tool.ruff]`, `[tool.pytest.ini_options]` — per the canonical file at
`references/python/pyproject.toml`. Add `[tool.mypy]` with `strict = true`.

> In TOML, a `[tool.*]` table header ends the `[project]` section. Every
> `[tool.*]` table must come after all keys belonging to `[project]`
> (name, version, dependencies, etc.). Placing `[tool.mypy]` before
> `dependencies` silently absorbs those keys into the mypy table.

### 5. Auto-activate the venv with direnv

```bash
echo 'source .venv/bin/activate' > .envrc
direnv allow
```

### 6. Pre-commit gates

Three hooks, pinned to specific revisions: `ruff` (lint), `ruff-format`
(format), `gitleaks` (secret scan). Canonical config at
`references/python/pre-commit.yaml`.

```bash
uv run pre-commit install
git add -A
uv run pre-commit run --all-files
```

> On a fresh repo with no commits, every file is untracked.
> `pre-commit run --all-files` only checks files git knows about, so
> without the stage step it reports `(no files to check)` and runs
> nothing — a gate that reports success without executing is worse than
> no gate, because it stops anyone looking again.

### 7. CI workflow

`.github/workflows/ci.yml` per `references/python/ci.yml`: checkout →
setup-uv → `uv sync --frozen` → `uv run ruff check .` → `uv run mypy src`
→ `uv run pytest`. CI does not run the formatter — pre-commit owns
formatting.

### 8. Named commands (Makefile)

Add `references/python/Makefile` as `Makefile` at the project root.
This gives agents and humans the same verbs:

```makefile
make lint        # ruff check
make format-check # ruff format --check
make typecheck   # mypy src
make test        # pytest
```

CI calls `make lint` (not `uv run make` — `make` is a system tool, not
a Python dependency). The Makefile targets call `uv run` internally.

> `make` is not present by default on Windows. On Windows, run the
> `uv run` commands directly instead.

### 9. First eval

Follow `references/python/eval_template.py`: a `CASES` list of
`(input, expected)` tuples, `@pytest.mark.parametrize`, exact-match
assertion to start. Because it is pytest, CI already runs it.

### 10. Verify the full pipeline

```bash
uv run ruff check . && uv run ruff format --check . && uv run mypy src --strict && uv run pytest
```

All must pass. Same sequence as CI.

### 11. First commit

With the pipeline green, set git identity (if not already set globally) and
make the first commit:

```bash
git config user.name "YOUR_NAME" && git config user.email "YOUR_EMAIL"
git add -A && git commit -m "Initial scaffold: Python project with quality gates"
```

On a fresh machine with no global git config, `git commit` fails without
this step. The commit message captures the scaffolding intent — every
subsequent commit is a real change on top of that foundation.

## TypeScript/React track

### 1. Scaffold with pnpm and Vite

```bash
pnpm create vite <project-dir> --template react-ts
cd <project-dir> && pnpm install
```

pnpm for speed and strict node_modules; commit `pnpm-lock.yaml`. Pin the
runtime with a committed `.nvmrc` (or `engines` field) — e.g. `22`.

### 2. Strict tsconfig

Vite's template starts strict; verify and keep these in
`tsconfig.app.json`:

```jsonc
{
  "compilerOptions": {
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true,
    "noUncheckedSideEffectImports": true,
    "moduleResolution": "bundler",
    "noEmit": true
  }
}
```

`tsc --noEmit` is the type gate (Vite transpiles without checking).
TypeScript's native (Go-based) compiler preview can run as an optional
faster validation lane, but keep stable `tsc` as the merge gate until it
ships stable.

### 3. Lint and format — pick one tool

Either **Biome** (one fast tool for lint + format) or **ESLint flat
config + Prettier**. Never both formatters in one repo; whichever is
chosen is enforced in CI and applied by pre-commit. Default to Biome for
new projects: single dependency, single config, an order of magnitude
faster.

```bash
pnpm add -D @biomejs/biome && pnpm biome init
```

### 4. Config and secrets at the edge

Frontend env vars are **public**: anything prefixed `VITE_` is embedded
in the shipped bundle. Never put secrets in frontend `.env` files —
secrets live server-side only. Validate the env at startup with a single
typed module using Zod:

```ts
// src/config.ts — the only file that touches import.meta.env
import { z } from "zod";
const Env = z.object({ VITE_API_BASE: z.string().url() });
export const env = Env.parse(import.meta.env);
```

Zod at all boundaries (env, API responses, forms) — parse, don't cast.

### 5. Testing

```bash
pnpm add -D vitest jsdom @testing-library/react @testing-library/jest-dom @testing-library/user-event
```

Vitest as the runner (Vite-native), React Testing Library for
behaviour-focused component tests. Add Playwright later for critical
end-to-end flows only (login, payment-grade paths). The first eval is
the same pattern as the Python track: a `CASES` array driven through
`test.each`, committed before feature code.

### 6. Pre-commit and CI

Same gitleaks hook as the Python track, plus the chosen lint/format
tool. CI workflow per `references/typescript/ci.yml`: checkout →
setup-node with pnpm cache → `pnpm install --frozen-lockfile` → lint →
`tsc --noEmit` → `vitest run` → `pnpm build`. `--frozen-lockfile` makes
CI fail if the lockfile drifted from the manifest. Run `pnpm audit` in
CI on a schedule, not every push.

### 7. Scripts parity

`package.json` scripts mirror the gate names across every project:
`dev`, `build`, `lint`, `format`, `typecheck`, `test`. Agents and
humans then never guess the command.

## Monorepo (both tracks in one repo)

For a Python service with a TypeScript/React UI (e.g. an API plus an
enterprise console):

- Layout: `apps/api/` (Python track) and `apps/web/` (TS track), each
  self-contained with its own lockfile and gates
- One `.gitignore`, one `.pre-commit-config.yaml` (gitleaks global;
  language hooks scoped by `files:` patterns), one `.env.example` per app
- CI as one workflow with two jobs (`api`, `web`), each running its
  track's gate sequence; path filters so a docs-only change doesn't run
  both
- pnpm workspaces only if there are multiple JS packages; a single web
  app doesn't need it

## Output checklist

Foundations (always):

- [ ] Toolchain version pinned and committed
- [ ] Lockfile(s) committed
- [ ] `.gitignore` with verified `.env` entries
- [ ] `.env.example` committed, `.env` ignored
- [ ] Single typed config module; no scattered env reads
- [ ] gitleaks in pre-commit, hooks installed
- [ ] CI workflow mirroring local gates, green on first commit
- [ ] First trivial eval committed and running in CI
- [ ] Exactly one formatter, enforced in CI

Python track: `pyproject.toml` + `uv.lock`, `.python-version`, `.envrc`,
`src/<pkg>/config.py`, ruff + mypy (strict) + pytest green.

TypeScript track: `pnpm-lock.yaml`, `.nvmrc`, strict `tsconfig`,
`src/config.ts` (Zod), Biome (or ESLint+Prettier) + `tsc --noEmit` +
Vitest green, `build` succeeds.

## Reference files

> **`references/python/`** — canonical Python configs: `ci.yml`,
> `pre-commit.yaml`, `config.py`, `eval_template.py`, `pyproject.toml`,
> `Makefile`, `README.md`. Copy verbatim and adapt names/placeholders.
> Run `uv run pre-commit autoupdate` to update pinned hook revisions
> to the latest tags (replaces manual curl-and-grep) before the first
> commit.

> **`references/typescript/`** — canonical TS configs: `ci.yml`. Copy
> verbatim and adapt.

When a detail is ambiguous, read the corresponding reference file
directly rather than guessing.
