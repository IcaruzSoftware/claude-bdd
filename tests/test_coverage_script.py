import subprocess
import sys
from pathlib import Path

import pytest
from pytest_bdd import given, parsers, scenario, then, when

ROOT = Path(__file__).resolve().parent.parent
SCRIPT = ROOT / 'plugin' / 'scripts' / 'check_coverage.py'


@scenario('automate.feature', 'An example without a test')
def test_example_without_test():
    """automate:B53.1"""


@scenario('automate.feature', 'A test without an example')
def test_test_without_example():
    """automate:B53.2"""


@scenario('automate.feature', 'The same ID in two features')
def test_same_id_in_two_features():
    """automate:B53.3"""


@scenario('automate.feature', 'A test deleted by hand')
def test_test_deleted_by_hand():
    """automate:B59.1"""


@scenario('automate.feature', 'A document mentions an example but no test does')
def test_document_mentions_example():
    """automate:B53.4"""


@scenario('automate.feature', 'A test points at a deleted feature')
def test_test_points_at_deleted_feature():
    """automate:B53.5"""


@scenario('automate.feature', 'A work-in-progress example is no gap')
def test_work_in_progress_example():
    """automate:B53.6"""


@scenario('automate.feature', 'A copy of the features in a worktree')
def test_copy_in_worktree():
    """automate:B53.7"""


@scenario('automate.feature', 'An example checked by review')
def test_example_checked_by_review():
    """automate:B53.8"""


@scenario('automate.feature', 'A scratchpad in specs is no test')
def test_scratchpad_in_specs():
    """automate:B53.9"""


@scenario('automate.feature', 'The hook also runs on a commit that only deletes files')
def test_hook_runs_always():
    """automate:B59.2"""


@pytest.fixture
def project(tmp_path):
    return tmp_path


def run_script(root):
    return subprocess.run(
        [sys.executable, str(SCRIPT), str(root)], capture_output=True, text=True
    )


def add_example(project, feature, tag, tag_line=None):
    path = project / 'features' / feature
    path.parent.mkdir(exist_ok=True)
    if not path.exists():
        path.write_text('Feature: Something\n')
    with path.open('a') as f:
        f.write(f'\n  {tag_line or tag}\n  Example: {tag}\n    Given something\n')


def add_test(project, name, ref):
    path = project / 'tests' / name
    path.parent.mkdir(exist_ok=True)
    path.write_text(f'def test_it():\n    """{ref}"""\n')


@given(parsers.parse('"{feature}" has the example "{tag}"'))
def feature_has_example(project, feature, tag):
    add_example(project, feature, tag)


@given(parsers.parse('"{feature}" has the example "{tag}" tagged "{extra}"'))
def feature_has_tagged_example(project, feature, tag, extra):
    add_example(project, feature, tag, tag_line=f'{extra} {tag}')


@given(parsers.parse('"{first}" and "{second}" both have the example "{tag}"'))
def features_both_have_example(project, first, second, tag):
    add_example(project, first, tag)
    add_example(project, second, tag)


@given(parsers.parse('"{feature}" has no example "{tag}"'))
def feature_has_no_example(project, feature, tag):
    path = project / 'features' / feature
    path.parent.mkdir(exist_ok=True)
    path.write_text('Feature: Something\n')


@given(parsers.parse('no test mentions "{ref}"'))
def no_test_mentions(project, ref):
    pass


@given(parsers.parse('a test mentions "{ref}"'))
def a_test_mentions(project, ref):
    add_test(project, 'test_a.py', ref)


@given(parsers.parse('only "{doc}" mentions "{ref}"'))
def only_doc_mentions(project, doc, ref):
    path = project / doc
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(f'See {ref}.\n')


@given(parsers.parse('there is no "{feature}"'))
def there_is_no_feature(project, feature):
    assert not (project / 'features' / feature).exists()


@given(parsers.parse('one test mentions "{first}" and another mentions "{second}"'))
def two_tests_mention(project, first, second):
    add_test(project, 'test_a.py', first)
    add_test(project, 'test_b.py', second)


@given(parsers.parse('a copy of it lies in "{folder}"'))
def copy_lies_in(project, folder):
    """No git repo in tmp_path, so the script walks the tree and must skip hidden folders."""
    target = project / folder
    target.mkdir(parents=True)
    for feature in (project / 'features').iterdir():
        (target / feature.name).write_text(feature.read_text())


@given('the coverage script runs as a pre-commit hook')
def pre_commit_hook(project):
    """The hook in .pre-commit-hooks.yaml runs the script with no arguments."""
    add_example(project, 'workouts.feature', '@B3.1')
    # built at runtime, so the coverage script run on this repo does not see a reference
    add_test(project, 'test_workouts.py', ':'.join(['workouts', 'B3.1']))
    assert run_script(project).returncode == 0


@when('the coverage script runs', target_fixture='result')
def coverage_script_runs(project):
    return run_script(project)


@when(
    parsers.parse('someone deletes the only test for "{ref}" and commits'),
    target_fixture='result',
)
def delete_test_and_commit(project, ref):
    (test,) = [p for p in (project / 'tests').iterdir() if ref in p.read_text()]
    test.unlink()
    return run_script(project)


@then(parsers.parse('it reports "{ref}" as missing'))
def reports_missing(result, ref):
    assert result.returncode == 1
    assert f'missing: {ref} has no test' in result.stdout.splitlines()


@then(parsers.parse('it reports "{ref}" as orphan'))
def reports_orphan(result, ref):
    assert result.returncode == 1
    assert f'orphan: {ref} has no example' in result.stdout.splitlines()


@when(parsers.parse('the hook definition in "{name}" is read'), target_fixture='hook')
def hook_definition_is_read(name):
    # stdlib only: PyYAML is not in the dev env; the file is a flat list of key: value lines
    text = (ROOT / name).read_text()
    return {k.strip(' -'): v.strip() for k, _, v in (line.partition(':') for line in text.splitlines())}


@then('the hook runs always')
def hook_runs_always(hook):
    assert hook.get('always_run') == 'true'


@then('it passes no file names')
def hook_passes_no_file_names(hook):
    assert hook.get('pass_filenames') == 'false'


@then(parsers.parse('it reports "{ref}" as checked by review'))
def reports_review(result, ref):
    assert f'review: {ref} checked by review' in result.stdout.splitlines()


@then(parsers.parse('it reports "{ref}" as work in progress'))
def reports_wip(result, ref):
    assert f'wip: {ref} has no test yet' in result.stdout.splitlines()


@then('it does not fail')
def does_not_fail(result):
    assert result.returncode == 0, result.stdout


@then('it reports no gap')
def reports_no_gap(result):
    assert result.returncode == 0, result.stdout
    assert result.stdout.startswith('ok: ')


@then(parsers.parse('the commit fails with "{message}"'))
def commit_fails_with(result, message):
    assert result.returncode != 0
    assert message in result.stdout
