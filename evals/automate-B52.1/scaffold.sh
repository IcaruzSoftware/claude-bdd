#!/usr/bin/env bash
set -euo pipefail
cat > pyproject.toml <<'TOML'
[project]
name = "coach"
version = "0.1.0"
requires-python = ">=3.10"

[dependency-groups]
dev = ["pytest", "pytest-bdd>=8"]

[tool.pytest.ini_options]
testpaths = ["tests"]
bdd_features_base_dir = "features/"
TOML
mkdir -p coach
: > coach/__init__.py
cat > coach/workouts.py <<'PY'
"""Workouts in a coaching club: who may see and delete which workout."""


class NotFound(Exception):
    """The workout does not exist, or the viewer may not see it."""


class Refused(Exception):
    """The user may not do this."""


class Club:
    def __init__(self):
        self.members = {}  # name -> (role, group)
        self.workouts = {}  # id -> {'athlete': name, 'title': text}

    def add_member(self, name, role, group=None):
        self.members[name] = (role, group)

    def log_workout(self, athlete, title):
        workout_id = max(self.workouts, default=0) + 1
        self.workouts[workout_id] = {'athlete': athlete, 'title': title}
        return workout_id

    def list_workouts(self, athlete):
        """The athlete's workouts, newest first."""
        ids = [i for i, w in self.workouts.items() if w['athlete'] == athlete]
        return [self.workouts[i] for i in sorted(ids, reverse=True)]

    def open_workout(self, viewer, workout_id):
        workout = self.workouts.get(workout_id)
        if workout is None or not self._may_see(viewer, workout['athlete']):
            raise NotFound(workout_id)
        return workout

    def delete_workout(self, user, workout_id):
        if self.members[user][0] not in ('admin',):
            raise Refused(user)
        del self.workouts[workout_id]

    def _may_see(self, viewer, athlete):
        role, group = self.members[viewer]
        if role == 'coach':
            return group == self.members[athlete][1]
        return viewer == athlete
PY
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
mkdir -p features
cat > features/sharing.feature <<'FEATURE'
Feature: Sharing
  Coaches share workouts with the athletes of their group.

  @R1
  Rule: A coach shares workouts only within her group

    @B1.1
    Example: Sharing with an athlete of her group
      Given coach Tom leads group B
      And Carl is an athlete in group B
      When Tom shares the workout "Intervals" with Carl
      Then Carl sees "Intervals" in his workout list

    @B1.2
    Example: Sharing with an athlete of another group
      Given coach Tom leads group B
      And Ben is an athlete in group A
      When Tom shares the workout "Intervals" with Ben
      Then Tom is refused
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
