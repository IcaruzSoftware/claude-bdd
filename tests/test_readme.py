import json
import re
from pathlib import Path

from pytest_bdd import given, scenario, then, when

ROOT = Path(__file__).resolve().parent.parent
OUTLINE = ['install', 'skills', 'worked example', 'configuration', 'requirements', 'update', 'license']
TERMS = ['Claude Code', 'BDD', 'Behavior-Driven Development', 'Example Mapping', 'Gherkin', 'Cucumber']


@scenario('plugin.feature', 'The README outline')
def test_readme_outline():
    """plugin:B7.1"""


@scenario('plugin.feature', 'The README is found by search')
def test_readme_found_by_search():
    """plugin:B7.2"""


def readme():
    return (ROOT / 'README.md').read_text(encoding='utf-8')


def sections():
    """Split the README at its H2 headings: (pitch, [(heading, body), ...])."""
    pitch, *rest = re.split(r'^## ', readme(), flags=re.M)
    return pitch, [tuple(part.split('\n', 1)) for part in rest]


def search_text():
    """Title, first lines and all headings."""
    text = readme()
    first_lines = '\n'.join(text.splitlines()[:5])
    headings = '\n'.join(re.findall(r'^#+ .*$', text, re.M))
    return f'{first_lines}\n{headings}'.lower()


@when('a visitor reads the README from top to bottom')
def visitor_reads_readme():
    assert readme()


@then(
    'they see in this order: pitch, install with two commands, a table of the three skills, a worked example, configuration, requirements, update and uninstall, license'
)
def readme_outline():
    pitch, parts = sections()
    assert pitch.split('\n', 1)[1].strip(), 'pitch missing under the title'
    headings = [heading.lower() for heading, _ in parts]
    positions = [
        next(i for i, h in enumerate(headings) if key in h) for key in OUTLINE
    ]
    assert positions == sorted(positions) == list(range(len(OUTLINE)))
    bodies = dict(zip(OUTLINE, (body for _, body in parts)))
    assert '/plugin marketplace add IcaruzSoftware/claude-bdd' in bodies['install']
    assert '/plugin install bdd@claude-bdd' in bodies['install']
    for skill in ('/bdd:discover', '/bdd:formulate', '/bdd:automate'):
        assert re.search(rf'^\|.*{skill}', bodies['skills'], re.M)


@then(
    'the worked example shows a scratchpad excerpt, a feature excerpt and a test excerpt for coaches, athletes and workouts'
)
def worked_example():
    example = sections()[1][2][1]
    blocks = re.findall(r'```(\w*)\n(.*?)```', example, re.S)
    languages = [lang for lang, _ in blocks]
    assert 'gherkin' in languages and 'python' in languages
    assert 'markdown' in languages
    assert 'Feature:' in next(b for lang, b in blocks if lang == 'gherkin')
    text = example.lower()
    for word in ('coach', 'athlete', 'workout'):
        assert word in text


@given('someone searches GitHub or Google for "Claude Code BDD" or "example mapping"')
def someone_searches():
    pass


@then('the README title, its first lines and its headings contain those terms')
def readme_contains_terms():
    text = search_text()
    assert readme().startswith('# ')
    for term in TERMS:
        assert term.lower() in text, term


@then('they match the repo description and topics')
def matches_description_and_topics():
    plugin = json.loads((ROOT / '.claude-plugin' / 'plugin.json').read_text(encoding='utf-8'))
    metadata = (plugin['description'] + ' ' + ' '.join(plugin['keywords'])).lower().replace('-', ' ')
    for term in TERMS:
        assert term.lower().replace('-', ' ') in metadata, term
