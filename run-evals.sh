#!/usr/bin/env bash
# Run the eval suite in evals/ against the plugin in plugin/.
#
# `claude plugin eval` only reads cases below the plugin root (--eval-dir ../evals
# and a manifest pointing outside are rejected), and the evals must not ship
# with the plugin. So copy both into a temp dir and evaluate that. Real copies:
# the eval refuses hard-linked files.
#
# Usage (arguments go to `claude plugin eval`):
#   ./run-evals.sh --scaffold --ablation none --model claude-haiku-5-5 --runs 1 --allow-tools Write Edit 'Bash(rm:*)' --no-publish -j 4 --json evals/results/latest.json
set -euo pipefail
root=$(cd "$(dirname "$0")" && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
cp -r "$root/plugin/." "$tmp/"
mkdir "$tmp/evals"
for path in "$root"/evals/*; do
  [ "$(basename "$path")" = results ] || cp -r "$path" "$tmp/evals/"
done
# run from the repo root, so relative paths like --json evals/results/x.json land here
cd "$root"
claude plugin eval "$tmp" --trust-plugin --output-dir "$root/evals/results/$(date +%Y-%m-%dT%H-%M-%S)" "$@"
