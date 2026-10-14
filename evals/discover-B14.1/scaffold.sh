#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "$0")/../fixtures/coach-readme.sh"
cat > README.md <<'EOF'
# Coach app

A training app for running clubs. Coaches lead groups of athletes, athletes
log their workouts, and coaches plan the training from those workouts.

## Groups

Every athlete belongs to one group. Athletes' training data is shared only
within their group.

Each coach leads exactly one group. A coach who takes over a second group
must hand the first one to another coach.
EOF
