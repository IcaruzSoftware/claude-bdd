# Contributing to claude-bdd

- Everything in this repo is English: skills, README, feature files, scratchpads, comments.
- The repo uses its own workflow: `/bdd:discover` → `/bdd:formulate` → `/bdd:automate`. The spec lives in `features/`; scratchpads live in `docs/discovery/`.
- Change behaviour by changing the feature file first, then the tests, then the skill.
- Only `plugin/` is installed (the marketplace's `source`). Spec, tests, evals and docs stay in the repo for maintainers.

## Development

```
uv sync                                # install dev dependencies
uv run pytest                          # run the tests
uv run plugin/scripts/check_coverage.py .  # every example has a test, every test an example
```

Behaviour examples that need a real Claude run are tested with `claude plugin eval` (see `evals/README.md`).
