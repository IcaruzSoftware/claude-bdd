# Example Map: findings from the first eval runs

🟨 **Story:** As the maintainer, I want the spec gaps found by the first eval runs decided, so that every example in `features/` is both true and checkable.

**Mode:** BACKWARD (code: `skills/*/SKILL.md`, tests: `evals/`)
**Delta to:** `features/discover.feature`, `features/formulate.feature`
**Status:** 4 rules (4 ✓) · 0 questions open · formulated into features on 2026-10-13. R24 stays in the spec; its evals B24.1/B24.2 are known to fail on Haiku

**How to answer:** edit this file, or reply in chat by ID, e.g. `R22: ok`.
Markers: `✓` confirmed by you · `!` Claude is sure, with evidence · `?` Claude's guess · `⚠` suspected problem.

Eval state (Haiku 5.5, 1 run each): 56 of 69 cases pass. 8 fail because Bash cannot start in the eval sandbox on this machine (environment), 4 are flaky judges, 1 is unresolved (R24), 1 is a spec gap (R22).

---

### R24 ✓ kept as is (user decision): discover still suggests itself through its skill description
- ⚠ 0 of 7 eval runs on Haiku followed the instruction; B24.1 and B24.2 are listed as known failures in `evals/README.md`
- ~~drop R24, README shows an optional hook~~ dropped: user keeps R24

### R22 ✓ (clarified) "write the tests anyway" inside discover does not run formulate and automate by itself. discover says which commands come next ("Run /bdd:formulate anyway, then /bdd:automate"). The user still confirms the feature file in between (R34)
- B22.2 (changed) The one where R4 is still `?` and the user says "write the tests anyway" during discover → discover replies with the next commands and changes nothing else
- B31.3 (unchanged) covers what formulate does with "anyway"
- Alternative: discover chains formulate and automate in one go and skips the confirmation. Guess: hand over, because each stage stays one explicit step and the confirmation of the feature file is kept

### R34 ✓ (extended) If the feature has `@wip` examples, formulate keeps the scratchpad even when `keep_scratchpad` is off, and says which IDs are still open
- B34.3 The one where R4's examples are `@wip` → "Scratchpad kept: R4 still open (@wip)."
- Evidence: the open items live only in the scratchpad; deleting it would lose them. The skill already does this; the spec does not say it yet

### R35 ✓ B34.2 (`keep_scratchpad` on) and B35.2 (`ask_before_delete` off) are checked by one eval attempt that writes the plugin option into the sandbox's home settings in the scaffold. If Claude Code ignores it there, both examples are marked "checked by review" and the coverage script gets a way to accept that (tag `@review` on the example, reported like `@wip`)
- ⚠ The eval tool has no documented way to set a plugin's options per case
