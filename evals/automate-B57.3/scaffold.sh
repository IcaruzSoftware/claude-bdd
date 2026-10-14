#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "$0")/../fixtures/coach-lib.sh"
. "$(dirname "$0")/../fixtures/sharing-feature.sh"
. "$(dirname "$0")/../fixtures/unittest-suite.sh"
cat > tests/test_sharing.py <<'PY'
import unittest

from coach.workouts import Refused, share_workout
from tests.helpers import make_club


class SharingTest(unittest.TestCase):
    def setUp(self):
        self.club = make_club()

    def test_athlete_of_the_group_sees_the_shared_workout(self):
        """sharing:B1_1"""
        share_workout(self.club, 'Tom', 'Intervals', 'Carl')

        self.assertIn('Intervals', [w['title'] for w in self.club.list_workouts('Carl')])

    def test_sharing_outside_the_group_is_refused(self):
        """sharing:B1_2"""
        with self.assertRaises(Refused):
            share_workout(self.club, 'Tom', 'Intervals', 'Ben')
PY
# references are written as B1_1 above, so this repo's coverage script
# does not count them as tests of its own features
sed -i -E 's/(:B[0-9]+)_([0-9]+)/\1.\2/g' tests/*.py
