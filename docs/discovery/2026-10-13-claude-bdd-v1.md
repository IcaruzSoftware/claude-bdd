# Example Map: claude-bdd v1

🟨 **Story:** As a developer working with Claude Code, I want to turn a rough idea or untested code into confirmed business rules, then Gherkin specs, then tests, so that code and tests both follow the intent instead of each other.

**Mode:** FORWARD (plugin does not exist yet)
**Status:** 45 rules (45 ✓, 0 !, 0 ?) · 0 questions open · formulated into `features/*.feature` on 2026-10-13 · kept on purpose as a worked example (R34 `keep_scratchpad`)

**How to answer:** edit this file, or reply in chat by ID, e.g. `R12: no, ask first`. A bare `ok` next to an ID confirms it. `accept all !` confirms every `!` at once.
Markers: `✓` confirmed by you · `!` Claude is sure, with evidence · `?` Claude's guess · `⚠` suspected problem.

---

## Plugin shape

### R1 ✓ Repo `claude-bdd`, marketplace `claude-bdd`, plugin `bdd` with three skills: `bdd:discover`, `bdd:formulate`, `bdd:automate`
- B1.1 The one where the user types `/bdd:automate` → only the automation step runs, nothing else
- B1.2 The one where the user installs it → `/plugin install bdd@claude-bdd`; "claude-" helps people find the repo, but would be noise in every command

### R2 ✓ Everything in the repo is English
- B2.1 The one where the user chats in German → repo files (skills, README, feature files) are still English

### R3 ✓ The repo is its own marketplace (`.claude-plugin/marketplace.json`) and installs with two commands
- B3.1 The one where a stranger finds the repo on GitHub → `/plugin marketplace add IcaruzSoftware/claude-bdd`, then `/plugin install bdd@claude-bdd`

### R4 ✓ The plugin ships no slash commands of its own. Claude Code always namespaces plugin skills as `plugin:skill`, so extra commands would only be duplicates
- B4.1 The one where the user looks for `/bdd-discover` → does not exist, `/bdd:discover` does

### R5 ✓ The personal skill `~/.claude/skills/example-mapping` is deleted once the plugin is installed, so two skills do not fight over the same trigger

### R6 ✓ The plugin's own behaviour is specified in `features/bdd.feature` at the repo root (dogfooding: this scratchpad becomes that file)
Evidence: `features/` is the default of behave (required) and cucumber-js (`features/**/*.feature`); pytest-bdd and playwright-bdd point there with one setting. No primary source favours `docs/`. Same rule as R36.
→ became four files `features/{plugin,discover,formulate,automate}.feature` (split by R18)

### R7 ✓ The README follows the shape of popular plugin READMEs, plus one short worked example
Evidence: obra/superpowers, anthropics/skills, anthropics/claude-plugins-official share: pitch → install near the top → list of skills → workflow → configuration → license. None has a demo, but this plugin's value only shows in an example.
- B7.2 The one where someone searches GitHub or Google for "Claude Code BDD" or "example mapping" → the title, the first lines and the headings carry those terms, so the README is found (same terms as the repo description and topics)
- B7.1 Outline: pitch · install (2 commands) · table of the three skills · example (coach / athletes / workouts: scratchpad excerpt → `.feature` excerpt → test excerpt) · configuration (R34, R35) · requirements · update/uninstall · license

---

## Step 1 · `bdd:discover`

### R10 ✓ discover writes a Markdown scratchpad with statements, examples and questions; the user corrects it; Claude folds the answers in; repeat until nothing is open
- B10.1 The one where the user answers `R3: no, only admins` in chat → R3 is rewritten, marked ✓, follow-up questions appended as new F-items

### R11 ✓ Two modes: FORWARD (idea, no code) and BACKWARD (code exists, tests missing)

### R12 ✓ BACKWARD: code is a witness, not a judge. A rule derived from code is at most `?`, unless docs or a ticket back it. Suspicious code gets a `⚠ code probably deviates` line with `path:line`
- B12.1 The one where the list endpoint filters by group but the detail endpoint does not → rule marked `?`, plus a ⚠ line pointing at the detail endpoint

### R13 ✓ Statements instead of open questions. A red question only when Claude cannot make a sensible guess

### R14 ✓ Markers per rule: `✓` (only the user sets it), `!` (Claude sure, names evidence), `?` (guess)

### R15 ✓ IDs are stable (`R1`, `B1.1`, `F1`) and never renumbered. Dropped items stay struck through with a reason

### R16 ✓ Rules are ordered by risk: uncertain and expensive-if-wrong first (permissions, money, data loss)

### R17 ✓ Examples are concrete (real names and values), titled "The one where …", and have no Given/When/Then yet

### R18 ✓ Wynne's signals: many questions → idea not ready, say so; more than ~12 rules → propose splitting the story; cap ~50 items per scratchpad

