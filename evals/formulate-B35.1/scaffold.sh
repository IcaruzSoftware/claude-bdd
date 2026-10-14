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
cat > pyproject.toml <<'EOF'
[project]
name = "coach-app"
version = "0.3.0"
requires-python = ">=3.11"
dependencies = ["flask>=3"]

[dependency-groups]
dev = ["pytest"]
EOF
mkdir -p src/coach
cat > src/coach/__init__.py <<'EOF'

EOF
mkdir -p src/coach
cat > src/coach/app.py <<'EOF'
"""Coach app: groups, athletes and workouts."""

from flask import Flask, render_template

app = Flask(__name__)

WORKOUTS = [
    {'id': 1, 'title': 'Tempo run 5 km', 'athlete': 'Ben'},
    {'id': 2, 'title': 'Long run 18 km', 'athlete': 'Carl'},
]


@app.get('/workouts')
def workouts():
    return render_template('workouts.html', workouts=WORKOUTS)
EOF
mkdir -p src/coach/templates
cat > src/coach/templates/workouts.html <<'EOF'
<ul class="workouts">
  {% for w in workouts %}
  <li id="workout-{{ w.id }}">{{ w.title }} ({{ w.athlete }})</li>
  {% endfor %}
</ul>
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
