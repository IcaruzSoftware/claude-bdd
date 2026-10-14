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
# Example Map: Workouts

🟨 **Story:** Als Coach möchte ich die Workouts meiner Athleten sehen, damit ich ihr Training planen kann.

**Mode:** FORWARD (noch kein Code für Workouts)
**Status:** 3 Regeln (1 ✓, 0 !, 2 ?) · 1 Frage offen

**How to answer:** edit this file, or reply in chat by ID, e.g. `R3: no, only admins`. A bare `ok` next to an ID confirms it. `accept all !` confirms every `!` at once.
Markers: `✓` confirmed by you · `!` Claude is sure, with evidence · `?` Claude's guess · `⚠` suspected problem.

---

## Regeln

### R1 ✓ Coaches sehen nur die Workouts ihrer Gruppe
- B1.1 Der Fall, in dem Coach Anna Carls Workout aus Gruppe B öffnet → nicht gefunden

### R3 ? Nur Admins und der Coach der eigenen Gruppe dürfen Workouts löschen
- B3.1 Der Fall, in dem Coach Anna Bens Workout "Tempolauf 5 km" löscht → erlaubt, Ben ist in ihrer Gruppe

### R2 ? Athleten sehen nur ihre eigenen Workouts
- B2.1 Der Fall, in dem Athlet Ben Carls Workout öffnet → nicht gefunden

---

## 🟥 Offene Fragen

- F1 Darf ein Coach einen Athleten in eine andere Gruppe verschieben?
EOF
