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
