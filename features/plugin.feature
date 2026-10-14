Feature: Plugin shape
  claude-bdd is a Claude Code plugin for Behavior-Driven Development.
  It takes a developer from a rough idea or untested code to confirmed
  business rules, then Gherkin specs, then tests, so that code and tests
  both follow the intent instead of each other.

  @R1
  Rule: The repo holds one plugin named "bdd" with the skills discover, formulate and automate
    The repo is called claude-bdd so people can find it. Inside commands the
    "claude-" prefix would only be noise, so the plugin itself is called bdd.

    @B1.1
    Example: The user runs only the automation step
      Given the bdd plugin is installed
      When the user invokes "/bdd:automate"
      Then only the automation step runs

    @B1.2
    Example: The plugin name stays short in commands
      When the user installs the plugin
      Then the install command is "/plugin install bdd@claude-bdd"
      And the skills are invoked as "/bdd:discover", "/bdd:formulate" and "/bdd:automate"

  @R3
  Rule: The repo is its own marketplace and installs with two commands

    @B3.1
    Example: A stranger installs the plugin from GitHub
      Given a developer finds "IcaruzSoftware/claude-bdd" on GitHub
      When they run "/plugin marketplace add IcaruzSoftware/claude-bdd"
      And they run "/plugin install bdd@claude-bdd"
      Then the skills discover, formulate and automate are available

  @R4
  Rule: The plugin ships no slash commands of its own
    Claude Code always namespaces plugin skills as "plugin:skill".
    Extra commands would only duplicate them.

    @B4.1
    Example: There is no hyphenated command
      Given the bdd plugin is installed
      When the user looks for "/bdd-discover"
      Then no such command exists
      And "/bdd:discover" does

  @R7
  Rule: The README follows the shape of popular plugin READMEs, plus one short worked example
    Popular plugin READMEs (obra/superpowers, anthropics/skills,
    anthropics/claude-plugins-official) put the install block near the top.
    None of them has a demo, but this plugin's value only shows in an example.

    @B7.1
    Example: The README outline
      When a visitor reads the README from top to bottom
      Then they see in this order: pitch, install with two commands, a table of the three skills, a worked example, configuration, requirements, update and uninstall, license
      And the worked example shows a scratchpad excerpt, a feature excerpt and a test excerpt for coaches, athletes and workouts

    @B7.2
    Example: The README is found by search
      Given someone searches GitHub or Google for "Claude Code BDD" or "example mapping"
      Then the README title, its first lines and its headings contain those terms
      And they match the repo description and topics
