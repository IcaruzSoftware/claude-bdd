#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "$0")/../fixtures/scratchpad-done.sh"
cat > README.md <<'EOF'
# Coach app

A training app for running clubs. Coaches lead groups of athletes, athletes
log their workouts, and coaches plan the training from those workouts.

## Groups

Every athlete belongs to one group. Athletes' training data is shared only
within their group.
EOF
cat > pom.xml <<'EOF'
<project xmlns="http://maven.apache.org/POM/4.0.0">
  <modelVersion>4.0.0</modelVersion>
  <groupId>club.coach</groupId>
  <artifactId>coach-app</artifactId>
  <version>0.3.0</version>
  <dependencies>
    <dependency>
      <groupId>io.cucumber</groupId>
      <artifactId>cucumber-java</artifactId>
      <version>7.20.1</version>
      <scope>test</scope>
    </dependency>
  </dependencies>
</project>
EOF
mkdir -p src/main/java/club/coach
cat > src/main/java/club/coach/Workouts.java <<'EOF'
package club.coach;

public class Workouts {}
EOF
mkdir -p src/test/resources/features
cat > src/test/resources/features/groups.feature <<'EOF'
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
