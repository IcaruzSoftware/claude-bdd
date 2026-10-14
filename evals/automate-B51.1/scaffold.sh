#!/usr/bin/env bash
set -euo pipefail
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
cat > requirements-dev.txt <<'TXT'
behave==1.2.6
TXT
mkdir -p features/steps
cat > features/environment.py <<'PY'
from coach.workouts import Club


def before_scenario(context, scenario):
    context.club = Club()
PY
cat > features/members.feature <<'FEATURE'
Feature: Members
  The club knows its members.

  Scenario: A new athlete
    When Ben joins group A as an athlete
    Then Ben is in group A
FEATURE
cat > features/steps/members_steps.py <<'PY'
from behave import then, when


@when('{name} joins group {group} as an athlete')
def step_joins(context, name, group):
    context.club.add_member(name, 'athlete', group)


@then('{name} is in group {group}')
def step_in_group(context, name, group):
    assert context.club.members[name] == ('athlete', group)
PY
