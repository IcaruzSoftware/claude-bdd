# Fixture: features/workouts.feature as formulate writes it from scratchpad-done.
# Sourced by scaffold.sh in the case folders; writes into the current dir.
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
      When Anna opens Carl's workout "Long run 18 km"
      Then Anna sees no workout

    @B1.2
    Example: Anna opens Ben's workout from her own group
      Given Ben is an athlete in group A
      And Anna coaches group A
      When Anna opens Ben's workout "Tempo run 5 km"
      Then Anna sees the workout

  @R2
  Rule: Athletes see only their own workouts

    @B2.1
    Example: Ben opens Carl's workout
      Given Ben and Carl are athletes
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

    @B3.2
    Example: Mia deletes Ben's workout
      Given Mia is an admin
      When Mia deletes Ben's workout
      Then neither Ben nor Anna sees the workout
EOF
