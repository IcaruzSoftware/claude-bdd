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
