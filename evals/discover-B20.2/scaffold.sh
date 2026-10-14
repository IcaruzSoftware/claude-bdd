#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "$0")/../fixtures/coach-web.sh"
mkdir -p specs
cat > specs/2026-09-01-groups.md <<'EOF'
# Example Map: groups

🟨 **Story:** As a club admin, I want coaches to lead groups, so that every athlete has one coach.

**Mode:** FORWARD (no code for groups yet)
**Status:** 1 rules (1 ✓, 0 !, 0 ?) · 0 questions open · formulated into features/groups.feature

**How to answer:** edit this file, or reply in chat by ID, e.g. `R3: no, only admins`. A bare `ok` next to an ID confirms it. `accept all !` confirms every `!` at once.
Markers: `✓` confirmed by you · `!` Claude is sure, with evidence · `?` Claude's guess · `⚠` suspected problem.

---

## Rules

### R1 ✓ A coach leads exactly one group
- B1.1 The one where Anna, coach of group A, is assigned group B → refused

---

## 🟥 Open questions

None open.
EOF
