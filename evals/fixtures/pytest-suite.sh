# Fixture: pyproject.toml with plain pytest, a club fixture and a pytest test suite.
# Sourced by scaffold.sh in the case folders; writes into the current dir.
cat > pyproject.toml <<'TOML'
[project]
name = "coach"
version = "0.1.0"
requires-python = ">=3.10"

[dependency-groups]
dev = ["pytest"]

[tool.pytest.ini_options]
testpaths = ["tests"]
TOML
mkdir -p tests
cat > tests/conftest.py <<'PY'
import pytest

from coach.workouts import Club


@pytest.fixture
def club():
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
def test_logged_workout_is_in_the_list(club):
    club.log_workout('Ben', 'Long run')

    assert [w['title'] for w in club.list_workouts('Ben')] == ['Long run']


def test_list_holds_only_the_athletes_own_workouts(club):
    club.log_workout('Carl', 'Intervals')

    assert club.list_workouts('Ben') == []
PY
