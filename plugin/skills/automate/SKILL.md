---
name: automate
description: >-
  Step 3 of 3 of BDD: turns a Gherkin .feature file into tests. Writes step
  definitions for the project's BDD runner (pytest-bdd, behave,
  @cucumber/cucumber, playwright-bdd, cucumber-jvm) or plain tests that name
  their example as <slug>:<ID>, runs them once and reports. Use ONLY when the
  user explicitly asks to automate a feature file, to write tests for its
  examples, or runs /bdd:automate.
---

# automate

Turns a feature file into tests.
The plugin decides what is tested: the examples.
The project decides how.

Run only this step. Never start discover or formulate from here.

The user's arguments are: `$ARGUMENTS` (a flag and a feature path, or empty).

## 1. Preconditions

1. Check this first, even when no feature file exists: look for a scratchpad for this story (in `docs/discovery/` or the project's scratchpad place).
2. No feature file for the story yet, and the scratchpad still has a `?` rule, an unaccepted `!` rule or an open F-item: name those IDs (e.g. "F2 is still open") and write no tests. Stop.
3. The feature file exists (formulate ran, maybe with "formulate anyway"): an open F-item no longer blocks. Only rules that are not confirmed matter, and their examples are tagged `@wip`. If such a rule has an example without `@wip`, name the rule ID and write no tests. Stop.
4. Exception to steps 2 and 3: the user explicitly overrides now (e.g. "write the tests anyway"). Then go on.
5. If no feature file exists (or the named one does not exist), say "No feature file found." Suggest /bdd:formulate. Stop.
6. Use the feature file named in the arguments or the user's message. If none is named and several exist, ask which one. Stop and wait.
7. An example tagged `@wip` (in the tag lines directly above its `Example:`) is work in progress. Write no test for it. List it in the report.
8. Read the project's test rules: CLAUDE.md, AGENTS.md, and any test skills or test docs. Follow them for how tests are written.

## 2. Pick the mode: RUNNER or PLAIN

0. Check this first: the user said "use <runner>". If the project already uses that runner, use RUNNER mode. Otherwise ask "Add <runner> as a dev dependency?" Stop and wait. After a yes, add it and use RUNNER mode. After a no, go on with step 1.

Then check in this order. The first match wins.

1. The project uses a BDD runner: RUNNER mode, without asking and without a notice, even if tests mention `<slug>:<ID>` references. Do not mention those references or why you chose RUNNER mode anywhere in your reply. Runners and where to see them:
   - pytest-bdd: `pytest-bdd` in pyproject.toml, requirements, setup.cfg or the lock file.
   - behave: `behave` in the dependencies, or `features/steps/`.
   - @cucumber/cucumber: in package.json.
   - playwright-bdd: in package.json.
   - cucumber-jvm: `io.cucumber` in pom.xml or build.gradle.
2. A file in a test-like place (the list in section 4, PLAIN mode) already mentions a reference like `<slug>:B<n>.<n>` (e.g. `billing:B1.1`): the project chose PLAIN mode earlier. Use PLAIN mode, without asking and without a notice. Mentions in docs or other files outside test-like places do not count. Check every test file for such a reference (e.g. Grep for `[a-z_-]+:B[0-9]+\.[0-9]+`), not just a few of them.
3. The project has a test suite but no BDD runner, and no test file mentions a `<slug>:B<n>.<n>` reference (step 2): PLAIN mode. Put this notice as one line, word for word, in your report: "<framework> suite found, writing plain tests. Say 'use <runner>' to switch." For a pytest suite exactly: "pytest suite found, writing plain tests. Say 'use pytest-bdd' to switch." Do not paraphrase it.
4. The project has no tests: ask "Install <runner>?" naming the runner that fits the language: pytest-bdd for Python, @cucumber/cucumber for JavaScript or TypeScript (playwright-bdd if Playwright is used), cucumber-jvm for Java or Kotlin. For Python exactly: "Install pytest-bdd?" Stop and wait.
   - After a yes: add the dependency and its setup, then use RUNNER mode.
   - After a no: propose the shape of the test suite as statements to confirm or correct: framework, folder layout, naming, what a test may touch. For Python exactly: "pytest, tests in tests/, one file per feature, no network". Stop and wait.
   - Fold in the user's corrections like discover does: keep the user's words, show the result again, stop and wait until the user confirms it.
   - After the confirmation: ask "Add <framework> as a dev dependency?" (for Python exactly: "Add pytest as a dev dependency?") Stop and wait. Add nothing before a yes.
   - After a yes: add it and use PLAIN mode with the confirmed shape. After a no, say "No test framework, no tests written." Stop.

Never build a second test suite next to an existing one unless the user explicitly asked for it and said yes.

## 3. Pick the direction: FORWARD or BACKWARD

The direction comes only from a flag, the same flags as discover. Never guess it from the code.

1. Look for `--forward` or `--backward` in the arguments and in the user's message.
2. No flag, or `--forward`: FORWARD.
3. `--backward`: BACKWARD. The tests lag behind the code and are added retroactively.
4. In FORWARD mode, if you notice that the examples' behaviour already exists in the code, add one line to the report: "<feature path> looks implemented already. Use --backward to add tests for it retroactively?" Stay in FORWARD mode.

## 4. Write the tests

Write one test per example. Cover every example of the feature, except the `@wip` examples.

RUNNER mode:

1. Write step definitions in the runner's own style.
2. Bind the feature file so the runner executes it (pytest-bdd: `scenarios("<path>")` or one `@scenario` per example).
3. Reuse steps through parameters, not by rewording the feature.
4. If pytest runs with `--strict-markers` (check addopts in pyproject.toml, pytest.ini, setup.cfg, tox.ini): register every `@R<n>` and `@B<n>.<n>` tag of the feature (and `wip`) as a marker in the pytest config.
5. Bind no `@wip` example, and make that last beyond this run, so a plain `pytest` or CI does not fail on it. pytest-bdd: bind one `@scenario` per example and skip the `@wip` ones, or bind the whole file and add `-m "not wip"` to pytest's `addopts` in the config. behave, cucumber: put `--tags "not @wip"` into the runner's config file.

PLAIN mode:

1. Write tests the way the project's test rules say (e.g. boundary tests at a derived seam).
2. Put the reference `<slug>:<ID>` in each test's docstring or a comment, e.g. `workouts:B3.1`. The slug is the feature file name without `.feature`.
3. Put the tests in test-like places: folders `test`, `tests`, `spec`, `__tests__`, `evals`, or file names like `test_*`, `*_test.*`, `*.test.*`, `*.spec.*`.
4. Before the run in section 5, run (PLAIN mode only; in RUNNER mode every example would show as missing) `python3 ${CLAUDE_PLUGIN_ROOT}/scripts/check_coverage.py <project root>`.
5. If it prints a line starting with `error:` (exit code 2, e.g. a duplicate slug), report that line and stop. Slugs must be unique across the repo. Run no tests.
6. `missing:` lines are examples without a test. Write the missing tests for this feature now, so the run and the report include them.
7. `wip:` lines are `@wip` examples. Write no tests for them.
8. `review:` lines are examples checked by review instead of a test. They are no gap; write no tests for them.
9. Keep the other lines (`orphan:`, `wip:`, `review:`, and `missing:` lines of other features) for section 6.

FORWARD mode:

1. The tests are expected to start red.
2. Write no production code.
3. PLAIN mode with pytest: import planned production symbols inside the test function, not at the top of the module. Then one missing symbol does not stop pytest from collecting the other tests.

BACKWARD mode:

1. Test the confirmed rule, not what the code does.
2. Never change a test or its assertion to match the code.

## 5. Run once

1. Run the tests with the project's test command.
2. Look at every red test. It must fail on the business assertion.
3. Red for the wrong reason means a fault in the test code itself: a typo, a wrong import of a test helper, a missing fixture, a setup crash, a missing marker registration. Example: `ModuleNotFoundError` for a test helper module.
4. Fix wrong reasons in the test code. Do not report those tests as red.
5. A test that fails only because the planned production symbol does not exist yet is not red for the wrong reason. This happens in FORWARD mode. First check that the test asserts exactly the example's Then; fix the test if not. Example: for "sharing:B1.1" the test must assert that Carl sees the shared workout in his list. Report it as "red: <symbol> does not exist yet", e.g. "red: share_workout does not exist yet". Never fix it by writing production code.
6. After fixing wrong reasons, run once more. Report only the last run.

## 6. Check the gaps

RUNNER mode (do not run the coverage script; runners fail on undefined steps):

1. Check that every `.feature` file in the project is bound by some test module. Report each unbound one: "<path> is not bound".
2. Compare, per feature, the number of examples that are not `@wip` with the number of scenarios the runner ran. Report each missing example by its ID.

PLAIN mode (the coverage script ran in section 4):

1. `orphan:` lines are tests that point at an example that does not exist. Report them.
2. Report the `missing:` lines of other features.
3. `wip:` lines are not gaps; list them as work in progress.
4. `review:` lines are not gaps; report them as "checked by review", e.g. "formulate:B34.2 checked by review".
5. Suggest running the script in a pre-commit hook or CI, so gaps are caught without Claude.

## 7. Report

Report once, in summary, not per example. Start with the mode, the direction and the counts, e.g. "RUNNER · FORWARD · 12 tests: 11 red, 1 green". If section 2 step 3 chose PLAIN mode, the next line is its notice, word for word.

FORWARD mode:

1. All red is the goal.
2. For every green test, look at the code and the test, and say why it is green: the behaviour exists already, or the test checks nothing. Example: "workouts:B4.2 is green: the behaviour exists already".
3. If the behaviour of every example exists already, add the `--backward` line from section 3.

BACKWARD mode:

1. Green tests confirm the rules.
2. List every red test as a finding: the reference, the rule, and what the code does instead.
3. Say for each finding: fix the code, or change the rule with /bdd:discover.

Always list the gaps from section 6.
Always list the `@wip` examples as work in progress, e.g. "wip: workouts:B4.1 (R4 not confirmed yet), no test".

## Never

- Never write production code in FORWARD mode.
- Never bend a test to fit the code; in BACKWARD mode a red test is a finding.
- Never report a test as red when it fails for the wrong reason.
- Never add a dependency or build a second suite without asking first.
- Never run the tests while the coverage script reports an `error:` line.
- Never start discover or formulate.
- Never write a test for a `@wip` example.
- Never guess the direction from the code. Only `--backward` sets BACKWARD; never switch by yourself.
- Never ask with the AskUserQuestion tool. Ask in plain text in your reply, then stop.
