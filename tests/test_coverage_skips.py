import shutil
import subprocess
import sys
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parent.parent
SCRIPT = ROOT / 'plugin' / 'scripts' / 'check_coverage.py'


def test_eval_results_are_not_tests(tmp_path):
    """Output of `claude plugin eval` (evals/results/) quotes case names but is no test."""
    (tmp_path / 'features').mkdir()
    (tmp_path / 'features' / 'workouts.feature').write_text('Feature: W\n  @B1.1\n  Example: x\n')
    (tmp_path / 'evals' / 'workouts-B1.1').mkdir(parents=True)
    (tmp_path / 'evals' / 'workouts-B1.1' / 'case.yaml').write_text('name: ' + ':'.join(['workouts', 'B1.1']))
    (tmp_path / 'evals' / 'results').mkdir()
    (tmp_path / 'evals' / 'results' / 'old.json').write_text(':'.join(['sharing', 'B9.9']))
    result = subprocess.run([sys.executable, str(SCRIPT), str(tmp_path)], capture_output=True, text=True)
    assert result.returncode == 0, result.stdout


def test_review_tag_is_no_gap(tmp_path):
    """An example tagged @review (plugin options an eval cannot set) is checked by review, not by a test."""
    (tmp_path / 'features').mkdir()
    (tmp_path / 'features' / 'workouts.feature').write_text(
        'Feature: W\n  @B1.1\n  Example: x\n\n  @review\n  @B1.2\n  Example: y\n\n  @B1.3 @review\n  Example: z\n'
    )
    (tmp_path / 'tests').mkdir()
    (tmp_path / 'tests' / 'test_w.py').write_text(':'.join(['workouts', 'B1.1']))
    result = subprocess.run([sys.executable, str(SCRIPT), str(tmp_path)], capture_output=True, text=True)
    lines = result.stdout.splitlines()
    assert result.returncode == 0, result.stdout
    for example in ('B1.2', 'B1.3'):
        assert f'review: workouts:{example} checked by review' in lines


def run(root):
    return subprocess.run([sys.executable, str(SCRIPT), str(root)], capture_output=True, text=True)


def write(root, rel, text):
    path = root / rel
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text)


def ref(slug, example):
    # built at runtime, so the coverage script run on this repo does not see a reference
    return ':'.join([slug, example])


@pytest.mark.skipif(shutil.which('git') is None, reason='git not installed')
def test_git_repo_reads_only_files_git_would_track(tmp_path):
    """Untracked but not ignored tests count; an ignored copy of the features is not read."""
    subprocess.run(['git', 'init', '-q'], cwd=tmp_path, check=True)
    write(tmp_path, '.gitignore', 'target/\n')
    write(tmp_path, 'features/workouts.feature', 'Feature: W\n  @B1.1\n  Example: x\n')
    write(tmp_path, 'target/features/workouts.feature', 'Feature: W\n  @B1.1\n  Example: x\n')
    write(tmp_path, 'target/tests/test_old.py', ref('gone', 'B9.9'))
    write(tmp_path, 'tests/test_w.py', ref('workouts', 'B1.1'))
    result = run(tmp_path)
    assert result.returncode == 0, result.stdout


def test_build_output_is_skipped_without_git(tmp_path):
    write(tmp_path, 'features/workouts.feature', 'Feature: W\n  @B1.1\n  Example: x\n')
    write(tmp_path, 'target/classes/features/workouts.feature', 'Feature: W\n  @B1.1\n  Example: x\n')
    write(tmp_path, 'tests/test_w.py', ref('workouts', 'B1.1'))
    assert run(tmp_path).returncode == 0


@pytest.mark.parametrize('slug', ['übungen', 'workouts.v2'])
def test_slug_with_unicode_or_dots(tmp_path, slug):
    write(tmp_path, f'features/{slug}.feature', 'Feature: W\n  @B1.1\n  Example: x\n')
    write(tmp_path, 'tests/test_w.py', f'"""{ref(slug, "B1.1")}"""\n')
    result = run(tmp_path)
    assert result.returncode == 0, result.stdout


def test_feature_not_utf8(tmp_path):
    path = tmp_path / 'features' / 'workouts.feature'
    path.parent.mkdir()
    path.write_bytes('Feature: Übungen\n  @B1.1\n  Example: x\n'.encode('latin-1'))
    result = run(tmp_path)
    assert result.returncode == 2
    assert result.stdout.strip() == f'error: cannot read {path}'


def test_root_does_not_exist(tmp_path):
    root = tmp_path / 'nope'
    result = run(root)
    assert result.returncode == 2
    assert result.stdout.strip() == f'error: no such directory {root}'


def test_tags_carry_across_blank_and_comment_lines(tmp_path):
    write(tmp_path, 'features/workouts.feature', 'Feature: W\n  @wip\n\n  # later\n  @B1.1\n  Example: x\n')
    result = run(tmp_path)
    assert result.returncode == 0, result.stdout
    assert f'wip: {ref("workouts", "B1.1")} has no test yet' in result.stdout.splitlines()


@pytest.mark.parametrize('tag, line', [('@wip', 'wip: {} has no test yet'), ('@review', 'review: {} checked by review')])
def test_rule_tag_applies_to_its_examples(tmp_path, tag, line):
    write(
        tmp_path,
        'features/workouts.feature',
        f'Feature: W\n\n  @R1 {tag}\n  Rule: open\n\n    @B1.1\n    Example: x\n      Given a\n\n'
        '    @B1.2\n    Example: y\n      Given b\n\n  @R2\n  Rule: done\n\n    @B2.1\n    Example: z\n',
    )
    result = run(tmp_path)
    lines = result.stdout.splitlines()
    assert result.returncode == 1
    assert line.format(ref('workouts', 'B1.1')) in lines
    assert line.format(ref('workouts', 'B1.2')) in lines
    assert f'missing: {ref("workouts", "B2.1")} has no test' in lines


def test_tag_in_docstring_is_no_example(tmp_path):
    write(
        tmp_path,
        'features/workouts.feature',
        'Feature: W\n  @B1.1\n  Example: x\n    Given the text\n      """\n      @B1.2\n      Example: quoted\n      """\n',
    )
    write(tmp_path, 'tests/test_w.py', ref('workouts', 'B1.1'))
    result = run(tmp_path)
    assert result.returncode == 0, result.stdout
