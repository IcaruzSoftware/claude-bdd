#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "$0")/../fixtures/coach-readme.sh"
cat > README.md <<'EOF'
# Coach-App

Eine Trainings-App für Laufvereine. Coaches leiten Gruppen von Athleten,
Athleten erfassen ihre Workouts, und Coaches planen das Training anhand
dieser Workouts.

## Gruppen

Jeder Athlet gehört zu genau einer Gruppe. Trainingsdaten werden nur
innerhalb der Gruppe geteilt.
EOF
mkdir -p docs
cat > docs/betrieb.md <<'EOF'
# Betrieb

Die App läuft als Flask-Dienst. Konfiguration über `config.toml`, Logs unter
`/var/log/coach`. Neue Gruppen legt ein Admin im Backoffice an.
EOF
