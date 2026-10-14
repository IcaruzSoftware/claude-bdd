#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "$0")/../fixtures/coach-web.sh"
mkdir -p features
cat > features/workouts.feature <<'EOF'
Feature: Workouts
  As a coach, I want to see my athletes' workouts, so that I can plan their training.

  @R1
  Rule: Coaches see only their group's workouts

    @B1.1
    Example: Anna opens Carl's workout from group B
      Given Carl is an athlete in group B
      And Anna coaches group A
      When Anna opens Carl's workout
      Then Anna sees no workout

  @R2
  Rule: Athletes see only their own workouts

    @B2.1
    Example: Ben opens Carl's workout
      Given Ben and Carl are athletes in group A
      When Ben opens Carl's workout
      Then Ben sees no workout

  @R3
  Rule: Only admins can delete workouts

    @B3.1
    Example: Anna deletes Ben's workout
      Given Anna coaches Ben's group
      When Anna deletes Ben's workout
      Then the deletion is refused
      And Ben's workout is still there
EOF
