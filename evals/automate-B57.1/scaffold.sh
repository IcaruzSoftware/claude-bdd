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
FEATURE
cat > tests/test_workouts.py <<'PY'
import unittest

from coach.workouts import NotFound, Refused
from tests.helpers import make_club


class WorkoutsTest(unittest.TestCase):
    def setUp(self):
        self.club = make_club()

    def test_coach_gets_not_found_for_another_groups_workout(self):
        """workouts:B1_1"""
        workout_id = self.club.log_workout('Carl', 'Intervals')

        with self.assertRaises(NotFound):
            self.club.open_workout('Anna', workout_id)

    def test_coach_sees_her_groups_workout(self):
        """workouts:B1_2"""
        workout_id = self.club.log_workout('Ben', 'Long run')

        self.assertEqual(self.club.open_workout('Anna', workout_id)['title'], 'Long run')

    def test_athlete_gets_not_found_for_another_athletes_workout(self):
        """workouts:B2_1"""
        from tests.helper import make_club

        club = make_club()
        workout_id = club.log_workout('Carl', 'Intervals')

        with self.assertRaises(NotFound):
            club.open_workout('Ben', workout_id)

    def test_coach_may_not_delete_a_workout(self):
        """workouts:B3_1"""
        workout_id = self.club.log_workout('Ben', 'Long run')

        with self.assertRaises(Refused):
            self.club.delete_workout('Anna', workout_id)
        self.assertEqual(len(self.club.list_workouts('Ben')), 1)
PY
# references are written as B1_1 above, so this repo's coverage script
# does not count them as tests of its own features
sed -i -E 's/(:B[0-9]+)_([0-9]+)/\1.\2/g' tests/*.py
