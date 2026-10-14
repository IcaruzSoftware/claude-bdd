#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "$0")/../fixtures/coach-lib.sh"
. "$(dirname "$0")/../fixtures/sharing-feature.sh"
. "$(dirname "$0")/../fixtures/pytest-bdd.sh"
mkdir -p features tests
{
  echo 'Feature: Workouts'
  echo "  An athlete's list shows every workout he logged."
  n=0
  for r in 1 2 3 4; do
    echo
    echo "  @R$r"
    echo "  Rule: An athlete's list shows every workout he logged (part $r)"
    for e in 1 2 3; do
      n=$((n + 1))
      echo
      echo "    @B$r.$e"
      echo "    Example: Ben logged $n workouts"
      echo "      Given Ben logged $n workouts"
      echo '      When Ben opens his list'
      echo "      Then he sees $n workouts"
    done
  done
} > features/workouts.feature
cat > tests/test_workouts.py <<'PY'
import pytest
from pytest_bdd import given, parsers, scenario, then, when

from coach.workouts import Club


@pytest.fixture
def club():
    club = Club()
    club.add_member('Ben', 'athlete', 'A')
    return club


@given(parsers.parse('Ben logged {n:d} workouts'))
def ben_logged(club, n):
    for i in range(n):
        club.log_workout('Ben', f'Run {i}')


@when('Ben opens his list', target_fixture='workouts')
def opens_list(club):
    return club.list_workouts('Ben')


@then(parsers.parse('he sees {n:d} workouts'))
def sees(workouts, n):
    assert len(workouts) == n
PY
for n in 1 2 3 4 5 7 8 9 10 11 12; do
  cat >> tests/test_workouts.py <<PY


@scenario('workouts.feature', 'Ben logged $n workouts')
def test_ben_logged_${n}_workouts():
    pass
PY
done
