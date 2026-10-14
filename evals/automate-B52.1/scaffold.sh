#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "$0")/../fixtures/coach-lib.sh"
. "$(dirname "$0")/../fixtures/sharing-feature.sh"
. "$(dirname "$0")/../fixtures/pytest-bdd.sh"
mkdir -p features
cat > features/workouts.feature <<'FEATURE'
Feature: Workouts
  Coaches plan training from their athletes' workouts.

  @R1
  Rule: Coaches see only their group's workouts

    @B1.1
    Example: A workout from another group
      Given coach Anna leads group A
      And Carl from group B logged a workout
      When Anna opens Carl's workout
      Then she gets "not found"

    @B1.2
    Example: A workout from her own group
      Given coach Anna leads group A
      And Ben from group A logged a workout
      When Anna opens Ben's workout
      Then she sees it
FEATURE
mkdir -p tests
cat > tests/test_workouts.py <<'PY'
import pytest
from pytest_bdd import given, parsers, scenarios, then, when

from coach.workouts import Club, NotFound

scenarios('workouts.feature')


@pytest.fixture
def club():
    club = Club()
    club.add_member('Ben', 'athlete', 'A')
    club.add_member('Carl', 'athlete', 'B')
    return club


@given(parsers.parse('coach {coach} leads group {group}'))
def coach_leads(club, coach, group):
    club.add_member(coach, 'coach', group)


@given(parsers.parse('{athlete} from group {group} logged a workout'), target_fixture='workout_id')
def athlete_logged(club, athlete):
    return club.log_workout(athlete, 'Long run')


@when(parsers.parse("{viewer} opens {athlete}'s workout"), target_fixture='outcome')
def opens(club, viewer, workout_id):
    try:
        return club.open_workout(viewer, workout_id)
    except NotFound:
        return 'not found'


@then('she gets "not found"')
def gets_not_found(outcome):
    assert outcome == 'not found'


@then('she sees it')
def sees_it(outcome):
    assert outcome['title'] == 'Long run'
PY
