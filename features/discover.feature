Feature: Discover
  Step 1 of 3. The discover skill runs Example Mapping (Matt Wynne) in writing.
  Claude writes a Markdown scratchpad of rules, examples and questions.
  The user corrects it until nothing is open. Only then does work move on.

  @R10
  Rule: The user corrects the scratchpad and Claude folds the answers in, until nothing is open

    @B10.1
    Example: An answer given in chat is folded in
      Given a scratchpad where rule R3 "Coaches can delete workouts" is marked "?"
      When the user answers "R3: no, only admins"
      Then R3 reads "Only admins can delete workouts" and is marked "✓"
      And follow-up questions are appended as new F-items

    @B10.2
    Example: The scratchpad is ready when nothing is open
      Given every rule in the scratchpad is marked "✓"
      And no question is open
      When Claude folds in the last answer
      Then discover reports that the scratchpad is ready for formulate

    @B10.3
    Example: Calling discover again keeps the user's edits
      Given a scratchpad where the user changed R3 in the file
      When the user runs "/bdd:discover" again
      Then R3 keeps the user's text
      And discover does not ask about the language again
      And the scratchpad is not written again from scratch

  @R11
  Rule: The mode is chosen by a flag: FORWARD by default, BACKWARD only with "--backward"
    FORWARD is for new behaviour, no matter whether code or tests exist already;
    "--forward" states it explicitly. BACKWARD is only for tests that lag behind
    the code and are added retroactively. Existing code says nothing about whether
    the user wants new behaviour, so the mode is never guessed. When Claude notices
    that the tests lag behind the code, it suggests "--backward" and does not switch.

    @B11.1
    Example: An idea without code
      Given no code for workout sharing exists
      When the user asks discover about workout sharing
      Then the scratchpad mode is FORWARD

    @B11.2
    Example: Tests are added retroactively
      Given the workouts API exists and has no tests
      When the user runs "/bdd:discover --backward" for the workouts API
      Then the scratchpad mode is BACKWARD
      And every rule names the code location it was derived from

    @B11.3
    Example: New behaviour on existing code
      Given the workouts API exists and has tests
      When the user runs "/bdd:discover" for "coaches also see their substitutes' groups"
      Then the scratchpad mode is FORWARD

    @B11.4
    Example: Lagging tests are noticed, not acted on
      Given the workouts API exists and has no tests
      When the user runs "/bdd:discover" for the workouts API
      Then the scratchpad mode is FORWARD
      And Claude suggests in one line to use "--backward" to add tests for the existing workouts API

  @R12
  Rule: In BACKWARD mode the code is a witness, not a judge
    What code does is a guess about the intent, not the truth. A rule taken
    from code stays "?" unless docs or a ticket back it. Suspicious code gets
    a warning line, because those are the bug candidates.

    @B12.1
    Example: The detail endpoint forgets a check the list endpoint has
      Given the workout list filters by the coach's group
      And the workout detail does not
      When discover derives the rule "Coaches see only their group's workouts"
      Then the rule is marked "?"
      And a warning "code probably deviates" points at the workout detail

  @R13
  Rule: The scratchpad states guesses instead of asking open questions
    Correcting a wrong statement is faster than answering an empty question.

    @B13.1
    Example: A guess becomes a statement
      Given Claude can guess that athletes see only their own workouts
      When discover writes the scratchpad
      Then it states "Athletes see only their own workouts" marked "?"
      And it does not ask "Who can see workouts?"

  @R14
  Rule: Every rule carries one marker: "✓" set only by the user, "!" for Claude's certainty with evidence, "?" for a guess

    @B14.1
    Example: Claude is certain but does not confirm
      Given the README says that coaches lead exactly one group
      When discover writes that rule
      Then it is marked "!" and names the README as evidence
      And it is not marked "✓"

  @R15
  Rule: IDs are stable and dropped items stay visible

    @B15.1
    Example: A dropped rule keeps its place
      Given a scratchpad with rules R4 and R5
      When the user drops R4
      Then R4 stays in the scratchpad, struck through, with the reason
      And R5 keeps its ID

  @R16
  Rule: Rules are ordered by risk: uncertain and expensive-if-wrong first

    @B16.1
    Example: Permissions before cosmetics
      Given a rule about who may delete workouts
      And a rule about the colour of the workout card
      When discover orders the scratchpad
      Then the rule about deleting comes first

  @R17
  Rule: Examples are concrete, titled "The one where ...", and have no Given/When/Then yet

    @B17.1
    Example: A concrete example title
      When discover writes an example for the group rule
      Then it reads "The one where coach Anna opens Carl's workout from group B"
      And not "A coach opens a workout of another group"

  @R18
  Rule: discover reads Wynne's signals: too many questions, too many rules, too many items
    A proposed split goes into a "## Split" section of the scratchpad, except
    in a delta scratchpad; "none" keeps one story, no new split is proposed
    while the section exists, and new rules go to a part.

    @B18.1
    Example: The idea is not ready
      Given a scratchpad with more open questions than rules
      Then discover says the idea is not ready yet
      And does not push on to formulate

    @B18.2
    Example: The story is too big
      Given a scratchpad with 15 rules
      Then discover proposes splitting the story
      And writes the split into the scratchpad as a "## Split" section

  @R19
  Rule: For a topic that already has a feature file, discover writes a delta scratchpad

    @B19.1
    Example: A rule changes in an existing feature
      Given "features/workouts.feature" exists
      When the user says coaches should also see the workouts of their substitutes' groups
      Then the scratchpad lists only the changed rule and questions about it
      And not the whole feature again

  @R20
  Rule: The scratchpad lives in docs/discovery/ unless the project already uses another place

    @B20.1
    Example: The default place
      Given the project has no place for scratchpads
      When discover starts on 13 October 2026 for "workouts"
      Then the scratchpad is "docs/discovery/2026-10-13-workouts.md"

    @B20.2
    Example: The project has its own place
      Given the project keeps scratchpads in "specs/"
      When discover starts
      Then the scratchpad goes into "specs/"

  @R21
  Rule: Answers are accepted in the file and in chat

    @B21.1
    Example: Answers from both places
      Given the user edits R3 in the scratchpad
      And answers F2 in chat
      When Claude folds in the answers
      Then both answers are in the scratchpad

    @B21.2
    Example: A rule rewritten in the file counts as confirmed
      Given the user changed R3 in the file to "Only admins delete workouts"
      When Claude folds in the answers
      Then R3 reads "Only admins delete workouts" and is marked "✓"

  @R22
  Rule: The stages run strictly in order: discover, formulate, then code and tests
    The user may override on purpose. discover then only names the next commands;
    each stage stays one explicit step, and the user still confirms the feature
    file. formulate writes the confirmed part and tags every example of a rule
    that is not confirmed yet "@wip": it gets no test until the rule is confirmed
    and the tag is removed.

    @B22.1
    Example: No tests while a question is open
      Given question F2 is open
      When the user asks for tests
      Then discover names F2 as open
      And writes no tests

    @B22.2
    Example: The user overrides on purpose
      Given R1 to R3 are confirmed
      And R4 is still marked "?"
      When the user says "write the tests anyway" during discover
      Then discover names the next commands "/bdd:formulate anyway" and "/bdd:automate"
      And it writes no feature file and no tests itself

    @B22.3
    Example: automate respects open questions too
      Given question F2 is open
      When the user runs "/bdd:automate" without overriding
      Then automate names F2 as open
      And writes no tests

    @B22.4
    Example: A work-in-progress rule is confirmed later
      Given "features/workouts.feature" has R4's examples tagged "@wip"
      When the user confirms R4 and runs "/bdd:formulate"
      Then formulate removes "@wip" from R4's examples
      And changes nothing else in the feature file

  @R23
  Rule: discover starts only on explicit request
    It is a tool, not a virus. Whoever wants it by default can add a hook.

    @B23.1
    Example: A small request stays a small request
      When the user says "add a delete button"
      Then no scratchpad is written

    @B23.2
    Example: An explicit request
      When the user says "do an example mapping for workout sharing"
      Then discover starts

  @R24
  Rule: discover may suggest itself once per conversation, in one line, for a feature with several rules

    @B24.1
    Example: A bigger feature gets one suggestion
      When the user says "coaches should manage groups, invite athletes and see their workouts"
      Then Claude suggests in one line "Want an example map first?"
      And continues normal work if the suggestion is ignored

    @B24.2
    Example: No second suggestion
      Given discover was already suggested in this conversation
      When the user describes another bigger feature
      Then discover is not suggested again

  @R25
  Rule: The scratchpad is English unless the user chooses another language
    discover asks once when the user writes in another language or the repo is
    in another language, unless the user already named the language. The answer
    covers the scratchpad and the feature file: discover writes it into the
    scratchpad header, and formulate takes it from there without asking again.
    The format stays English in every language: header keys, markers and IDs.

    @B25.1
    Example: A German-speaking user is asked once
      Given the user writes in German
      When discover starts
      Then it asks once "Scratchpad and feature file in German or English?"

    @B25.2
    Example: A German repo with an English-speaking user
      Given the user writes in English
      And the repo docs are in German
      When discover starts
      Then it asks once "Scratchpad and feature file in German or English?"

    @B25.3
    Example: The answer is kept in the scratchpad
      Given the user writes in German
      When the user answers "German"
      Then the scratchpad header has the line "**Language:** German"
