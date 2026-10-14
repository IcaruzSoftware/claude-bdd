#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "$0")/../fixtures/coach-api.sh"
. "$(dirname "$0")/../fixtures/scratchpad-f2-open.sh"
mkdir -p tests
cat > tests/__init__.py <<'EOF'

EOF
mkdir -p tests
cat > tests/test_store.py <<'EOF'
from src.workouts.store import WORKOUTS


def test_store_has_workouts():
    assert len(WORKOUTS) == 2
EOF
