#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "$0")/../fixtures/coach-web.sh"
mkdir -p docs/discovery
cat > docs/discovery/2026-10-13-workouts.md <<'EOF'
# Example Map: workouts

🟨 **Story:** As a coach, I want to see my athletes' workouts, so that I can plan their training.

**Mode:** FORWARD (no code for workouts yet)
**Status:** 3 rules (1 ✓, 2 !, 0 ?) · 0 questions open

**How to answer:** edit this file, or reply in chat by ID, e.g. `R3: no, only admins`. A bare `ok` next to an ID confirms it. `accept all !` confirms every `!` at once.
Markers: `✓` confirmed by you · `!` Claude is sure, with evidence · `?` Claude's guess · `⚠` suspected problem.

---

## Rules

### R1 ✓ Coaches see only their group's workouts
Evidence: README.md, section "Groups": training data is shared only within the group
- B1.1 The one where coach Anna opens Carl's workout "Long run 18 km" from group B → not found
- B1.2 The one where coach Anna opens Ben's workout "Tempo run 5 km" from her own group A → she sees it

### R2 ! Athletes see only their own workouts
Evidence: pilot feedback, ticket #42: athletes in the pilot asked not to be compared with each other
- B2.1 The one where athlete Ben opens Carl's workout → not found

### R3 ! Only admins can delete workouts
Evidence: support log, ticket #57: a deleted workout cannot be restored, and coaches deleted the wrong ones in the pilot
- B3.1 The one where coach Anna deletes Ben's workout → refused, the workout stays
- B3.2 The one where admin Mia deletes Ben's workout → it is gone for Ben and Anna

---

## 🟥 Open questions

None open.

- ~~F1~~ → R3
EOF
