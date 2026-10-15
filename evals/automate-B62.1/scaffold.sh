#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "$0")/../fixtures/coach-web.sh"
. "$(dirname "$0")/../fixtures/coach-api.sh"
. "$(dirname "$0")/../fixtures/workouts-feature.sh"
# the API decides B1.1: a coach gets "not found" for another group's workout
sed -i "s/^    if user.role == 'athlete' and workout.athlete_id != user.id:$/    if user.role == 'coach' and workout.group_id != user.group_id:\n        abort(404)\n&/" src/workouts/api.py
grep -q "user.role == 'coach' and workout.group_id" src/workouts/api.py
cat > pyproject.toml <<'TOML'
[project]
name = "coach-app"
version = "0.3.0"
requires-python = ">=3.11"
dependencies = ["flask>=3"]

[dependency-groups]
dev = ["pytest", "pytest-playwright"]

[tool.pytest.ini_options]
testpaths = ["tests"]
pythonpath = ["."]
TOML
cat > AGENTS.md <<'MD'
# coach

- API tests: `pytest tests/api` (Flask test client, log in with the `X-User` header).
- End-to-end tests: `pytest tests/e2e` (Playwright, needs `flask --app src.coach.app run`).
MD
mkdir -p tests/api tests/e2e
cat > tests/api/conftest.py <<'PY'
from types import SimpleNamespace

import pytest
from flask import g, request

from src.workouts.api import app

USERS = {
    'Anna': SimpleNamespace(id=1, role='coach', group_id='A'),
    'Ben': SimpleNamespace(id=10, role='athlete', group_id='A'),
    'Carl': SimpleNamespace(id=11, role='athlete', group_id='B'),
    'Ada': SimpleNamespace(id=2, role='admin', group_id=None),
}


@app.before_request
def log_in():
    g.user = USERS[request.headers['X-User']]


@pytest.fixture
def client():
    return app.test_client()
PY
cat > tests/api/test_workout_list.py <<'PY'
def test_coach_lists_only_her_groups_workouts(client):
    response = client.get('/workouts', headers={'X-User': 'Anna'})

    assert [w['title'] for w in response.get_json()] == ['Tempo run 5 km']


def test_athlete_lists_only_his_own_workouts(client):
    response = client.get('/workouts', headers={'X-User': 'Carl'})

    assert [w['title'] for w in response.get_json()] == ['Long run 18 km']
PY
cat > tests/e2e/test_workouts_page.py <<'PY'
from playwright.sync_api import Page, expect


def test_workouts_page_shows_each_workout_with_its_athlete(page: Page):
    page.goto('http://localhost:5000/workouts')

    expect(page.locator('#workout-1')).to_have_text('Tempo run 5 km (Ben)')
PY
