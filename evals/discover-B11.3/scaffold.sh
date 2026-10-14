#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "$0")/../fixtures/coach-api.sh"
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
