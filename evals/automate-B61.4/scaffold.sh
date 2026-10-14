#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "$0")/../fixtures/coach-web.sh"
. "$(dirname "$0")/../fixtures/workouts-feature-formulated.sh"
mkdir -p docs/discovery
cat > docs/discovery/2026-10-13-workouts.md <<'EOF'
# Example Map: workouts

🟨 **Story:** As a coach, I want to see my athletes' workouts, so that I can plan their training.

**Mode:** BACKWARD (--backward; code: src/coach/, tests: none)
**Status:** 3 rules (3 ✓, 0 !, 0 ?) · 0 questions open

**How to answer:** edit this file, or reply in chat by ID, e.g. `R3: no, only admins`. A bare `ok` next to an ID confirms it. `accept all !` confirms every `!` at once.
Markers: `✓` confirmed by you · `!` Claude is sure, with evidence · `?` Claude's guess · `⚠` suspected problem.

---

## Rules

### R1 ✓ Coaches see only their group's workouts
Source: `src/coach/app.py:13`
- B1.1 The one where coach Anna opens Carl's workout "Long run 18 km" from group B → not found
- B1.2 The one where coach Anna opens Ben's workout "Tempo run 5 km" from her own group A → she sees it

### R2 ✓ Athletes see only their own workouts
Source: `src/coach/app.py:13`
- B2.1 The one where athlete Ben opens Carl's workout → not found

### R3 ✓ Only admins can delete workouts
Source: `src/coach/app.py:13`
- B3.1 The one where coach Anna deletes Ben's workout → refused, the workout stays
- B3.2 The one where admin Mia deletes Ben's workout → it is gone for Ben and Anna

---

## 🟥 Open questions

None open.
EOF