### R19 ✓ If a `.feature` already exists for the topic, discover starts from it and writes a delta scratchpad: only changes and new questions
- B19.1 The one where the coach rule changes to "coaches also see workouts of their substitutes' groups" → scratchpad lists only R1 changed plus questions about it, not the whole feature again

### R20 ✓ The scratchpad lives at `docs/discovery/<YYYY-MM-DD>-<slug>.md`, unless the project already uses another place
- B20.1 The one where the project has a `specs/` folder with scratchpads → discover uses that

### R21 ✓ Answers are accepted both ways: written into the file or given in chat by ID
- B21.1 The one where the user edits R3 in the file and also answers F2 in chat → both are folded in

### R22 ✓ The stages run strictly in order: discover until nothing is open → formulate → code and tests. discover writes no code and no tests while questions are open, unless the user explicitly says so

### R23 ✓ discover starts only on explicit request ("example mapping", "discover", `/bdd:discover`, "write me the scratchpad"). It is a tool, not a virus; whoever wants it by default can add a hook
- B23.1 The one where the user says "add a delete button" → no scratchpad, normal work

### R24 ✓ (from F3) discover may suggest itself in one line when the user describes a feature with several rules ("Want an example map first?"). It never starts on its own and suggests at most once per conversation
- B24.1 The one where the user says "coaches should manage groups, invite athletes and see their workouts" → one-line suggestion, then normal work if ignored

### R25 ✓ (from F2) The scratchpad is English by default. If the user writes in another language or the repo is in another language, discover asks once which language to use
- B25.1 The one where the user writes in German → "Scratchpad in German or English?"

---

## Step 2 · `bdd:formulate`

### R30 ✓ formulate turns a finished scratchpad into a `.feature` file. Only confirmed content goes in

### R31 ✓ formulate refuses while any `?` or open F-item is left. `!` items count as confirmed only if the user says so (e.g. "accept all !")
- B31.1 The one where R4 is still `?` → formulate stops and lists R4

### R32 ✓ Each Example gets its ID as a tag, e.g. `@B1.2`. Rules keep their ID too

### R33 ✓ Rule IDs are tags on `Rule:` (`@R1`), the same way as examples. Rule titles stay clean
Evidence: tested locally with pytest-bdd 9.0, behave 1.3.3, cucumber-js 13.3: all accept tags on `Rule:` and pass them to the scenarios; dotted tags like `@B1.2` work in tag filters. playwright-bdd 2.x and cucumber-jvm support it per source/docs.
- ⚠ pytest-bdd with `--strict-markers` needs every tag registered as a marker → see R57
- ~~Rule IDs in the rule title~~ dropped: the premise ("not every runner supports Rule tags") was wrong

### R34 ✓ After formulate is done and the user has confirmed the `.feature`, the scratchpad is deleted. The reasoning worth keeping ("why this rule") moves into the free-text description under `Rule:`. Plugin option `keep_scratchpad` (default `false`) keeps it instead
- B34.1 The one where the user confirms the `.feature` → scratchpad deleted
- B34.2 The one where `keep_scratchpad` is `true` → scratchpad stays
- Mechanism: `userConfig` in `plugin.json`, set via `/plugin configure bdd@claude-bdd`, read in SKILL.md as `${user_config.keep_scratchpad}`. Per user, not per project.

### R35 ✓ formulate asks before deleting the scratchpad. Plugin option `ask_before_delete` (default `true`) turns the question off

### R36 ✓ One `.feature` per story at `features/<slug>.feature`, unless the project already has a feature location
Evidence: see R6.
- B36.1 The one where a Java project keeps features in `src/test/resources/…` → formulate writes there

### R40 ✓ In a monorepo, the `.feature` lives in the module it describes: `<module>/features/<slug>.feature`, not one `features/` folder at the root
- B40.1 The one in the first real user's monorepo about the invoice assistant → `billing_assistant/features/<slug>.feature`

### R37 ✓ Gherkin is English by default. If the repo is in another language, formulate asks whether to use that language (`# language: de`) or English

### R38 ✓ Steps are declarative and in domain language: no clicks, URLs, selectors or SQL
- B38.1 Good: `When Anna opens Carl's workout` · Bad: `When I click "#workout-42"`

### R39 ✓ formulate uses the project's existing domain vocabulary consistently (same word for the same concept). Readability beats step reuse: wording is never bent just so an existing step matches; reuse happens in the step code through parameters
Evidence: Seb Rose, "Keep your scenarios BRIEF" (B = business language); Cucumber docs, anti-patterns and step organisation; Liz Keogh on custom DSLs.
- B39.1 The one where existing features say "coach", not "trainer" → new examples say "coach"

---

## Step 3 · `bdd:automate`

