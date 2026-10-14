# Fixture: pyproject.toml with pytest and pytest-bdd, no tests yet.
# Sourced by scaffold.sh in the case folders; writes into the current dir.
cat > pyproject.toml <<'TOML'
[project]
name = "coach"
version = "0.1.0"
requires-python = ">=3.10"

[dependency-groups]
dev = ["pytest", "pytest-bdd>=8"]

[tool.pytest.ini_options]
testpaths = ["tests"]
bdd_features_base_dir = "features/"
TOML
