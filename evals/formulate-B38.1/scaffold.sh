#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "$0")/../fixtures/coach-web.sh"
mkdir -p docs/discovery
cat > docs/discovery/2026-10-13-workouts.md <<'EOF'
# Example Map: workouts

🟨 **Story:** As a coach, I want to see my athletes' workouts, so that I can plan their training.

**Mode:** FORWARD (no code for workouts yet)
**Status:** 1 rules (1 ✓, 0 !, 0 ?) · 0 questions open

**How to answer:** edit this file, or reply in chat by ID, e.g. `R3: no, only admins`. A bare `ok` next to an ID confirms it. `accept all !` confirms every `!` at once.
Markers: `✓` confirmed by you · `!` Claude is sure, with evidence · `?` Claude's guess · `⚠` suspected problem.

---

## Rules

### R1 ✓ Coaches see only their group's workouts
Evidence: README.md, section "Groups"
- B1.1 The one where coach Anna clicks Carl's workout card (`#workout-42` on `/workouts`) from group B → the page says "not found"

---

## 🟥 Open questions

None open.
EOF
