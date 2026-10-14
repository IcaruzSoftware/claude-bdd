---
name: formulate
description: >-
  Step 2 of 3 of BDD: turns a finished discovery scratchpad (example map) into a
  Gherkin .feature file with @R and @B tags, then deletes the scratchpad once the
  user confirms the feature. Use ONLY when the user explicitly asks to formulate
  a scratchpad, to write the feature file from an example map, or runs
  /bdd:formulate.
---

# formulate

Turns a finished scratchpad into one Gherkin feature file.
The feature file is the lasting statement of the business rules.
The scratchpad was only for thinking.

Write no code and no tests in this skill.

## 1. Find the scratchpad

1. Use the path the user names.
2. Otherwise take the newest scratchpad in `docs/discovery/` or in the project's own scratchpad place.
3. If there is none, say so and suggest `/bdd:discover`. Stop.

## 2. Gate: only confirmed content

1. Re-read the scratchpad file.
2. Skip dropped (struck-through) rules. They never count as `?` or `!`.
3. Collect every other rule marked `?`, every other rule marked `!`, and every open F-item (not struck through).
4. If any rule is `?` or any F-item is open: stop. List them by ID, e.g. "Not ready: R4 is still ?." Write no feature file. Exception: the override in step 9.
5. A `!` rule counts as accepted when the user said "accept all !" or `ok <ID>` for it (e.g. `ok R3`).
6. If any `!` rule is not accepted, list those rules and ask: "Accept all ! rules (<IDs>)?" Then stop and wait. Exception: the override in step 9.
7. Mark every accepted `!` rule `✓` in the scratchpad and continue.
8. Dropped (struck-through) rules, examples and questions never go into the feature file.
9. Override: the user explicitly says so, e.g. "formulate anyway" or "write the tests anyway", or `anyway` is in the arguments (`$ARGUMENTS`). Then write the feature anyway. Put every rule that is not confirmed yet (`?` or not accepted `!`) into it with its examples, and tag each of their examples `@wip` (see section "Write the feature"). Open F-items stay in the scratchpad. Say which rules are `@wip`.

## 3. Location

1. Delta scratchpad (header line `**Delta to:**`): edit that feature file. Change only the rules the delta lists. Keep everything else as it is.
2. The feature file exists already and holds this scratchpad's rules, with `@wip` on a rule that is now confirmed: update only that rule. Remove its `@wip` tags and apply its changed wording. Change nothing else in the file; the user may have edited it.
3. Monorepo: a module is the top-level folder the story's code lives in. In BACKWARD mode it is the folder of the rules' `Source:` paths. Own build files per folder (`pyproject.toml`, `package.json`, `pom.xml`, `build.gradle`) are a hint, not a condition. If the story's code lives in one top-level folder next to other code folders, the feature file goes there: `<module>/features/<slug>.feature`. Example: a story about the invoice assistant whose code is in `billing_assistant/` goes into `billing_assistant/features/`.
4. The project already keeps feature files somewhere (e.g. `src/test/resources/`): write there.
5. Otherwise: `features/<slug>.feature`. Example: story "workouts" gives `features/workouts.feature`.
6. One feature file per story.
7. The slug is the scratchpad's slug without the date.
8. Before writing a new file, check that no other `.feature` file in the repo has the same name. If one does, ask: "<path> exists already. Which slug instead of <slug>?" Stop and wait.

## 4. Language

1. Check the language of the repo (docs, comments, existing feature files).
2. If the repo is in English, write the feature in English.
3. If the repo is in another language, ask once: "Feature in <Language> with \"# language: <code>\" or in English?" (for German: "Feature in German with \"# language: de\" or in English?"). Stop and wait.
4. For a non-English feature, make `# language: <code>` the first line and use that language's Gherkin keywords.

## 5. Vocabulary

1. Read the existing feature files, docs and domain code.
2. Use the project's word for each concept, everywhere. If existing features say "coach", write "coach", never "trainer".
3. Use the same word for the same concept in every step.
4. Readability beats step reuse. Never bend a sentence so that an existing step matches. Reuse belongs in the step code, through parameters.

## 6. Write the feature

Write this shape:

