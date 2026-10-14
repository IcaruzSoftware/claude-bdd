#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "$0")/../fixtures/coach-web.sh"
mkdir -p docs/discovery
cat > docs/discovery/2026-10-13-workouts.md <<'EOF'
# Example Map: Workouts

🟨 **Story:** Als Coach möchte ich die Workouts meiner Athleten sehen, damit ich ihr Training planen kann.

**Mode:** FORWARD (noch kein Code für Workouts)
**Status:** 3 Regeln (1 ✓, 0 !, 2 ?) · 1 Frage offen

**How to answer:** edit this file, or reply in chat by ID, e.g. `R3: no, only admins`. A bare `ok` next to an ID confirms it. `accept all !` confirms every `!` at once.
Markers: `✓` confirmed by you · `!` Claude is sure, with evidence · `?` Claude's guess · `⚠` suspected problem.

---

## Regeln

### R1 ✓ Coaches sehen nur die Workouts ihrer Gruppe
- B1.1 Der Fall, in dem Coach Anna Carls Workout aus Gruppe B öffnet → nicht gefunden

### R3 ? Nur Admins und der Coach der eigenen Gruppe dürfen Workouts löschen
- B3.1 Der Fall, in dem Coach Anna Bens Workout "Tempolauf 5 km" löscht → erlaubt, Ben ist in ihrer Gruppe

### R2 ? Athleten sehen nur ihre eigenen Workouts
- B2.1 Der Fall, in dem Athlet Ben Carls Workout öffnet → nicht gefunden

---

## 🟥 Offene Fragen

- F1 Darf ein Coach einen Athleten in eine andere Gruppe verschieben?
EOF
