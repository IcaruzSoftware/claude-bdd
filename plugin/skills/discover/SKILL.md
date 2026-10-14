---
name: discover
description: >-
  When the user describes a feature with several rules without asking for an
  example map, add the single line "Want an example map first? (/bdd:discover)"
  to your reply, at most once per conversation, and continue the normal work; do
  not start this skill. Step 1 of 3 of BDD: Example Mapping (Matt Wynne) in
  writing. Writes a Markdown discovery scratchpad of rules, examples and
  questions and folds in the user's answers until nothing is open. Use ONLY when
  the user explicitly asks for the bdd discover skill, an example mapping, an
  example map, a discovery scratchpad, or /bdd:discover. Never use it for
  ordinary feature or bug requests.
---

# discover

Example Mapping in writing.
You write a scratchpad of rules, examples and questions.
The user corrects it.
You fold the answers in until nothing is open.
Then the user moves on to `/bdd:formulate`.

Write no code and no tests in this skill. If the user explicitly overrides, name the next commands (sections "Reply" and "Order of the stages"); never run them yourself.

## 1. Existing scratchpad

1. Use the scratchpad the user names. Otherwise look for a scratchpad for this topic (see section "Location").
2. If one exists, re-read it and go straight to section "Fold in answers".
3. Do not ask the language again. Keep the scratchpad's language and mode.
4. Do not write the scratchpad again from scratch. Never overwrite the user's edits.
5. If none exists, start with section "Language".

## 2. Language

1. Check the language of the user's messages and of the repo's docs.
2. If either is not English, ask once in your reply: "Scratchpad in <Language> or English?" (for German: "Scratchpad in German or English?"). Otherwise write the scratchpad in English.
3. After asking, stop and wait for the answer. Ask this only once per scratchpad.
4. In a scratchpad in another language, keep the format in English: the title `# Example Map`, the header keys `**Mode:**`, `**Delta to:**` and `**Status:**`, the markers and the IDs. Translate only the content.

## 3. Mode

The mode comes only from a flag. Never guess it from the code.

1. The user's arguments are: `$ARGUMENTS` (empty means no flag). Also look for `--forward` or `--backward` in the user's message.
2. No flag, or `--forward`: mode is FORWARD. FORWARD is for new behaviour, whether or not code or tests exist already.
3. `--backward`: mode is BACKWARD. BACKWARD adds tests retroactively for code whose tests lag behind.
4. In BACKWARD mode, every rule gets a line `Source: <path>:<line>` naming the code it was derived from.
5. In FORWARD mode, search the code for the topic. If it is already implemented and has no tests, add one line to your reply: "The <topic> already exists without tests. Use --backward to add tests for it retroactively?" Example: "The workouts API already exists without tests. Use --backward to add tests for it retroactively?" Stay in FORWARD mode.

## 4. BACKWARD: the code is a witness, not a judge

What the code does is a guess about the intent, not the truth.

1. A rule derived only from code is marked `?`.
2. Mark it `!` only if docs or a ticket back it, and name them as evidence.
3. Compare similar code paths (list vs. detail, create vs. update, API vs. UI).
4. When code looks inconsistent with a rule, add under that rule: `- ⚠ code probably deviates: <path>:<line> (<what differs>)`.
5. Example: the workout list filters by the coach's group, the workout detail does not. Write the rule "Coaches see only their group's workouts" marked `?`, plus a ⚠ line pointing at the workout detail.

## 5. Existing feature file: delta scratchpad

1. Look for a `.feature` file about the topic.
2. If one exists, read it first and write a delta scratchpad.
3. Add the header line `**Delta to:** <path of the feature>`.
4. List only the changed or new rules, their examples, and questions about them.
5. Do not copy the unchanged rules of the feature.
6. A changed rule keeps its rule ID from the feature (its `@R<n>` tag).
7. The examples of a changed rule keep their IDs from the feature (their `@B<n>.<n>` tags).
8. A new example takes the next free number under its rule. Example: R2 has B2.1 and B2.2 in the feature; the new example is B2.3.
9. A new rule takes the next free rule number in that feature. Example: the feature has R1 to R5; the new rule is R6.

## 6. Location

1. Look for existing scratchpads in the project (Markdown files starting with "# Example Map", or a folder like `specs/` or `docs/discovery/`).
2. If the project has a place, use it.
3. Otherwise use `docs/discovery/<YYYY-MM-DD>-<slug>.md` with today's date and a short kebab-case slug of the topic.
4. Example: topic "workouts" on 13 October 2026 gives `docs/discovery/2026-10-13-workouts.md`.

## 7. Write the scratchpad

Follow this format exactly. The content is an example; replace it with the real rules.

````markdown
# Example Map: <topic>

🟨 **Story:** As a <role>, I want <capability>, so that <benefit>.

**Mode:** <FORWARD (new behaviour) | BACKWARD (--backward; code: <path>, tests: <path or none>)>
**Delta to:** <features/<slug>.feature — only in a delta scratchpad, else delete this line>
**Status:** <n> rules (<a> ✓, <b> !, <c> ?) · <m> questions open

**How to answer:** edit this file, or reply in chat by ID, e.g. `R3: no, only admins`. A bare `ok` next to an ID confirms it. `accept all !` confirms every `!` at once.
Markers: `✓` confirmed by you · `!` Claude is sure, with evidence · `?` Claude's guess · `⚠` suspected problem.

---

## Rules