```gherkin
Feature: Workouts
  <the story from the scratchpad, as free text>

  @R1
  Rule: Coaches see only their group's workouts
    <why this rule exists: the reasons and evidence from the scratchpad>

    @B1.1
    Example: Anna opens Carl's workout from group B
      Given Carl is an athlete in group B
      And Anna coaches group A
      When Anna opens Carl's workout
      Then Anna sees no workout
```

1. Take the rules in the scratchpad's order.
2. Put the tag `@R<n>` on its own line directly above `Rule:`.
3. Write the rule title as the plain statement, without the ID.
4. Under `Rule:`, write the reasons as free text: why the rule exists, its evidence, and dropped alternatives worth remembering. Keep it short. This text replaces the scratchpad.
5. Put the tag `@B<n>.<n>` on its own line directly above each `Example:`. Use the example's ID from the scratchpad, e.g. `@B1.2`.
6. Override only (section 2, step 9): for every example of a rule that is not confirmed yet, put the tag `@wip` on its own line directly above the `@B<n>.<n>` line. Later, when that rule is confirmed, remove its `@wip` tags (section 3, step 2).
7. Turn "The one where …" into a short example title without "The one where".
8. Write Given/When/Then from the example's situation and outcome.
9. Write steps declaratively, in domain language: "When Anna opens Carl's workout", never "When I click #workout-42".
10. No clicks, URLs, selectors, field IDs or SQL in steps.
11. Keep the concrete names and values from the scratchpad.

## 7. Confirm

1. Show the feature file path and a short summary (rules and example counts).
2. Ask: "Please review <path>. Confirm the feature file?" Stop and wait.
3. If the user asks for changes, apply them and ask again.

## 8. After the user confirms: the scratchpad

First read the scratchpad's `**Mode:**` line. The last line below needs it, and the scratchpad may be gone by then.

Keep the scratchpad while work is open: its open items live only there.

- The feature has `@wip` examples: say "Scratchpad kept: <rule IDs of the @wip examples> still open (@wip).", e.g. "Scratchpad kept: R4 still open (@wip)."
- An F-item is open (not struck through): say "Scratchpad kept: <F-IDs> still open.", e.g. "Scratchpad kept: F2 still open."
- Both: name both, e.g. "Scratchpad kept: R4 still open (@wip). F2 still open."

Then do not delete it, do not ask, and skip to item 7 below.

Read the two settings. Each is the text `true` or `false`.

- keep_scratchpad = `${user_config.keep_scratchpad}`
- ask_before_delete = `${user_config.ask_before_delete}`

1. If keep_scratchpad is exactly `true`: keep the scratchpad. Update its status line to "formulated into <feature path> on <date>". Say "Scratchpad kept (keep_scratchpad is on)." Done.
2. Any other value of keep_scratchpad means off. Then delete the scratchpad as follows.
3. Before deleting, make sure the reasons of every rule are in the free text under its `Rule:`.
4. If ask_before_delete is exactly `false`: delete the scratchpad without asking. Say "Deleted <path>."
5. Any other value of ask_before_delete means on. Ask: "Delete the scratchpad <path>?" Stop and wait. Delete it only after a yes.
6. After a no: keep the scratchpad. Update its status line to "formulated into <feature path> on <date>". Say "Scratchpad kept."
7. Finish with: "Next step: /bdd:automate <feature path>." If the Mode line says BACKWARD, finish with: "Next step: /bdd:automate --backward <feature path>.", e.g. "Next step: /bdd:automate --backward features/workouts.feature."

## Never

- Never write a feature file while a rule is `?`, a `!` is not accepted, or an F-item is open, unless the user overrides; then tag the examples of every rule that is not confirmed `@wip`.
- Never put dropped items into the feature file.
- Never put the rule ID into the rule title; it belongs in the `@R<n>` tag.
- Never delete the scratchpad before the user has confirmed the feature file, or while an F-item or a `@wip` rule is open.
- Never rewrite an existing feature file from the scratchpad; change only the rules that changed.
- Never write UI steps (clicks, selectors, URLs) or SQL.
- Never write code or tests here.
- Never ask with the AskUserQuestion tool. Ask in plain text in your reply, then stop.
