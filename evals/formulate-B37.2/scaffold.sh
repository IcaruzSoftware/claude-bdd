#!/usr/bin/env bash
set -euo pipefail
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
cat > pyproject.toml <<'EOF'
[project]
name = "coach-app"
version = "0.3.0"
requires-python = ">=3.11"
dependencies = ["flask>=3"]

[dependency-groups]
dev = ["pytest"]
EOF
mkdir -p docs/discovery
cat > docs/discovery/2026-10-13-workouts.md <<'EOF'
# Example Map: Workouts

🟨 **Story:** Als Coach möchte ich die Workouts meiner Athleten sehen, damit ich ihr Training planen kann.

**Mode:** FORWARD (noch kein Code für Workouts)
**Status:** 2 Regeln (2 ✓, 0 !, 0 ?) · 0 Fragen offen

**How to answer:** edit this file, or reply in chat by ID, e.g. `R3: no, only admins`. A bare `ok` next to an ID confirms it. `accept all !` confirms every `!` at once.
Markers: `✓` confirmed by you · `!` Claude is sure, with evidence · `?` Claude's guess · `⚠` suspected problem.

---

## Regeln

### R1 ✓ Coaches sehen nur die Workouts ihrer Gruppe
Begründung: README.md, Abschnitt "Gruppen"
- B1.1 Der Fall, in dem Coach Anna Carls Workout aus Gruppe B öffnet → nicht gefunden

### R2 ✓ Nur Admins dürfen Workouts löschen
Begründung: gelöschte Workouts lassen sich nicht wiederherstellen
- B2.1 Der Fall, in dem Coach Anna Bens Workout löscht → abgelehnt, das Workout bleibt

---

## 🟥 Offene Fragen

Keine offen.
EOF
