#!/usr/bin/env bash
set -euo pipefail
mkdir -p docs/discovery
cat > docs/discovery/2026-10-13-workouts.md <<'MD'
# Example Map: workouts

🟨 **Story:** As a coach, I want to see my athletes' workouts, so that I can plan training.

**Mode:** FORWARD (no code for workouts yet)
**Status:** 4 rules (3 ✓, 0 !, 1 ?) · 0 questions open

### R1 ✓ Coaches see only their group's workouts
- B1.1 The one where coach Anna opens Carl's workout from group B → not found

### R2 ✓ Athletes see only their own workouts
- B2.1 The one where athlete Ben opens Carl's workout → not found

### R3 ✓ Only admins can delete workouts
- B3.1 The one where coach Anna deletes Ben's workout → refused

### R4 ? A coach sees the workouts of a substitute's group while the substitution lasts
- B4.1 The one where Anna substitutes for Tom from 1 to 7 May → she sees group C's workouts until 7 May
MD
