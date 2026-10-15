#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "$0")/../fixtures/coach-web.sh"
. "$(dirname "$0")/../fixtures/scratchpad-done.sh"
# discover proposed a split; put it before the open questions
sed -i 's/^## 🟥 Open questions$/## Split\n\n- workouts-access: R1, R2\n- workouts-admin: R3\n\n---\n\n&/' docs/discovery/2026-10-13-workouts.md
