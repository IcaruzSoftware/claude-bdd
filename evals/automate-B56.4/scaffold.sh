#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "$0")/../fixtures/coach-lib.sh"
. "$(dirname "$0")/../fixtures/workouts-feature.sh"
. "$(dirname "$0")/../fixtures/unittest-suite.sh"
cat > tests/test_groups.py <<'PY'
import unittest

from tests.helpers import make_club


class GroupsTest(unittest.TestCase):
    def setUp(self):
        self.club = make_club()

    def test_coach_leads_one_group(self):
        self.assertEqual(self.club.members['Anna'], ('coach', 'A'))

    def test_admin_has_no_group(self):
        self.assertEqual(self.club.members['Ada'], ('admin', None))
PY
