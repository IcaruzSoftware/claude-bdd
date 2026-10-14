# Example Map: gaps found while building v1

🟨 **Story:** As the maintainer, I want the gaps found while building and reviewing the skills written into the spec, so that `features/*.feature` and the skills say the same thing.

**Mode:** BACKWARD (code: `skills/*/SKILL.md`, tests: `tests/`, `evals/`)
**Delta to:** `features/discover.feature`, `features/formulate.feature`, `features/automate.feature`
**Status:** 10 rules (10 ✓) · 0 questions open · formulated into features on 2026-10-13

**How to answer:** edit this file, or reply in chat by ID, e.g. `R11: ok`. `accept all !` confirms every `!` at once.
Markers: `✓` confirmed by you · `!` Claude is sure, with evidence · `?` Claude's guess · `⚠` suspected problem.

Rule IDs are the IDs in the feature files. New examples take the next free number under their rule.

---

## discover.feature

### R11 ✓ (changed) The mode is chosen by a flag, never guessed. FORWARD is the default (new behaviour, no matter whether code or tests exist); `--forward` states it explicitly. BACKWARD runs only with an explicit `--backward`: tests lag behind the code and are added retroactively. If Claude notices on the way that the tests lag behind the code, it suggests `--backward` in one line and does not switch by itself
- B11.1 (unchanged) The one where no code for workout sharing exists → FORWARD
- B11.2 (changed) The one where the user runs `/bdd:discover --backward` for the workouts API → BACKWARD, every rule names the code it was derived from
- B11.3 The one where the workouts API exists with tests and the user runs `/bdd:discover` for "coaches also see their substitutes' groups" → FORWARD: new behaviour on existing code
- B11.4 The one where the user runs `/bdd:discover` for the workouts API, which is implemented but has no tests → FORWARD, plus one line: "The workouts API already exists without tests. Use --backward to add tests for it retroactively?"
- ~~"code exists → BACKWARD"~~ dropped: existing code says nothing about whether the user wants new behaviour
- ~~mode guessed from the code~~ dropped: a flag is explicit and testable

### R10 ✓ Calling discover again on an existing scratchpad only folds the answers into its statements and questions
- B10.3 The one where the user edited R3 in the file and calls `/bdd:discover` again → the edit is kept, no language question, the scratchpad is not rewritten

### R21 ✓ A rule the user rewrote in the file counts as confirmed
- B21.2 The one where the user changes R3 in the file to "Only admins delete workouts" → R3 keeps that text and is marked ✓

### R25 ✓ discover also asks about the language when the repo is not English
- B25.2 The one where the user writes English but the repo docs are German → asks once "Scratchpad in German or English?"

### R22 ✓ (changed) "Write the tests anyway" needs a working end
Today: the user overrides an open question, discover hands over to automate, automate needs a feature file, formulate refuses while anything is open → nothing happens.
Proposal: formulate writes the feature anyway; every example of a rule that is not confirmed yet is tagged `@wip` ("work in progress"). automate writes no test for `@wip` examples and lists them; the coverage script reports them as `wip:`, not `missing:`. Once the rule is confirmed, the tag is removed and the test is written.
- B22.2 (changed) The one where R4 is still `?` and the user says "write the tests anyway" → feature written, R4's examples tagged `@wip`, tests for R1–R3 only
- B22.3 The one where F2 is open and the user runs `/bdd:automate` without overriding → automate names F2 and writes no tests
- B53.6 (automate.feature) The one where `@B4.1` is tagged `@wip` and has no test → the coverage script reports `wip: workouts:B4.1`, not missing, and does not fail

---

## automate.feature

### R61 ✓ (new) automate uses the same flags as discover: FORWARD by default or with `--forward`, BACKWARD only with `--backward`. If automate notices that the tests lag behind the code, it suggests `--backward` in one line and does not switch by itself
- B61.1 The one where the user runs `/bdd:automate --backward features/workouts.feature` → BACKWARD: red tests are findings
- B61.2 The one where the user runs `/bdd:automate features/sharing.feature` → FORWARD
- B61.3 The one where the user runs `/bdd:automate features/workouts.feature`, and every example's behaviour already exists in the code → FORWARD, plus one line suggesting `--backward`
- ~~direction from the scratchpad's mode line or the user's words~~ dropped: a flag is explicit

### R51 ✓ (extended) Saying no to the runner in a project without tests starts a short discovery of the test suite: automate asks how the suite should look (framework, folder layout, naming, what a test may touch), statement-first like discover, and adds nothing before the user confirmed it
- B51.5 The one where the project has no tests and the user says no to pytest-bdd → automate proposes "pytest, tests in `tests/`, one file per feature, no network" as statements to confirm or correct → after confirmation it asks "Add pytest as a dev dependency?" → PLAIN mode

### R51 ✓ (extended) A project with a BDD runner and `<slug>:<ID>` references in its tests uses RUNNER mode
- B51.6 The one where the project uses pytest-bdd and a test docstring says `plugin:B1.2` → RUNNER mode, no notice

### R56 ✓ (extended) After fixing tests that were red for the wrong reason, automate runs once more and reports only the last run
- B56.3 The one where B2.1 fails on a typo in the test, automate fixes it and reruns → the report shows only the rerun

### R57 ✓ (extended) In FORWARD mode a test that fails only because the planned code does not exist yet is red for the right reason. automate still checks that the test's intention is right: it asserts exactly the example's Then. It is reported as "red: <symbol> does not exist yet" and never fixed with production code
- B57.3 The one where the test imports `share_workout`, which does not exist yet → automate checks the test asserts "Carl sees the workout in his list", reports "red: share_workout does not exist yet", writes no production code

---

## 🟥 Open questions

None open.

- ~~F1~~ option (a): `@wip` → R22

## Moved elsewhere

- Your note on R22 about PLAIN mode ("tests must fit into the existing suite, and a separate check must judge correctness and how well they blend in") is about how we test automate, not about R22 → added to `2026-10-13-evals.md` as R13.

## Already fixed without a question

- B34.1 now says "And ask_before_delete is off": with the default (on), formulate asks first (B35.1), so the old example contradicted B35.1.
