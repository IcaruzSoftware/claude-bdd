#!/usr/bin/env bash
set -euo pipefail
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
mkdir -p billing
: > billing/__init__.py
cat > billing/service.py <<'PY'
"""Draft invoices from billable hours."""

HOURLY_RATE = {'standard': 120, 'senior': 150}


def draft_invoice(client, entries):
    """entries: (hours, level) pairs. Returns the draft the client will see."""
    lines = [_line(hours, level) for hours, level in entries]
    return {'client': client, 'lines': lines, 'total': sum(line['amount'] for line in lines)}


def _line(hours, level):
    rate = _hourly_rate(level)
    return {'hours': hours, 'rate': rate, 'amount': hours * rate}


def _hourly_rate(level):
    return HOURLY_RATE[level]
PY
mkdir -p features
cat > features/billing.feature <<'FEATURE'
Feature: Invoice assistant
  The invoice assistant drafts invoices from billable hours.

  @R1
  Rule: A draft invoice has one line per billable entry

    @B1.1
    Example: Two entries
      Given Mia has 2 standard hours and 1 senior hour
      When the assistant drafts her invoice
      Then the draft has 2 lines

  @R2
  Rule: The total is the hours times the hourly rate of their level

    @B2.1
    Example: Senior hours cost more
      Given Mia has 2 standard hours and 1 senior hour
      And the rates are 120 EUR standard and 150 EUR senior
      When the assistant drafts her invoice
      Then the total is 390 EUR
FEATURE
cat > tests/test_billing.py <<'PY'
from billing.service import draft_invoice


def test_draft_has_one_line_per_entry():
    """billing:B1_1"""
    draft = draft_invoice('Mia', [(2, 'standard'), (1, 'senior')])

    assert len(draft['lines']) == 2
PY
# references are written as B1_1 above, so this repo's coverage script
# does not count them as tests of its own features
sed -i -E 's/(:B[0-9]+)_([0-9]+)/\1.\2/g' tests/*.py
