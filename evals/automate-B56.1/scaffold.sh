#!/usr/bin/env bash
set -euo pipefail
cat > AGENTS.md <<'MD'
# coach

Run the tests with `python3 -m unittest`.
MD
mkdir -p tests
: > tests/__init__.py
cat > tests/helpers.py <<'PY'
from coach.workouts import Club


def make_club():
    """Anna coaches group A, Tom group B; Ben is in A, Carl in B; Ada is admin."""
    club = Club()
    club.add_member('Anna', 'coach', 'A')
    club.add_member('Tom', 'coach', 'B')
    club.add_member('Ben', 'athlete', 'A')
    club.add_member('Carl', 'athlete', 'B')
    club.add_member('Ada', 'admin')
    return club
PY
cat > tests/test_club.py <<'PY'
import unittest

from tests.helpers import make_club


class ClubTest(unittest.TestCase):
    def setUp(self):
        self.club = make_club()

    def test_logged_workout_is_in_the_list(self):
        self.club.log_workout('Ben', 'Long run')

        self.assertEqual([w['title'] for w in self.club.list_workouts('Ben')], ['Long run'])

    def test_list_holds_only_the_athletes_own_workouts(self):
        self.club.log_workout('Carl', 'Intervals')

        self.assertEqual(self.club.list_workouts('Ben'), [])
PY
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

  @R2
  Rule: Athletes see only their own workouts

    @B2.1
    Example: Another athlete's workout
      Given Carl logged a workout
      When athlete Ben opens Carl's workout
      Then he gets "not found"

  @R3
  Rule: Only admins delete workouts

    @B3.1
    Example: A coach deletes a workout
      Given Ben logged a workout
      When coach Anna deletes it
      Then she is refused
      And the workout still exists

    @B3.2
    Example: An admin deletes a workout
      Given Ben logged a workout
      When admin Ada deletes it
      Then the workout is gone

  @R4
  Rule: An athlete's list shows the newest workouts first, ten per page

    @B4.1
    Example: More than ten workouts
      Given Ben logged 12 workouts
      When Ben opens the first page of his list
      Then he sees his 10 newest workouts

    @B4.2
    Example: The newest workout comes first
      Given Ben logged "Long run" on Monday and "Intervals" on Tuesday
      When Ben opens his list
      Then "Intervals" comes before "Long run"
FEATURE
