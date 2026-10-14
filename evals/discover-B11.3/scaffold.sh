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
cat > tests/test_api.py <<'EOF'
from types import SimpleNamespace

import pytest
from flask import g

from src.workouts.api import app


@pytest.fixture
def client():
    return app.test_client()


def login(role, **kw):
    g.user = SimpleNamespace(role=role, **kw)


def test_coach_lists_only_group_workouts(client):
    with app.test_request_context():
        login('coach', id=1, group_id='A')
        titles = [w['title'] for w in app.view_functions['list_workouts']().json]
    assert titles == ['Tempo run 5 km']


def test_coach_cannot_delete(client):
    with app.test_request_context():
        login('coach', id=1, group_id='A')
        with pytest.raises(Exception):
            app.view_functions['delete_workout'](1)
EOF
