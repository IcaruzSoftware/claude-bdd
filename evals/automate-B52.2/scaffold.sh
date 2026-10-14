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
