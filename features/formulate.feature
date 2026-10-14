Feature: Formulate
  Step 2 of 3. The formulate skill turns a finished scratchpad into a Gherkin
  feature file. The feature file is the lasting, readable statement of the
  business rules in the repo; the scratchpad was only for thinking.

  @R30
  Rule: Only confirmed content goes into the feature file

    @B30.1
    Example: A finished scratchpad becomes a feature
      Given a finished scratchpad for "workouts" with rules R1 to R3 and a dropped R4
      When formulate runs
      Then the feature file contains R1 to R3 as rules with their examples
      And it does not contain R4

  @R31
  Rule: formulate refuses while anything is open, and "!" counts only when the user accepts it
    Exception: the user overrides on purpose ("write the tests anyway"). Then
    open rules go in with their examples tagged "@wip" (R22 in discover.feature).

    @B31.1
    Example: An open guess stops formulate
      Given R4 is still marked "?"
      When formulate runs
      Then it stops and lists R4

    @B31.2
    Example: The user accepts Claude's certain rules
      Given every rule is marked "✓" or "!"
      And no question is open
      When the user says "accept all !"
      Then formulate runs

    @B31.3
    Example: The user overrides an open rule
      Given R4 is still marked "?"
      When the user says "formulate anyway"
      Then formulate writes the feature file
      And the examples of R4 are tagged "@wip"

  @R32
  Rule: Every example carries its ID as a tag

    @B32.1
    Example: An example tag
      Given example B1.2 in the scratchpad
      When formulate writes it
      Then the example is tagged "@B1.2"

  @R33
  Rule: Every rule carries its ID as a tag on "Rule:", and its title stays clean
    Verified with pytest-bdd 9.0, behave 1.3.3 and cucumber-js 13.3: all accept
    tags on Rule and pass them to the examples. playwright-bdd 2.x and
    cucumber-jvm support it by their docs and sources.

    @B33.1
    Example: A rule tag
      Given rule R1 "Coaches see only their group's workouts"
      When formulate writes it
      Then the line above "Rule:" is "@R1"
      And the rule title is "Coaches see only their group's workouts" without the ID

  @R34
  Rule: The scratchpad is deleted once the user confirms the feature, unless "keep_scratchpad" is on
    Two documents with the same rules would drift apart. The reasoning worth
    keeping moves into the free text under each Rule.

    @B34.1
    Example: The scratchpad goes away
      Given "keep_scratchpad" is off
      And "ask_before_delete" is off
      When the user confirms the feature file
      Then the scratchpad is deleted
      And the reasons behind each rule are in the free text under that rule

    @review @B34.2
    Example: The scratchpad is kept
      Given "keep_scratchpad" is on
      When the user confirms the feature file
      Then the scratchpad stays

    @B34.3
    Example: Open work keeps the scratchpad
      Given "keep_scratchpad" is off
      And the examples of R4 are tagged "@wip"
      When the user confirms the feature file
      Then the scratchpad stays
      And formulate says "Scratchpad kept: R4 still open (@wip)."

    @B34.4
    Example: An open question keeps the scratchpad
      Given every rule is marked "✓"
      And question F2 is open
      And the user said "formulate anyway"
      When the user confirms the feature file
      Then the scratchpad stays
      And formulate says "Scratchpad kept: F2 still open."

  @R35
  Rule: formulate asks before deleting the scratchpad, unless "ask_before_delete" is off

    @B35.1
    Example: Asking by default
      Given "ask_before_delete" is on
      When the scratchpad is about to be deleted
      Then formulate asks first

    @review @B35.2
    Example: Deleting without asking
      Given "ask_before_delete" is off
      When the scratchpad is about to be deleted
      Then formulate deletes it without asking

  @R36
  Rule: One feature file per story in features/, unless the project already has a place for features
    features/ is the default of behave and cucumber-js; pytest-bdd and
    playwright-bdd point there with one setting.

    @B36.1
    Example: The default place
      Given the project has no feature files yet
      When formulate writes the story "workouts"
      Then the file is "features/workouts.feature"

    @B36.2
    Example: A Java project
      Given the project keeps feature files in "src/test/resources/"
      When formulate writes the story "workouts"
      Then the file goes into "src/test/resources/"

  @R40
  Rule: In a monorepo the feature file lives in the module it describes
    A module is the top-level folder the story's code lives in (in BACKWARD
    mode: the folder of the rules' Source paths). Own build files per module
    are a hint, not a condition.

    @B40.1
    Example: A module of a monorepo
      Given a monorepo with the module "billing_assistant"
      When formulate writes a story about the invoice assistant
      Then the file goes into "billing_assistant/features/"

  @R37
  Rule: Gherkin is English unless the repo is in another language and the user chooses it

    @B37.1
    Example: An English repo
      Given the repo is in English
      When formulate writes a feature
      Then the feature is in English

    @B37.2
    Example: A German repo
      Given the repo is in German
      When formulate writes a feature
      Then it asks whether to write German with "# language: de" or English

  @R38
  Rule: Steps are declarative and in domain language

    @B38.1
    Example: A business step, not a UI step
      When formulate writes the step for opening a workout
      Then it reads "When Anna opens Carl's workout"
      And not "When I click #workout-42"

  @R39
  Rule: formulate uses the project's domain vocabulary consistently, and readability beats step reuse
    Sources: Seb Rose, "Keep your scenarios BRIEF"; Cucumber docs on
    anti-patterns and step organisation; Liz Keogh on custom DSLs. Reuse
    belongs in the step code, through parameters.

    @B39.1
    Example: The project's word wins
      Given existing features say "coach"
      When formulate writes a new feature about trainers
      Then the new feature says "coach"