### R50 ✓ automate turns a `.feature` into tests. It detects the project's BDD runner (pytest-bdd, behave, @cucumber/cucumber, playwright-bdd, cucumber-jvm) and writes step definitions for it
- B50.1 The one where the project has `pytest-bdd` in its dependencies → step definitions in pytest-bdd style

### R51 ✓ The project's state picks the mode, no setting needed: BDD runner present → RUNNER. Test suite but no BDD runner → PLAIN, fitting into the existing suite. No tests at all → RUNNER, after asking before installing it. automate never builds a second suite next to an existing one unless the user explicitly asks
- B51.1 The one where the project already uses behave → RUNNER mode, no question
- B51.2 The one where the project has a pytest suite (the first real user) → PLAIN mode, with a one-line notice: "pytest suite found, writing plain tests. Say 'use pytest-bdd' to switch."
- B51.3 The one where the project is new and has no tests → "Install pytest-bdd?" → RUNNER mode
- B51.4 The one where the user says "use pytest-bdd" in a project with a pytest suite → asks before adding the dependency, then RUNNER mode
- ~~RUNNER always default, ask to switch when a suite exists~~ dropped: a question at every run is noise; a notice keeps the door open

### R60 ✓ The repo remembers the choice: if tests with `<slug>:<ID>` references already exist, the project chose PLAIN mode earlier and automate does not ask again. No setting needed
- B60.1 The one at the first real user, second feature → PLAIN mode straight away, because `billing:B1.1` already appears in a test

### R52 ✓ RUNNER mode needs no coverage script. Every runner already fails on steps without a definition. automate checks the two gaps runners do not catch: every `.feature` is actually bound (pytest-bdd silently ignores unbound files), and the number of scenarios run equals the number of Examples
Evidence: verified locally for pytest-bdd, behave, cucumber-js; docs for playwright-bdd (`missingSteps: 'fail-on-gen'`) and cucumber-jvm (strict since v7).

### R53 ✓ (from F5) PLAIN mode is part of V1, because the first real user gets no BDD runner. Each plain test names its example in a docstring or comment as `<feature-slug>:<ID>`. A Python-stdlib script shipped with the plugin compares `.feature` files with test files and reports examples without a test and tests pointing at a missing example
- B53.1 The one where `workouts.feature` has `@B3.1` and no test mentions `workouts:B3.1` → reported as missing
- B53.2 The one where a test mentions `workouts:B9.1` but the feature has no `@B9.1` → reported as orphan
- B53.3 The one where `billing.feature` and `workouts.feature` both have `@B1.2` → no clash, because the reference includes the slug
- The script only matches text, so it works for any test language

### R58 ✓ In PLAIN mode the project's own test rules win: automate reads CLAUDE.md, AGENTS.md and test skills and writes tests their way. The plugin decides *what* is tested (the examples), the project decides *how*
- B58.1 The one at the first real user → tests follow its rules for boundary tests at a derived seam from its test skill, and each one carries its `<slug>:<ID>` reference

### R59 ✓ The README shows how to run the coverage script as a pre-commit hook or CI step, so a stale `.feature` is caught without Claude. In PLAIN mode nothing else keeps spec and tests in sync
- B59.1 The one where someone deletes a test by hand → the next commit fails with "workouts:B3.1 has no test"
- Limit: the script checks that a test exists, not that it tests the example correctly; that stays a review job

### R54 ✓ BACKWARD: a red test is information, not a broken test. The test is never bent to fit the code; the case goes back to discover

### R55 ✓ FORWARD: tests are expected to be red at first (TDD). automate writes no production code

### R56 ✓ automate runs the suite once and reports in summary, not per example
- FORWARD: all red is the goal. A green test is looked at: either the behaviour already exists or the test checks nothing
- BACKWARD: the red tests are the findings and are listed
- B56.1 The one where 11 of 12 are red and B4.2 is green → automate looks at B4.2 and reports why it is green

### R57 ✓ A red test must be red for the right reason: it fails on the business assertion, not on an import error, missing fixture or setup crash. A test red for the wrong reason is fixed before reporting
Evidence: standard TDD practice ("see it fail for the right reason"); without it, a red test proves nothing.
- B57.1 The one where B2.1 fails with `ModuleNotFoundError` → fixed first, not reported as red
- ⚠ pytest-bdd with `--strict-markers`: automate registers the ID tags as markers, otherwise every test is red for the wrong reason

---

## 🟥 Open questions

None open.

- ~~F1~~ → R3 (IcaruzSoftware)
- ~~F2~~ → R25
- ~~F3~~ → R24
- ~~F4~~ Python is fine as a requirement → R53
- ~~F5~~ plain tests are in V1, the first real user needs them → R53, R58

## Dropped / deferred

- ~~Gherkin as the scratchpad format~~ dropped: full Given/When/Then makes the review list ~4× longer; Markdown scratchpad + separate `.feature` instead
- ~~`--create-tests` flag~~ dropped: replaced by the separate `bdd:automate` skill
