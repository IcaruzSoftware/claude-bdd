#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "$0")/../fixtures/coach-lib.sh"
. "$(dirname "$0")/../fixtures/workouts-feature.sh"
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
