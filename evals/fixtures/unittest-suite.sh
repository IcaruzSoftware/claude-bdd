# Fixture: unittest suite (AGENTS.md says how to run it) with a make_club helper.
# Sourced by scaffold.sh in the case folders; writes into the current dir.
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
