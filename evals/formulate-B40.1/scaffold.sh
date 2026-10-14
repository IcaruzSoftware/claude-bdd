#!/usr/bin/env bash
set -euo pipefail
cat > README.md <<'EOF'
# Services

Monorepo of our services.

- `billing_assistant/`: the invoice assistant, proposes invoices from billable hours
- `dunning/`: the dunning run, sends payment reminders
EOF
mkdir -p billing_assistant
cat > billing_assistant/pyproject.toml <<'EOF'
[project]
name = "billing-assistant"
version = "1.0.0"
requires-python = ">=3.13"
EOF
mkdir -p billing_assistant/billing_assistant
cat > billing_assistant/billing_assistant/__init__.py <<'EOF'
"""Invoice assistant."""
EOF
mkdir -p dunning
cat > dunning/pyproject.toml <<'EOF'
[project]
name = "dunning"
version = "1.0.0"
requires-python = ">=3.13"
EOF
mkdir -p dunning/dunning
cat > dunning/dunning/__init__.py <<'EOF'
"""Dunning run."""
EOF
mkdir -p docs/discovery
cat > docs/discovery/2026-10-13-invoice-assistant.md <<'EOF'
# Example Map: invoice assistant

🟨 **Story:** As an accountant, I want the invoice assistant to propose invoices from billable hours, so that I stop typing them by hand.

**Mode:** FORWARD (no code for the invoice assistant yet)
**Status:** 2 rules (2 ✓, 0 !, 0 ?) · 0 questions open

**How to answer:** edit this file, or reply in chat by ID, e.g. `R3: no, only admins`. A bare `ok` next to an ID confirms it. `accept all !` confirms every `!` at once.
Markers: `✓` confirmed by you · `!` Claude is sure, with evidence · `?` Claude's guess · `⚠` suspected problem.

---

## Rules

### R1 ✓ The assistant proposes an invoice only for clients with billable hours in the period
Reason: empty invoices confused clients in the old process
- B1.1 The one where client Müller GmbH has 12 billable hours in September → one proposal over 12 hours
- B1.2 The one where client Schulz KG has no hours in September → no proposal

### R2 ✓ A proposal is never sent without an accountant's approval
Reason: invoices are legal documents and need a human sign-off
- B2.1 The one where accountant Lena has not approved the proposal for Müller GmbH → nothing is sent

---

## 🟥 Open questions

None open.
EOF
