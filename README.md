# claude-bdd: Behavior-Driven Development (BDD) for Claude Code

Claude Code plugin for Behavior-Driven Development (BDD): Example Mapping discovery, Gherkin feature files as living documentation, and test generation with Cucumber, pytest-bdd or plain tests.

You turn a rough idea or untested code into confirmed business rules, then Gherkin specs, then tests, so that code and tests both follow the intent instead of each other. The three stages run strictly in order, and each starts only when you ask for it.

## Install the Claude Code BDD plugin

```
/plugin marketplace add IcaruzSoftware/claude-bdd
/plugin install bdd@claude-bdd
```

## Skills: Example Mapping, Gherkin and tests

| Skill | What it does |
|---|---|
| `/bdd:discover` | Example Mapping in writing: a Markdown scratchpad of rules, examples and questions that you correct until nothing is open. |
| `/bdd:formulate` | Turns the finished scratchpad into one Gherkin `.feature` file, then deletes the scratchpad after asking. |
| `/bdd:automate` | Turns the feature file into tests: Cucumber-style step definitions for your BDD runner, or plain tests. |

The plugin's own behaviour is specified the same way, in [`features/`](features/) (dogfooding). A real scratchpad is kept in [`docs/discovery/`](docs/discovery/).

## Worked example: from Example Mapping to Gherkin to a pytest-bdd test

Coaches lead groups of athletes and plan workouts for them. `/bdd:discover` writes a scratchpad:

```markdown
### R2 ? Coaches see only their group's workouts
Source: `src/workouts/api.py:40`
- ⚠ code probably deviates: `src/workouts/api.py:61` (detail does not filter by group)
- B2.1 The one where coach Anna opens Carl's workout from group B → not found
```

You answer, discover folds it in, and `/bdd:formulate` writes `features/workouts.feature`:

```gherkin
Feature: Workouts

  @R2
  Rule: Coaches see only their group's workouts

    @B2.1
    Example: Anna opens a workout from another group
      Given coach Anna leads group A
      And athlete Carl is in group B
      When Anna opens Carl's workout "Tempo run 5 km"
      Then she gets "not found"
```

`/bdd:automate` writes the test (pytest-bdd here; with no BDD runner it writes plain tests that name `workouts:B2.1`):

```python
@scenario('workouts.feature', "Anna opens a workout from another group")
def test_anna_opens_other_groups_workout():
    """workouts:B2.1"""
```

### Keep tests in sync: pre-commit hook and CI

In PLAIN mode (plain tests that name their example), `plugin/scripts/check_coverage.py` reports examples without a test and tests without an example. Run it as a pre-commit hook:

```yaml
repos:
  - repo: https://github.com/IcaruzSoftware/claude-bdd
    rev: v0.1.0
    hooks:
      - id: bdd-coverage
```

`rev: v0.1.0` is the first release tag. Or run it as a one-line CI step: `python3 path/to/check_coverage.py .`

It checks that a test exists, not that it is correct. That stays a review job.

In RUNNER mode you need neither: the BDD runner itself fails on a step without a definition.

## Configuration

Set the options with `/plugin configure bdd@claude-bdd`.

| Option | Default | Meaning |
|---|---|---|
| `keep_scratchpad` | `false` | Keep the discovery scratchpad after formulate instead of deleting it. |
| `ask_before_delete` | `true` | Ask before formulate deletes the scratchpad. |

## Requirements

- Claude Code
- Python 3.10+ for the coverage script

## Update and uninstall

```
/plugin marketplace update claude-bdd
/plugin uninstall bdd@claude-bdd
```

## License

[MIT](LICENSE)
