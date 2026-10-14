#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "$0")/../fixtures/coach-web.sh"
mkdir -p docs/discovery
cat > docs/discovery/2026-10-13-workout-sharing.md <<'EOF'
# Example Map: workout sharing

🟨 **Story:** As a coach, I want to send a planned workout to my athletes, so that they train the same plan.

**Mode:** FORWARD (no code for workout sharing yet)
**Status:** 2 rules (0 ✓, 0 !, 2 ?) · 4 questions open

**How to answer:** edit this file, or reply in chat by ID, e.g. `R3: no, only admins`. A bare `ok` next to an ID confirms it. `accept all !` confirms every `!` at once.
Markers: `✓` confirmed by you · `!` Claude is sure, with evidence · `?` Claude's guess · `⚠` suspected problem.

---

## Rules

### R1 ? Coaches send workouts only to athletes of their own group
- B1.1 The one where coach Anna sends "Intervals 6×800 m" to Carl from group B → refused

### R2 ? A sent workout appears in the athlete's calendar on the planned day
- B2.1 The one where Anna sends "Long run 18 km" for Sunday → Ben sees it on Sunday

---

## 🟥 Open questions

- F1 Can an athlete decline a sent workout?
- F2 What happens to sent workouts when an athlete changes group?
- F3 Can a coach edit a workout after sending it?
- F4 Are sent workouts visible to other coaches?
EOF
