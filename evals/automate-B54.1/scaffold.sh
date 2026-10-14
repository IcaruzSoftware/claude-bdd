#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "$0")/../fixtures/coach-lib.sh"
. "$(dirname "$0")/../fixtures/workouts-feature.sh"
. "$(dirname "$0")/../fixtures/unittest-suite.sh"
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
            return True
        return viewer == athlete
PY
