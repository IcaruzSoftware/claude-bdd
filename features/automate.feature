Feature: Automate
  Step 3 of 3. The automate skill turns a feature file into tests. In RUNNER
  mode a BDD runner executes the feature file itself. In PLAIN mode the
  project's own tests point at the examples they cover.

  @R50
  Rule: In RUNNER mode automate writes step definitions for the project's BDD runner
    Supported runners: pytest-bdd, behave, @cucumber/cucumber, playwright-bdd, cucumber-jvm.

    @B50.1
    Example: A pytest-bdd project
      Given the project depends on pytest-bdd
      When automate runs on "features/workouts.feature"
      Then it writes pytest-bdd step definitions

  @R51
  Rule: The project's state picks the mode, and automate never builds a second suite next to an existing one
    Most people want the rules and the feature file, not a migration of their
    test suite. A question at every run would be noise; a one-line notice keeps
    the door to RUNNER mode open.

    @B51.1
    Example: A project with a BDD runner
      Given the project uses behave
      When automate runs
      Then it uses RUNNER mode without asking

    @B51.2
    Example: A project with a plain test suite
      Given the project has a pytest suite and no BDD runner
      When automate runs
      Then it uses PLAIN mode
      And says in one line "pytest suite found, writing plain tests. Say 'use pytest-bdd' to switch."

    @B51.3
    Example: A project without tests
      Given the project has no tests
      When automate runs
      Then it asks "Install pytest-bdd?"
      And uses RUNNER mode after a yes

    @B51.5
    Example: No runner wanted and no tests yet
      Given the project has no tests
      And the user said no to installing pytest-bdd
      When automate continues
      Then it proposes how the test suite should look as statements to confirm, like "pytest, tests in tests/, one file per feature, no network"
      And it adds no dependency before the user confirmed them and said yes to "Add pytest as a dev dependency?"

    @B51.6
    Example: A runner and example references together
      Given the project uses pytest-bdd
      And a test docstring says "plugin:B1.2"
      When automate runs
      Then it uses RUNNER mode without a notice

    @B51.4
    Example: The user asks for a runner in a project with a plain suite
      Given the project has a pytest suite and no BDD runner
      When the user says "use pytest-bdd"
      Then automate asks before adding the dependency
      And uses RUNNER mode after a yes

  @R60
  Rule: The repo remembers PLAIN mode through the example references in its tests

    @B60.1
    Example: The second feature in a PLAIN project
      Given a test already mentions "billing:B1.1"
      When automate runs on another feature
      Then it uses PLAIN mode without asking
      And it shows no notice

  @R52
  Rule: RUNNER mode needs no coverage script, but automate checks the gaps runners leave
    Every supported runner fails on a step without a definition. Runners do not
    notice a feature file that no test binds (pytest-bdd ignores it silently).

    @B52.1
    Example: An unbound feature file
      Given "features/sharing.feature" is not bound by any pytest-bdd test module
      When automate checks the suite
      Then it reports "features/sharing.feature" as not bound

    @B52.2
    Example: A missing scenario
      Given "features/workouts.feature" has 12 examples
      And the runner ran 11 of them
      When automate checks the suite
      Then it reports the missing example

  @R53
  Rule: In PLAIN mode every test names its example, and a script reports gaps both ways
    The reference includes the feature slug, because every feature has a B1.2.
    The script only matches text, so it works for any test language. Only files
    in test-like places count (folders test, tests, spec, specs, __tests__,
    evals; names like test_*, *_test.*, *.test.*, *.spec.*): a false "covered"
    from a document that merely mentions an example is worse than a gap. specs/
    is no test place, because discover may keep scratchpads there. The script
    reads only the project's own files: in a git repo the files git tracks or
    would track, otherwise it skips hidden folders and build output. The eval
    tool's output folder evals/results/ is never read. An example tagged
    "@review" is checked by review instead of a test and is no gap.

    @B53.1
    Example: An example without a test
      Given "workouts.feature" has the example "@B3.1"
      And no test mentions "workouts:B3.1"
      When the coverage script runs
      Then it reports "workouts:B3.1" as missing

    @B53.2
    Example: A test without an example
      Given a test mentions "workouts:B9.1"
      And "workouts.feature" has no example "@B9.1"
      When the coverage script runs
      Then it reports "workouts:B9.1" as orphan

    @B53.3
    Example: The same ID in two features
      Given "billing.feature" and "workouts.feature" both have the example "@B1.2"
      And one test mentions "billing:B1.2" and another mentions "workouts:B1.2"
      When the coverage script runs
      Then it reports no gap

    @B53.4
    Example: A document mentions an example but no test does
      Given "workouts.feature" has the example "@B3.1"
      And only "docs/notes.md" mentions "workouts:B3.1"
      When the coverage script runs
      Then it reports "workouts:B3.1" as missing

    @B53.5
    Example: A test points at a deleted feature
      Given "workouts.feature" has the example "@B1.1"
      And a test mentions "sharing:B1.1"
      And there is no "sharing.feature"
      When the coverage script runs
      Then it reports "sharing:B1.1" as orphan

    @B53.6
    Example: A work-in-progress example is no gap
      Given "workouts.feature" has the example "@B4.1" tagged "@wip"
      And no test mentions "workouts:B4.1"
      When the coverage script runs
      Then it reports "workouts:B4.1" as work in progress
      And it does not fail

    @B53.7
    Example: A copy of the features in a worktree
      Given "workouts.feature" has the example "@B1.1"
      And a copy of it lies in ".claude/worktrees/x/features/"
      And a test mentions "workouts:B1.1"
      When the coverage script runs
      Then it reports no gap

    @B53.8
    Example: An example checked by review
      Given "workouts.feature" has the example "@B1.2" tagged "@review"
      And no test mentions "workouts:B1.2"
      When the coverage script runs
      Then it reports "workouts:B1.2" as checked by review
      And it does not fail

    @B53.9
    Example: A scratchpad in specs is no test
      Given "workouts.feature" has the example "@B1.1"
      And only "specs/2026-10-13-workouts.md" mentions "workouts:B1.1"
      When the coverage script runs
      Then it reports "workouts:B1.1" as missing

  @R58
  Rule: In PLAIN mode the project's test rules decide how a test is written
    The plugin decides what is tested: the examples. The project decides how:
    its CLAUDE.md, AGENTS.md and test skills.

    @B58.1
    Example: A project with its own test rules
      Given the project's CLAUDE.md requires boundary tests at a derived seam
      When automate writes a plain test for "billing:B2.1"
      Then the test follows the boundary-test rule
      And mentions "billing:B2.1"

  @R62
  Rule: automate tests each example at the lowest level that can check its Then
    A unit or API test when code below the UI decides the outcome. An
    end-to-end UI test only when the Then is about what the UI shows or does.
    The project's test rules win (R58).

    @B62.1
    Example: A rule the API decides
      Given a web project with API tests and Playwright end-to-end tests
      And the API decides that coach Anna gets "not found" for Carl's workout
      When automate writes the test for that example
      Then it writes an API test
      And no Playwright test

  @R59
  Rule: The README shows how to run the coverage script in a pre-commit hook or in CI
    In PLAIN mode nothing else keeps spec and tests in sync without Claude.
    The script checks that a test exists, not that it tests the example
    correctly; that stays a review job.

    @B59.1
    Example: A test deleted by hand
      Given the coverage script runs as a pre-commit hook
      When someone deletes the only test for "workouts:B3.1" and commits
      Then the commit fails with "workouts:B3.1 has no test"

    @B59.2
    Example: The hook also runs on a commit that only deletes files
      When the hook definition in ".pre-commit-hooks.yaml" is read
      Then the hook runs always
      And it passes no file names

  @R54
  Rule: In BACKWARD mode a red test is a finding, never a test to bend

    @B54.1
    Example: The code breaks a confirmed rule
      Given the confirmed rule "Coaches see only their group's workouts"
      And the test for it is red because the workout detail shows any workout
      When automate reports
      Then the red test is listed as a finding
      And the test is not changed to match the code

  @R55
  Rule: In FORWARD mode tests start red and automate writes no production code

    @B55.1
    Example: A new feature
      Given no code for workout sharing exists
      When automate writes the tests for "sharing.feature"
      Then the tests are red
      And no production code was written

  @R56
  Rule: automate runs the feature's tests at most twice and reports a summary
    automate runs only the tests of the feature it automates, never the whole
    suite: once, and once more after fixing wrong reasons. In PLAIN mode these
    are the test files it wrote or changed and the existing ones that name the
    feature's examples; in RUNNER mode the runner runs only that feature. A
    test that still fails for a wrong reason after the second run is reported
    as "broken: <ref> (<error>)", not as red. When it hands the writing of
    tests to other agents, they write the tests but do not run them, and each
    brief carries the test level (R62) and the rules of R54 and R55. Sections 1
    to 3 of the skill are automate's exploration of the project: it starts no
    other exploration, and a plan the project's rules require is written from
    what it found there.

    @B56.1
    Example: A green test in FORWARD mode
      Given FORWARD mode
      And 11 of 12 tests are red and "workouts:B4.2" is green
      When automate reports
      Then it explains why "workouts:B4.2" is green: the behaviour exists already or the test checks nothing

    @B56.2
    Example: Red tests in BACKWARD mode
      Given BACKWARD mode
      And 2 of 12 tests are red
      When automate reports
      Then it lists the 2 red tests as findings

    @B56.3
    Example: A rerun after fixing a wrong reason
      Given the test for "workouts:B2.1" failed on a typo in the test
      When automate fixes the typo and runs its tests again
      Then the report shows only the second run

    @B56.4
    Example: Only the new tests run
      Given the project has the test file "tests/test_groups.py"
      When automate writes "tests/test_workouts.py" and runs it
      Then no test command runs "tests/test_groups.py"

  @R57
  Rule: A red test must be red for the right reason
    It fails on the business assertion, not on a fault in the test code itself
    (a typo, a wrong import of a test helper, a missing fixture, a setup crash).
    Otherwise a red test proves nothing. In FORWARD mode a test that fails only
    because the planned code does not exist yet is red for the right reason, as
    in classic TDD; automate still checks that it asserts exactly the example's
    Then, and never fixes it with production code.

    @B57.1
    Example: Red for the wrong reason
      Given the test for "workouts:B2.1" fails with "ModuleNotFoundError"
      When automate checks the red tests
      Then it fixes the import first
      And does not report "workouts:B2.1" as red

    @B57.3
    Example: The planned code does not exist yet
      Given FORWARD mode
      And the test for "sharing:B1.1" imports "share_workout", which does not exist yet
      When automate checks the red tests
      Then it checks that the test asserts that Carl sees the shared workout in his list
      And it reports "red: share_workout does not exist yet"
      And it writes no production code

    @B57.2
    Example: pytest-bdd with strict markers
      Given the project runs pytest with "--strict-markers"
      When automate writes pytest-bdd tests
      Then it registers the ID tags as markers

  @R61
  Rule: automate takes the direction from a flag: FORWARD by default, BACKWARD only with "--backward"
    The same flags as discover. When automate notices that the tests lag behind
    the code, it suggests "--backward" and does not switch by itself.

    @B61.1
    Example: Retroactive tests
      When the user runs "/bdd:automate --backward features/workouts.feature"
      Then automate uses BACKWARD mode

    @B61.2
    Example: The default
      When the user runs "/bdd:automate features/sharing.feature"
      Then automate uses FORWARD mode

    @B61.3
    Example: Lagging tests are noticed, not acted on
      Given every example of "features/workouts.feature" is already implemented
      When the user runs "/bdd:automate features/workouts.feature"
      Then automate uses FORWARD mode
      And it suggests in one line to use "--backward"

    @B61.4
    Example: BACKWARD travels with the work
      Given the scratchpad's mode is BACKWARD
      When the user confirms "features/workouts.feature"
      Then formulate ends with "Next step: /bdd:automate --backward features/workouts.feature"
