# Fixture: Coach app with a small Flask web app in src/coach (no tests).
# Sourced by scaffold.sh in the case folders; writes into the current dir.
. "$(dirname "${BASH_SOURCE[0]}")/coach-readme.sh"
mkdir -p src/coach
cat > src/coach/__init__.py <<'EOF'

EOF
mkdir -p src/coach
cat > src/coach/app.py <<'EOF'
"""Coach app: groups, athletes and workouts."""

from flask import Flask, render_template

app = Flask(__name__)

WORKOUTS = [
    {'id': 1, 'title': 'Tempo run 5 km', 'athlete': 'Ben'},
    {'id': 2, 'title': 'Long run 18 km', 'athlete': 'Carl'},
]


@app.get('/workouts')
def workouts():
    return render_template('workouts.html', workouts=WORKOUTS)
EOF
mkdir -p src/coach/templates
cat > src/coach/templates/workouts.html <<'EOF'
<ul class="workouts">
  {% for w in workouts %}
  <li id="workout-{{ w.id }}">{{ w.title }} ({{ w.athlete }})</li>
  {% endfor %}
</ul>
EOF
