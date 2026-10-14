#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "$0")/../fixtures/coach-readme.sh"
cat > README.md <<'EOF'
# Coach app

A training app for running clubs. Coaches lead groups of athletes, athletes
log their workouts, and coaches plan the training from those workouts.
EOF
