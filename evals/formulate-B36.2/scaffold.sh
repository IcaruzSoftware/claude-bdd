#!/usr/bin/env bash
set -euo pipefail
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
mkdir -p docs/discovery
cat > docs/discovery/2026-10-13-workouts.md <<'EOF'
# Example Map: workouts

🟨 **Story:** As a coach, I want to see my athletes' workouts, so that I can plan their training.

**Mode:** FORWARD (no code for workouts yet)
**Status:** 4 rules (3 ✓, 0 !, 0 ?) · 0 questions open

**How to answer:** edit this file, or reply in chat by ID, e.g. `R3: no, only admins`. A bare `ok` next to an ID confirms it. `accept all !` confirms every `!` at once.
Markers: `✓` confirmed by you · `!` Claude is sure, with evidence · `?` Claude's guess · `⚠` suspected problem.

---

## Rules

### R1 ✓ Coaches see only their group's workouts
Evidence: README.md, section "Groups": training data is shared only within the group
- B1.1 The one where coach Anna opens Carl's workout "Long run 18 km" from group B → not found
- B1.2 The one where coach Anna opens Ben's workout "Tempo run 5 km" from her own group A → she sees it

### R2 ✓ Athletes see only their own workouts
Reason: athletes in the pilot asked not to be compared with each other
- B2.1 The one where athlete Ben opens Carl's workout → not found

### R3 ✓ Only admins can delete workouts
Reason: a deleted workout cannot be restored, and coaches deleted the wrong ones in the pilot
- B3.1 The one where coach Anna deletes Ben's workout → refused, the workout stays
- B3.2 The one where admin Mia deletes Ben's workout → it is gone for Ben and Anna

### R4 ~~Athletes can rename workouts~~ dropped: renaming is out of scope for this story

---

## 🟥 Open questions

None open.

- ~~F1~~ → R3
EOF
