#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "$0")/../fixtures/coach-lib.sh"
. "$(dirname "$0")/../fixtures/workouts-feature.sh"
cat > pyproject.toml <<'TOML'
[project]
name = "coach"
version = "0.1.0"
requires-python = ">=3.10"
TOML
