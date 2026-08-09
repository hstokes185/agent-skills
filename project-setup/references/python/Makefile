# Named commands — agents and humans use the same verbs.
# CI calls `make lint` etc. (not `uv run make` — make is not a Python dep).
#
# Fallback: `make` is not available on Windows by default. On Windows,
# run the `uv run ...` commands directly instead.

.PHONY: lint format-check typecheck test

lint:
	uv run ruff check .

format-check:
	uv run ruff format --check .

typecheck:
	uv run mypy src

test:
	uv run pytest