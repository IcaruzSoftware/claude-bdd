#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "$0")/../fixtures/coach-lib.sh"
. "$(dirname "$0")/../fixtures/workouts-feature.sh"
. "$(dirname "$0")/../fixtures/pytest-bdd.sh"
mkdir -p tests
cat > tests/test_club.py <<'PY'
from coach.workouts import Club


def test_logged_workout_is_in_the_list():
    """plugin:B1_2"""
    club = Club()
    club.add_member('Ben', 'athlete', 'A')
    club.log_workout('Ben', 'Long run')

    assert [w['title'] for w in club.list_workouts('Ben')] == ['Long run']
PY
# references are written as B1_1 above, so this repo's coverage script
# does not count them as tests of its own features
sed -i -E 's/(:B[0-9]+)_([0-9]+)/\1.\2/g' tests/*.py
