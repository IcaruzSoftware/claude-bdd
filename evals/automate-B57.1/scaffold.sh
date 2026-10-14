#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "$0")/../fixtures/coach-lib.sh"
. "$(dirname "$0")/../fixtures/workouts-feature.sh"
. "$(dirname "$0")/../fixtures/unittest-suite.sh"
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
