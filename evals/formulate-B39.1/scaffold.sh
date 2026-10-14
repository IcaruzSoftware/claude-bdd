#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "$0")/../fixtures/coach-web.sh"
mkdir -p features
cat > features/groups.feature <<'EOF'
Feature: Groups
  As a club admin, I want coaches to lead groups of athletes, so that every athlete has one coach.

  @R1
  Rule: Every athlete belongs to exactly one group

    @B1.1
    Example: Ben joins group B while in group A
      Given Ben is an athlete in group A
      When the admin moves Ben to group B
      Then Ben is in group B only

  @R2
  Rule: A coach leads exactly one group

    @B2.1
    Example: Anna is assigned a second group
      Given Anna coaches group A
      When the admin assigns Anna to group B
      Then the assignment is refused
EOF
mkdir -p docs/discovery
cat > docs/discovery/2026-10-13-training-plans.md <<'EOF'
# Example Map: training plans

🟨 **Story:** As a trainer, I want to publish training plans to my group, so that my athletes know what to run.

**Mode:** FORWARD (no code for training plans yet)
**Status:** 2 rules (2 ✓, 0 !, 0 ?) · 0 questions open

**How to answer:** edit this file, or reply in chat by ID, e.g. `R3: no, only admins`. A bare `ok` next to an ID confirms it. `accept all !` confirms every `!` at once.
Markers: `✓` confirmed by you · `!` Claude is sure, with evidence · `?` Claude's guess · `⚠` suspected problem.

---

## Rules

### R1 ✓ Trainers publish training plans only to their own group
Reason: athletes of other groups follow other plans
- B1.1 The one where trainer Anna publishes "Base week 3" to group B → refused

### R2 ✓ Athletes see the training plan of their group from the day it is published
- B2.1 The one where Anna publishes "Base week 3" to group A on Monday → Ben sees it on Monday

---

## 🟥 Open questions

None open.
EOF
