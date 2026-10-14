#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "$0")/../fixtures/billing.sh"
cat > CLAUDE.md <<'MD'
# Invoice assistant

## Test rules

- Write boundary tests. Derive the seam from the code under test: the first
  public function the use case goes through. For drafting invoices that is
  `billing.service.draft_invoice`.
- Never call a private helper (`_name`) from a test, and never mock our own code.
- Put realistic business input in at the seam and assert the business result
  that comes out: the lines and amounts the client sees.
- One test file per feature: `tests/test_<feature>.py`, plain pytest functions.
MD
cat > pyproject.toml <<'TOML'
[project]
name = "coach"
version = "0.1.0"
requires-python = ">=3.10"

[dependency-groups]
dev = ["pytest"]

[tool.pytest.ini_options]
testpaths = ["tests"]
TOML
