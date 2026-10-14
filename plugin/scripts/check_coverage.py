#!/usr/bin/env python3
"""Report BDD examples without a test and test references without an example.

Usage: check_coverage.py [ROOT]

An example is a tag like @B3.1 in workouts.feature; a test refers to it by
writing workouts:B3.1 anywhere in a test-like file: one under a folder named
test, tests, spec, __tests__ or evals, or named like test_*, *_test.*,
*.test.* or *.spec.*. An example tagged @wip without a test is reported as
work in progress, not as a gap. An example tagged @review is checked by review
instead of a test (e.g. it needs plugin options an eval cannot set); it is
reported, not counted as a gap.

In a git repo only the files git tracks or would track are read; otherwise
hidden folders and build output are skipped. evals/results/ is never read.
"""

import os
import re
import subprocess
import sys
from fnmatch import fnmatch
from pathlib import Path

SKIP = {'node_modules', 'venv', '__pycache__', 'dist', 'build', 'target'}
TAG = re.compile(r'(?<!\S)@(B\d+\.\d+)(?!\S)')
REF = re.compile(r'(?<![\w.-])\.*([\w-][\w.-]*:B\d+\.\d+)(?!\d)')
TEST_DIRS = {'test', 'tests', 'spec', '__tests__', 'evals'}
TEST_NAMES = ('test_*', '*_test.*', '*.test.*', '*.spec.*')


def walk(root):
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d not in SKIP and not d.startswith('.')]
        for name in filenames:
            yield Path(dirpath, name)


def project_files(root):
    """The files git tracks or would track; without git, the tree minus hidden and build folders."""
    try:
        out = subprocess.run(
            ['git', 'ls-files', '--cached', '--others', '--exclude-standard', '-z'],
            cwd=root, capture_output=True, check=True,
        ).stdout
    except (OSError, subprocess.CalledProcessError):
        yield from walk(root)
        return
    for name in dict.fromkeys(os.fsdecode(out).split('\0')):
        path = Path(root, name)
        if name and path.is_file():  # skips deleted-but-staged files and nested repos
            yield path


def is_test(path, root):
    *dirs, name = path.relative_to(root).parts
    return bool(TEST_DIRS & set(dirs)) or any(fnmatch(name, p) for p in TEST_NAMES)


def is_eval_result(path, root):
    return '/evals/results/' in '/' + path.relative_to(root).as_posix()


def read_examples(slug, text, examples, wip, review):
    tags, rule_tags, in_docstring = [], [], False
    for line in text.splitlines():
        line = line.strip()
        if line.startswith(('"""', '```')):
            in_docstring = not in_docstring
            continue
        if in_docstring or not line or line.startswith('#'):
            continue  # tags carry across blank and comment lines
        if line.startswith('@'):
            tags += line.split()
            continue
        if line.startswith('Rule:'):  # ponytail: English keyword only, add i18n keywords when needed
            rule_tags = tags
        else:
            ids = {f'{slug}:{i}' for t in tags for i in TAG.findall(t)}
            examples |= ids
            if '@wip' in tags + rule_tags:
                wip |= ids
            if '@review' in tags + rule_tags:
                review |= ids
        tags = []


def main(root):
    if not Path(root).is_dir():
        print(f'error: no such directory {root}')
        return 2
    features, texts = {}, []
    for path in project_files(root):
        if is_eval_result(path, root):
            continue
        if path.suffix != '.feature':
            if is_test(path, root):
                texts.append(path)
        elif path.stem in features:
            print(f'error: duplicate slug {path.stem}: {features[path.stem]}, {path}')
            return 2
        else:
            features[path.stem] = path

    examples, wip, review = set(), set(), set()
    for slug, path in features.items():
        try:
            text = path.read_text(encoding='utf-8')
        except (UnicodeDecodeError, OSError):
            print(f'error: cannot read {path}')
            return 2
        read_examples(slug, text, examples, wip, review)

    refs = set()
    for path in texts:
        try:
            refs.update(REF.findall(path.read_text(encoding='utf-8')))
        except (UnicodeDecodeError, OSError):
            pass

    wips = [f'wip: {e} has no test yet' for e in wip - refs]
    reviews = [f'review: {e} checked by review' for e in review - refs]
    gaps = [f'missing: {e} has no test' for e in examples - wip - review - refs]
    gaps += [f'orphan: {r} has no example' for r in refs - examples]
    for line in sorted(gaps + wips + reviews):
        print(line)
    if gaps:
        return 1
    print(f'ok: {len(examples) - len(wips) - len(reviews)} examples covered')
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1] if len(sys.argv) > 1 else '.'))
