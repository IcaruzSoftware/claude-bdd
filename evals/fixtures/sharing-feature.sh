# Fixture: features/sharing.feature for the coach package.
# Sourced by scaffold.sh in the case folders; writes into the current dir.
mkdir -p features
cat > features/sharing.feature <<'FEATURE'
Feature: Sharing
  Coaches share workouts with the athletes of their group.

  @R1
  Rule: A coach shares workouts only within her group

    @B1.1
    Example: Sharing with an athlete of her group
      Given coach Tom leads group B
      And Carl is an athlete in group B
      When Tom shares the workout "Intervals" with Carl
      Then Carl sees "Intervals" in his workout list

    @B1.2
    Example: Sharing with an athlete of another group
      Given coach Tom leads group B
      And Ben is an athlete in group A
      When Tom shares the workout "Intervals" with Ben
      Then Tom is refused
FEATURE
