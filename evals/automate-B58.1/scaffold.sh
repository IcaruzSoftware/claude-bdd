#!/usr/bin/env bash
set -euo pipefail
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
mkdir -p billing
: > billing/__init__.py
cat > billing/service.py <<'PY'
"""Draft invoices from billable hours."""

HOURLY_RATE = {'standard': 120, 'senior': 150}


def draft_invoice(client, entries):
    """entries: (hours, level) pairs. Returns the draft the client will see."""
    lines = [_line(hours, level) for hours, level in entries]
    return {'client': client, 'lines': lines, 'total': sum(line['amount'] for line in lines)}


def _line(hours, level):
    rate = _hourly_rate(level)
    return {'hours': hours, 'rate': rate, 'amount': hours * rate}


def _hourly_rate(level):
    return HOURLY_RATE[level]
PY
mkdir -p features
cat > features/billing.feature <<'FEATURE'
Feature: Invoice assistant
  The invoice assistant drafts invoices from billable hours.

  @R1
  Rule: A draft invoice has one line per billable entry

    @B1.1
    Example: Two entries
      Given Mia has 2 standard hours and 1 senior hour
      When the assistant drafts her invoice
      Then the draft has 2 lines

  @R2
  Rule: The total is the hours times the hourly rate of their level

    @B2.1
    Example: Senior hours cost more
      Given Mia has 2 standard hours and 1 senior hour
      And the rates are 120 EUR standard and 150 EUR senior
      When the assistant drafts her invoice
      Then the total is 390 EUR
FEATURE
mkdir -p tests
cat > tests/test_billing.py <<'PY'
from billing.service import draft_invoice


def test_draft_has_one_line_per_entry():
    """billing:B1_1"""
    draft = draft_invoice('Mia', [(2, 'standard'), (1, 'senior')])

    assert len(draft['lines']) == 2
PY
# references are written as B1_1 above, so this repo's coverage script
# does not count them as tests of its own features
sed -i -E 's/(:B[0-9]+)_([0-9]+)/\1.\2/g' tests/*.py
