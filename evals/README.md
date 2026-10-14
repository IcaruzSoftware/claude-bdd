# Evals

Every behaviour example in `features/discover.feature`, `features/formulate.feature`
and `features/automate.feature` has one `claude plugin eval` case here. The case
checks the example, not the skill text: Given → scaffold (and prompt), When →
prompt, Then → graders. Examples about files in this repo are pytest tests in
`tests/`, not evals: `plugin.feature` (except its one eval, plugin-B1.1) and
automate's coverage-script examples (R53, R59). Background and decisions:
`docs/discovery/2026-10-13-evals.md`.

Evals run locally only. They need a Claude login and use your quota or API
budget. CI (`.github/workflows/ci.yml`) runs `uv run pytest -q` and
`scripts/check_coverage.py` on every push and pull request, not evals.

## Run

Quick run while working on a skill (one run per case, Haiku 5.5):

```bash
claude plugin eval . --scaffold --ablation none --model claude-haiku-5-5 \
  --runs 1 --allow-tools Write Edit --no-publish
```

- One skill: add `--tag discover` (or `formulate`, `automate`).
- One rule: add `--tag R31`.
- One case: add `--case '<feature>:<ID>'`, with the case's `name`.
- Release run, before tagging a version: `--runs 3` instead of `--runs 1`.

Case B34.1 of formulate deletes the scratchpad with `rm`. Without a Bash grant that
call is denied, so add `'Bash(rm:*)'` to `--allow-tools` when that case must pass.

Why these flags:

- `--scaffold` runs each case's `scaffold.sh`, which seeds the empty workspace.
  It runs as you, outside the sandbox; the scripts only write files.
- `--ablation none` skips the no-plugin baseline arm. That arm measures "plugin
  vs. no plugin", which we do not need on every change, and it doubles the cost.
- `--allow-tools Write Edit`: the skills write scratchpads, feature files and tests.
- `--no-publish` keeps the HTML report local (`evals/results/<timestamp>/`, ignored by git).

Cost: with a Claude subscription the cost column shows `$0`, so `--max-cost-usd`
does not limit your quota. Limit a run with `--runs 1`, `--tag` or `--case`
instead. With an API key, `--max-cost-usd 10` is the ceiling for a release run.

## Add a case

1. Create `evals/<feature>-<ID>/case.yaml`, e.g. `evals/discover-B11.3/case.yaml`.
2. Set `name: <feature>:<ID>`: the feature file's name without `.feature`, a
   colon, and the example ID. `scripts/check_coverage.py` counts the example as
   covered only through this exact reference, so a typo shows up as `missing:`
   plus `orphan:`. Do not write such references anywhere else under `evals/`
   (this README included): the script would count them as coverage.
3. Set `description: "<example title> (features/<feature>.feature @<ID>)"` and
   `tags: [<feature>, R<n>]`, where `R<n>` is the example's rule.
4. Seed state the example assumes with `context.scaffold_script: scaffold.sh`
   (bash, `set -euo pipefail`, executable). It starts in an empty directory with a
   minimal environment and has 120 seconds. Write fixture files with heredocs;
   never put a real `.feature` file under `evals/`, the coverage script would read it.
5. Put the "When" into `execution.prompt`, invoking the skill explicitly
   (`/bdd:discover …`, `/bdd:formulate docs/discovery/…`), with the user's answer
   in the same prompt when the example continues a conversation. A case is a
   single turn: skills ask in plain text and stop.
6. Turn each "Then" into a grader. Prefer deterministic ones:
   - `regex` on `last_message` or on a file (`target: {source: file, path: …}`);
     use the spec's exact phrase where the example quotes one.
   - `file_exists` for files Claude created. It does not see scaffolded files.
   - `tool_used` with `input_match` to check what Claude wrote: the input is
     JSON-encoded, so a newline in the written file is `\n` and `[^\\]*` stays
     within one line. Use `min: 0` and `max: 0` for "never".
   - `llm` only when no pattern can check the Then; write explicit PASS and FAIL
     conditions.
   Avoid `regex` on `target: trace`: the trace contains the skill text, which
   quotes many of the phrases the graders look for.

## Known limits

- **Plugin options** (`keep_scratchpad`, `ask_before_delete`) come from the
  user's plugin config and cannot be set per case: a case's `env` only accepts
  `EVAL_*` keys, and the run's `config/settings.json` is created after the
  scaffold (a scaffold that writes it fails the run with `EEXIST`). The suite
  runs without options, so `${user_config.*}` stays unsubstituted and the skill
  falls back to the defaults (keep off, ask on). formulate's B34.2 and B35.2 have
  no case; they carry the tag `@review`, which the coverage script reports as
  `review: … checked by review` instead of a gap. formulate's B34.1 runs with the
  defaults and the user's "yes" in the prompt.
- **Earlier turns**: discover's B24.2 resumes `history.jsonl`, a hand-written
  transcript. Its format is not documented; if the case fails to load, rebuild
  the file from a real session.
- **Dates**: discover's B20.1 checks the `YYYY-MM-DD-<slug>` shape, not today's date.

## Known failures

- **discover's B24.1 and B24.2**: Haiku does not follow the suggestion in the
  discover skill's description. R24 stays in the spec on purpose.
- **Cases tagged `needs-bash`**: Bash cannot start in the eval sandbox on
  machines that restrict unprivileged nested user namespaces, e.g. Ubuntu with
  AppArmor's `kernel.apparmor_restrict_unprivileged_userns=1`. Run them on a
  machine or CI runner without that restriction.
- **`llm` graders on the trace** are flaky: the trace they judge can be cut off
  in the middle, and the judge then misses what happened after the cut.

## Hard links

`claude plugin eval` refuses hard-linked files anywhere in the plugin directory,
`.venv` included. `pyproject.toml` sets `[tool.uv] link-mode = "copy"` for that
reason; if you recreate `.venv` with another tool, make sure it copies.

## automate cases

The `automate-*` cases follow the same layout. PLAIN-mode cases seed a small
project with its own test suite and use an `llm` grader to judge whether the new
tests assert exactly the example's Then and blend into that suite (R13 of the
evals scratchpad).
