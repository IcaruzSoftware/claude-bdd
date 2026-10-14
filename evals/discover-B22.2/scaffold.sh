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
mkdir -p src
cat > src/__init__.py <<'EOF'

EOF
mkdir -p src/workouts
cat > src/workouts/__init__.py <<'EOF'

EOF
mkdir -p src/workouts
cat > src/workouts/store.py <<'EOF'
"""In-memory store of the coach app."""

from dataclasses import asdict, dataclass


@dataclass
class Workout:
    id: int
    athlete_id: int
    group_id: str
    title: str

    def to_dict(self):
        return asdict(self)


WORKOUTS = [
    Workout(1, athlete_id=10, group_id='A', title='Tempo run 5 km'),
    Workout(2, athlete_id=11, group_id='B', title='Long run 18 km'),
]
EOF
mkdir -p src/workouts
cat > src/workouts/api.py <<'EOF'
"""Workouts API of the coach app."""

from flask import Flask, abort, g, jsonify

from .store import WORKOUTS

app = Flask(__name__)


@app.get('/workouts')
def list_workouts():
    user = g.user
    if user.role == 'coach':
        items = [w for w in WORKOUTS if w.group_id == user.group_id]
    elif user.role == 'athlete':
        items = [w for w in WORKOUTS if w.athlete_id == user.id]
    else:
        items = WORKOUTS
    return jsonify([w.to_dict() for w in items])


@app.get('/workouts/<int:workout_id>')
def workout_detail(workout_id):
    user = g.user
    workout = next((w for w in WORKOUTS if w.id == workout_id), None)
    if workout is None:
        abort(404)
    if user.role == 'athlete' and workout.athlete_id != user.id:
        abort(404)
    return jsonify(workout.to_dict())


@app.delete('/workouts/<int:workout_id>')
def delete_workout(workout_id):
    if g.user.role != 'admin':
        abort(403)
    WORKOUTS[:] = [w for w in WORKOUTS if w.id != workout_id]
    return '', 204
EOF
mkdir -p tests
cat > tests/__init__.py <<'EOF'

EOF
mkdir -p tests
cat > tests/test_store.py <<'EOF'
from src.workouts.store import WORKOUTS


def test_store_has_workouts():
    assert len(WORKOUTS) == 2
EOF
mkdir -p docs/discovery
cat > docs/discovery/2026-10-13-workouts.md <<'EOF'
# Example Map: workouts

🟨 **Story:** As a coach, I want to see my athletes' workouts, so that I can plan their training.

**Mode:** FORWARD (no code for workouts yet)
**Status:** 4 rules (3 ✓, 0 !, 1 ?) · 0 questions open

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

### R4 ? A coach sees the workouts of a substitute's group while the substitution lasts
- B4.1 The one where Anna substitutes for Tom from 1 to 7 May → she sees group C's workouts until 7 May

---

## 🟥 Open questions

None open.

- ~~F1~~ → R3
EOF
