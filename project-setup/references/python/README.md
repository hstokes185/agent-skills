# <Project Name>

<One-line description of what this project does, what problem it solves, or
why it exists.>

## Quality gates

```bash
make lint        # ruff lint
make format-check # ruff format (check only)
make typecheck   # mypy (strict)
make test        # pytest
```

Or run individually:

```bash
uv run ruff check .
uv run ruff format --check .
uv run mypy src
uv run pytest
```

## Secrets

Copy `.env.example` to `.env` and fill in the values. Never commit `.env`.