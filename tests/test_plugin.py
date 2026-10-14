import json
import re
import shutil
import subprocess
from pathlib import Path

import pytest
from pytest_bdd import given, parsers, scenario, then, when

ROOT = Path(__file__).resolve().parent.parent
PLUGIN = ROOT / 'plugin'
SKILLS = {'discover', 'formulate', 'automate'}


@scenario('plugin.feature', 'The plugin name stays short in commands')
def test_plugin_name_stays_short():
    """plugin:B1.2"""


@scenario('plugin.feature', 'A stranger installs the plugin from GitHub')
def test_stranger_installs_from_github():
    """plugin:B3.1"""


@scenario('plugin.feature', 'There is no hyphenated command')
def test_no_hyphenated_command():
    """plugin:B4.1"""


def load(name):
    # marketplace.json lives at the repo root, plugin.json in the plugin the marketplace installs
    base = ROOT if name == 'marketplace.json' else PLUGIN
    return json.loads((base / '.claude-plugin' / name).read_text(encoding='utf-8'))


def install_command():
    plugin, market = load('plugin.json'), load('marketplace.json')
    assert [p['name'] for p in market['plugins']] == [plugin['name']]
    return f'/plugin install {plugin["name"]}@{market["name"]}'


def skill_commands():
    """Slash commands Claude Code derives from the plugin: /<plugin>:<skill>."""
    plugin = load('plugin.json')['name']
    commands = set()
    for skill_md in (PLUGIN / 'skills').glob('*/SKILL.md'):
        name = re.search(
            r'^name:\s*(\S+)', skill_md.read_text(encoding='utf-8'), re.M
        ).group(1)
        assert name == skill_md.parent.name
        commands.add(f'/{plugin}:{name}')
    return commands


@given('the bdd plugin is installed')
def bdd_plugin_installed():
    assert load('plugin.json')['name'] == 'bdd'


@given(parsers.parse('a developer finds "{repo}" on GitHub'), target_fixture='repo')
def developer_finds_repo(repo):
    assert load('plugin.json')['repository'] == f'https://github.com/{repo}'
    return repo


@when('the user installs the plugin')
def user_installs():
    pass


@when(parsers.parse('they run "{command}"'))
def they_run(command, repo):
    if command.startswith('/plugin marketplace add '):
        # marketplace add <owner/repo> reads .claude-plugin/marketplace.json at the repo root
        assert command == f'/plugin marketplace add {repo}'
        assert load('marketplace.json')['name'] == repo.split('/')[1]
    else:
        assert command == install_command()


@when(parsers.parse('the user looks for "{command}"'), target_fixture='looked_for')
def user_looks_for(command):
    return command


@then(parsers.parse('the install command is "{command}"'))
def install_command_is(command):
    assert install_command() == command


@then(
    parsers.parse(
        'the skills are invoked as "{first}", "{second}" and "{third}"'
    )
)
def skills_invoked_as(first, second, third):
    assert skill_commands() == {first, second, third}


@then('the skills discover, formulate and automate are available')
def skills_available():
    plugins = load('marketplace.json')['plugins']
    assert (ROOT / plugins[0]['source']).resolve() == PLUGIN
    assert {p.parent.name for p in (PLUGIN / 'skills').glob('*/SKILL.md')} == SKILLS
    claude = shutil.which('claude')
    if not claude:
        pytest.skip('claude CLI not on PATH, skipping "claude plugin validate"')
    for path in (ROOT, PLUGIN):  # the marketplace, then the plugin it installs
        result = subprocess.run(
            [claude, 'plugin', 'validate', str(path)], capture_output=True, text=True
        )
        assert result.returncode == 0, result.stdout + result.stderr


@then('no such command exists')
def no_such_command(looked_for):
    assert not (PLUGIN / 'commands').exists()
    assert looked_for not in skill_commands()


@then(parsers.parse('"{command}" does'))
def command_does(command):
    assert command in skill_commands()