### R1 ? Only admins can delete workouts
Source: `src/workouts/api.py:88`
- B1.1 The one where coach Anna deletes Carl's workout "Tempo run 5 km" → refused, the workout stays
- B1.2 The one where admin Mia deletes the same workout → it is gone for Carl and Anna

### R2 ? Coaches see only their group's workouts
Source: `src/workouts/api.py:40` (list filters by group)
- ⚠ code probably deviates: `src/workouts/api.py:61` (detail does not filter by group)
- B2.1 The one where coach Anna opens Carl's workout from group B → not found

### R3 ! Coaches lead exactly one group
Evidence: README.md, section "Groups"
- B3.1 The one where Anna already leads group A and is assigned group B → refused

### R4 ~~Athletes can rename workouts~~ dropped: renaming is out of scope for this story

### R5 ? The workout card shows the sport's colour
- B5.1 The one where Carl's run is shown in green and his swim in blue

---

## 🟥 Open questions

- F1 Can a coach move an athlete to another group?
- ~~F2~~ → R3
````

1. Read the user's request, the docs, tickets and (in BACKWARD mode) the code.
2. Write each rule as a statement: `### R<n> <marker> <statement>`.
3. State a guess instead of asking an open question. Write "Athletes see only their own workouts" marked `?`, not the question "Who can see workouts?".
4. Write an F-item only when you cannot make a sensible guess.
5. Give each rule exactly one marker:
   - `?` your guess.
   - `!` you are certain, and the next line names the evidence: `Evidence: <file, doc or ticket>`.
   - `✓` only the user sets it. You never write `✓` on your own judgement.
6. Order rules by risk: uncertain and expensive-if-wrong first (permissions, money, data loss, security), cosmetics last.
7. Number the rules R1, R2, … in that order. Number examples per rule: B1.1, B1.2, B2.1, … In a delta scratchpad, take the IDs from section "Existing feature file" instead.
8. Write each example as `- B<n>.<n> The one where <concrete situation> → <outcome>`.
9. Use real names and values: "The one where coach Anna opens Carl's workout from group B", not "A coach opens a workout of another group".
10. Never write Given/When/Then in the scratchpad.
11. Fill in the header: story, mode, status counts, how to answer, markers.

## 8. Fold in answers

Answers come in the file and in chat. Take both.

1. Re-read the scratchpad file first; the user may have edited it.
2. Apply every chat answer by ID and every edit in the file:
   - `ok` next to an ID: mark it `✓`.
   - `accept all !`: mark every `!` rule `✓`.
   - A correction, e.g. `R3: no, only admins` for "Coaches can delete workouts": rewrite the rule as a statement ("Only admins can delete workouts") and mark it `✓`.
   - A rule the user rewrote in the file: keep the user's text and mark it `✓`.
   - A dropped item: keep it in place, struck through, with the reason: `### R4 ~~<statement>~~ dropped: <reason>`.
   - An answered question: fold the answer into a rule, then strike it: `- ~~F2~~ → R7`.
3. Check what each answer leaves open (who else, which exceptions, what happens to existing data). Append each such follow-up question as a new F-item with the next free number, e.g. `- F2 <question>`. Never ask a follow-up only in your chat reply.
4. Add new rules or examples raised by an answer as `?` or `!`.
5. Never renumber an ID. Never reuse a dropped ID.
6. Update the status line.

## 9. Check the signals

After writing and after every fold, check Wynne's signals:

1. More open questions than rules: say "This idea is not ready yet" and why. Do not suggest formulate.
2. More than 12 rules: propose splitting the story, and name the split.
3. More than about 50 items in total: propose splitting the story.

## 10. Reply

1. Name the scratchpad path, the mode and the status counts. Add the `--backward` line from section "Mode" if it applies.
2. List the `?` rules, `⚠` lines and open F-items the user should look at first.
3. Remind the user how to answer: edit the file or reply by ID.
4. When every rule that is not dropped is `✓` and no question is open, say: "The scratchpad is ready for formulate. Run /bdd:formulate."
5. In BACKWARD mode, add: "Then run /bdd:automate --backward <feature path>." The feature path is the `**Delta to:**` path, else `features/<slug>.feature`.
6. If the user overrides (e.g. "write the tests anyway"), add the sentence from section "Order of the stages", step 3, word for word: "Run `/bdd:formulate anyway`, then `/bdd:automate`. …"

## 11. Order of the stages

The stages run strictly in order: discover, then formulate, then code and tests.

1. While any rule is `?` or `!`, or any F-item is open, write no code and no tests.
2. If the user asks for code or tests now, name the open IDs (e.g. "F2 is still open") and write nothing else.
3. Only if the user explicitly overrides (e.g. "write the tests anyway"), the work moves on. Then say exactly: "Run `/bdd:formulate anyway`, then `/bdd:automate`. The examples of <open rule IDs> will be tagged @wip and get no tests yet." Keep "anyway" inside the backticks: it is part of the command. In BACKWARD mode write "`/bdd:automate --backward <feature path>`" instead of "`/bdd:automate`" (feature path as in section "Reply"). Write no feature file and no tests in discover itself.

## Never

- Never set `✓` yourself; only the user's answer sets it.
- Never renumber IDs or delete dropped items.
- Never overwrite the user's edits in the scratchpad.
- Never write Given/When/Then in the scratchpad.
- Never write code or tests while anything is open, unless the user explicitly overrides.
- Never guess the mode from the code. Only `--backward` sets BACKWARD; never switch by yourself.
- Never ask with the AskUserQuestion tool. Ask in plain text in your reply, then stop.
