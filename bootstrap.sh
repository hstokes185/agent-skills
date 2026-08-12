#!/usr/bin/env bash
# Wire the leak gate into this clone.
#
# `core.hooksPath` is local git config, so a clone does not carry it. Until
# this is run, `git push` here is unchecked — and the hook that checks it lived
# in exactly one machine's .git/hooks for long enough that nothing recorded it
# was supposed to exist at all.
#
# Idempotent. Run it as often as you like.
#
# Exit codes: 0 = wired, 2 = could not.
set -euo pipefail

cd "$(dirname "$0")"
REPO="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[ -n "$REPO" ] || { echo "bootstrap: not inside a git repository" >&2; exit 2; }
cd "$REPO"

git config core.hooksPath .githooks
chmod +x .githooks/* 2>/dev/null || true

echo "bootstrap: core.hooksPath = $(git config --get core.hooksPath)"
echo "bootstrap: pre-push leak gate is wired"
