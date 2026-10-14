# Example Map: findings from the acceptance review

🟨 **Story:** As the maintainer, I want the gaps found by the two acceptance reviewers settled in the spec, so that v1 behaves correctly for a real user end to end.

**Mode:** BACKWARD (code: `skills/`, `scripts/check_coverage.py`, `.pre-commit-hooks.yaml`)
**Delta to:** `features/discover.feature`, `features/formulate.feature`, `features/automate.feature`
**Status:** 9 rules (9 ✓ — the user asked to stop review rounds and go ahead; all follow from confirmed rules) · 0 questions open · formulated into features on 2026-10-13

**How to answer:** edit this file, or reply in chat by ID. `accept all !` confirms every `!` at once.
Markers: `✓` confirmed by you · `!` Claude is sure, with evidence · `?` Claude's guess · `⚠` suspected problem.

All `!` items follow from rules you already confirmed; the evidence names the rule they protect. Fixes that change no rule (wording in skills, README, robustness of the script, weak eval graders) are done without a question.

---

## Blockers

### R61 ✓ (extended) BACKWARD travels with the work: when the scratchpad's mode is BACKWARD, discover and formulate name the next command with the flag, `/bdd:automate --backward <feature>`
Evidence: reviewer 2 — without it a user who follows the hint runs automate FORWARD, and a ⚠ code deviation is reported as "red is the goal" instead of a finding (breaks R54).
- B61.4 The one where the scratchpad says BACKWARD and the user confirms the feature → formulate ends with "Next step: /bdd:automate --backward features/workouts.feature"

### R53 ✓ (extended) The coverage script reads only the project's own files: in a git repo the files git tracks or would track (`git ls-files`), otherwise it skips hidden folders and build output (`target/`, `dist/`, `build/`)
Evidence: reviewer 2 — Claude Code worktrees (`.claude/worktrees/…`) and Maven's `target/` hold copies of the features and made the script stop with "duplicate slug", which stops automate (R53, R58).
- B53.7 The one where `.claude/worktrees/x/features/workouts.feature` is a copy → no duplicate-slug error, the copy is ignored

### R59 ✓ (extended) The pre-commit hook runs on every commit, also on a commit that only deletes files
Evidence: reviewer 1 — pre-commit passes no deleted files, so the hook was skipped exactly in B59.1 ("someone deletes the only test"). Fix: `always_run: true`.
- B59.2 The one where the hook definition is read → it runs always and passes no file names

### R40 ✓ (clarified) A "module" is the top-level folder the story's code lives in (in BACKWARD: the folder of the rules' `Source:` paths). Own build files per module are a hint, not a condition
Evidence: reviewer 2 — the strict "own pyproject.toml per module" made formulate miss the monorepo of the first real user, against B40.1.

---

## Smaller rule gaps

### R53 ✓ (extended) `@review` examples are reported as `review: … checked by review` and are no gap; the eval tool's output folder `evals/results/` is never read as tests; `specs/` is not a test place (it is discover's scratchpad place, B20.2)
Evidence: decided in eval-findings R35 but not yet in the spec; `specs/` gave a false "covered" from a scratchpad (reviewer 2).
- B53.8 The one where `@B1.2` is tagged `@review` and has no test → `review: workouts:B1.2 checked by review`, no failure
- B53.9 The one where only `specs/2026-10-13-workouts.md` mentions `workouts:B1.1` → reported as missing

### R60 ✓ (sharpened) The only visible effect of remembered PLAIN mode is that the one-line notice of B51.2 is not shown again
Evidence: reviewer 1 — B60.1's eval passed even if the references were ignored, because nothing in the example distinguishes it from B51.2.
- B60.1 (changed) adds "And it shows no notice"

### R34 ✓ (extended) formulate also keeps the scratchpad while any F-item is open, not only while `@wip` examples exist
Evidence: reviewer 2 — after "formulate anyway" with all rules ✓ but F2 open, the scratchpad (the only place F2 lives) was deleted.
- B34.4 The one where every rule is ✓, F2 is open and the user said "formulate anyway" → "Scratchpad kept: F2 still open."

### R22 ✓ (extended) Confirming a `@wip` rule later updates the existing feature: only that rule changes and its `@wip` tags go; the rest of the feature stays as it is
Evidence: reviewer 2 — formulate re-ran the whole scratchpad and would overwrite changes the user made when confirming the feature.
- B22.4 The one where R4 is confirmed after "formulate anyway" → formulate removes `@wip` from R4's examples and changes nothing else

### R25 ✓ (extended) In a scratchpad written in another language, the format stays English: header keys (`**Mode:**`, `**Delta to:**`, `**Status:**`), markers and IDs
Evidence: reviewer 2 — formulate finds deltas by `**Delta to:**` and discover finds scratchpads by `# Example Map`; translated keys break both.

---

## 🟥 Open question

- ~~F1~~ Before the repo goes public, internal names of the first real user were replaced with neutral ones (`billing_assistant`, "boundary tests at a derived seam", "the first real user"); the meaning of the examples did not change.
