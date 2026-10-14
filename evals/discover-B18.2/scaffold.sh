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
cat > docs/discovery/2026-10-13-coach-app.md <<'EOF'
# Example Map: coach app

🟨 **Story:** As a running club, I want one app for groups, workouts and billing, so that coaches stop using spreadsheets.

**Mode:** FORWARD (no code for the coach app yet)
**Status:** 15 rules (0 ✓, 0 !, 15 ?) · 0 questions open

**How to answer:** edit this file, or reply in chat by ID, e.g. `R3: no, only admins`. A bare `ok` next to an ID confirms it. `accept all !` confirms every `!` at once.
Markers: `✓` confirmed by you · `!` Claude is sure, with evidence · `?` Claude's guess · `⚠` suspected problem.

---

## Rules

### R1 ? Coaches see only their group's workouts
- B1.1 The one where coach Anna and athlete Ben meet rule 1 → it holds

### R2 ? Athletes see only their own workouts
- B2.1 The one where coach Anna and athlete Ben meet rule 2 → it holds

### R3 ? Only admins can delete workouts
- B3.1 The one where coach Anna and athlete Ben meet rule 3 → it holds

### R4 ? Coaches invite athletes by email
- B4.1 The one where coach Anna and athlete Ben meet rule 4 → it holds

### R5 ? An invitation expires after 7 days
- B5.1 The one where coach Anna and athlete Ben meet rule 5 → it holds

### R6 ? Athletes can leave a group at any time
- B6.1 The one where coach Anna and athlete Ben meet rule 6 → it holds

### R7 ? Coaches send planned workouts to their group
- B7.1 The one where coach Anna and athlete Ben meet rule 7 → it holds

### R8 ? Athletes comment on their own workouts
- B8.1 The one where coach Anna and athlete Ben meet rule 8 → it holds

### R9 ? Coaches see comments on their group's workouts
- B9.1 The one where coach Anna and athlete Ben meet rule 9 → it holds

### R10 ? The club pays a monthly fee per active athlete
- B10.1 The one where coach Anna and athlete Ben meet rule 10 → it holds

### R11 ? An athlete without a workout for 30 days is inactive
- B11.1 The one where coach Anna and athlete Ben meet rule 11 → it holds

### R12 ? Coaches get a weekly summary email
- B12.1 The one where coach Anna and athlete Ben meet rule 12 → it holds

### R13 ? Athletes export their workouts as CSV
- B13.1 The one where coach Anna and athlete Ben meet rule 13 → it holds

### R14 ? The workout card shows the sport's colour
- B14.1 The one where coach Anna and athlete Ben meet rule 14 → it holds

### R15 ? The calendar starts the week on Monday
- B15.1 The one where coach Anna and athlete Ben meet rule 15 → it holds

---

## 🟥 Open questions

None open.
EOF
