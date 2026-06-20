# Skill Evaluation Specification

## ADDED Requirements

### Requirement: Deterministic skill package validation

The system SHALL provide a deterministic lint command that validates the AI skill package before any model-based evaluation is executed.

#### Scenario: Valid skill package

- **GIVEN** the repository contains a valid `soused-hegelian` skill package
- **WHEN** the lint command is executed
- **THEN** the command SHALL exit with status code `0`
- **AND** the command SHALL print a success message.

#### Scenario: Missing skill file

- **GIVEN** `skills/soused-hegelian/SKILL.md` is missing
- **WHEN** the lint command is executed
- **THEN** the command SHALL exit with a non-zero status code
- **AND** the command SHALL report the missing file.

#### Scenario: Invalid plugin metadata JSON

- **GIVEN** `.claude-plugin/plugin.json` contains invalid JSON
- **WHEN** the lint command is executed
- **THEN** the command SHALL exit with a non-zero status code
- **AND** the command SHALL report invalid JSON.

#### Scenario: Invalid skill frontmatter

- **GIVEN** `SKILL.md` does not start with standalone YAML frontmatter delimiters
- **WHEN** the lint command is executed
- **THEN** the command SHALL exit with a non-zero status code
- **AND** the command SHALL report invalid frontmatter.

#### Scenario: Missing reference file

- **GIVEN** `skills/soused-hegelian/references/hegel-reference.md` is missing
- **WHEN** the lint command is executed
- **THEN** the command SHALL exit with a non-zero status code
- **AND** the command SHALL report the missing reference file.

---

### Requirement: Skill frontmatter validation

The system SHALL validate that `SKILL.md` contains frontmatter fields required for skill discovery and activation.

#### Scenario: Required frontmatter fields are present

- **GIVEN** `SKILL.md` contains valid YAML frontmatter
- **WHEN** the lint command parses the frontmatter
- **THEN** the frontmatter SHALL contain `name`
- **AND** the frontmatter SHALL contain `description`.

#### Scenario: Skill name is correct

- **GIVEN** `SKILL.md` contains valid YAML frontmatter
- **WHEN** the lint command parses the frontmatter
- **THEN** the `name` field SHALL equal `soused-hegelian`.

#### Scenario: Description contains activation terms

- **GIVEN** `SKILL.md` contains a `description`
- **WHEN** the lint command validates the description
- **THEN** the description SHALL contain terms that indicate the skill is activated for Brandt-style, Hegelian, and dialectical prompts.

---

### Requirement: Local SLM eval runner

The system SHALL provide a command-line eval runner that tests the skill using a local Ollama model.

#### Scenario: Eval runner receives model and eval file

- **GIVEN** an Ollama model is available locally
- **AND** an eval JSON file exists
- **WHEN** the eval runner is executed with `--model` and `--evals`
- **THEN** the runner SHALL load the specified model name
- **AND** the runner SHALL load eval cases from the specified eval file.

#### Scenario: Eval runner loads skill context

- **GIVEN** `SKILL.md` exists
- **AND** `references/hegel-reference.md` exists
- **WHEN** the eval runner starts
- **THEN** it SHALL include the skill instructions in the system prompt
- **AND** it SHALL include the Hegel reference material in the system prompt.

#### Scenario: Eval runner calls Ollama

- **GIVEN** the Ollama server is running
- **WHEN** the eval runner executes a test case
- **THEN** it SHALL call the local Ollama chat API
- **AND** it SHALL send the test prompt as the user message
- **AND** it SHALL capture the generated assistant response.

#### Scenario: Ollama is unavailable

- **GIVEN** the Ollama server is not reachable
- **WHEN** the eval runner executes
- **THEN** the runner SHALL fail
- **AND** it SHALL return a non-zero status code.

---

### Requirement: Contract-based output assertions

The system SHALL evaluate local SLM outputs using contract-based assertions rather than exact output matching.

#### Scenario: Required-any assertion passes

- **GIVEN** an eval case defines `must_include_any`
- **AND** the model output contains at least one listed term
- **WHEN** the eval runner evaluates the output
- **THEN** the assertion SHALL pass.

#### Scenario: Required-any assertion fails

- **GIVEN** an eval case defines `must_include_any`
- **AND** the model output contains none of the listed terms
- **WHEN** the eval runner evaluates the output
- **THEN** the assertion SHALL fail.

#### Scenario: Required-all assertion passes

- **GIVEN** an eval case defines `must_include_all`
- **AND** the model output contains every listed term
- **WHEN** the eval runner evaluates the output
- **THEN** the assertion SHALL pass.

#### Scenario: Required-all assertion fails

- **GIVEN** an eval case defines `must_include_all`
- **AND** the model output omits at least one listed term
- **WHEN** the eval runner evaluates the output
- **THEN** the assertion SHALL fail.

#### Scenario: Forbidden-term assertion passes

- **GIVEN** an eval case defines `must_not_include`
- **AND** the model output contains none of the listed terms
- **WHEN** the eval runner evaluates the output
- **THEN** the assertion SHALL pass.

#### Scenario: Forbidden-term assertion fails

- **GIVEN** an eval case defines `must_not_include`
- **AND** the model output contains at least one listed term
- **WHEN** the eval runner evaluates the output
- **THEN** the assertion SHALL fail.

---

### Requirement: Slop footer reporting

The eval runner SHALL treat the `slop:` footer as advisory: it SHALL report
whether the footer is present, but a missing footer SHALL NOT fail the smoke
test. The footer is a skill feature built on the stop-slop machinery and a
multi-pass self-scoring loop, which a bare system-prompted local model (with no
stop-slop skill installed in CI) cannot reliably perform.

#### Scenario: Footer present

- **GIVEN** the model output contains a `slop: N/10` footer
- **WHEN** the eval runner evaluates the output
- **THEN** no footer advisory is reported.

#### Scenario: Footer absent

- **GIVEN** the model output does not contain a `slop:` footer
- **WHEN** the eval runner evaluates the output
- **THEN** the runner SHALL report a footer advisory
- **AND** the case SHALL NOT fail on the missing footer alone.

---

### Requirement: English skill smoke tests

The system SHALL include English eval cases that verify basic behaviour of the `soused-hegelian` skill.

#### Scenario: Explicit Brandt prompt

- **GIVEN** an English prompt explicitly asks for Doktor Brandt
- **WHEN** the eval runner executes the case with the English model
- **THEN** the output SHALL include at least one Hegelian marker
- **AND** the output SHALL NOT include generic AI-disclaimer language.

#### Scenario: Dialectical prompt

- **GIVEN** an English prompt asks for a dialectical answer
- **WHEN** the eval runner executes the case with the English model
- **THEN** the output SHALL include at least one dialectical marker

#### Scenario: Technical prompt

- **GIVEN** an English prompt asks the skill to debug Python
- **WHEN** the eval runner executes the case with the English model
- **THEN** the output SHALL redirect or dismiss the request in character
- **AND** the output SHALL NOT provide normal coding output

#### Scenario: Grief prompt

- **GIVEN** an English prompt expresses grief or despair
- **WHEN** the eval runner executes the case with the English model
- **THEN** the output SHALL avoid treating the prompt as a merely technical question

---

### Requirement: Polish skill smoke tests

The system SHALL include Polish eval cases that verify basic behaviour of the `soused-hegelian` skill in Polish.

#### Scenario: Explicit Brandt prompt in Polish

- **GIVEN** a Polish prompt explicitly asks for Doktor Brandt
- **WHEN** the eval runner executes the case with the Polish model
- **THEN** the output SHALL include at least one Hegelian marker
- **AND** the output SHALL NOT include generic AI-disclaimer language in Polish.

#### Scenario: Dialectical prompt in Polish

- **GIVEN** a Polish prompt asks for a dialectical answer
- **WHEN** the eval runner executes the case with the Polish model
- **THEN** the output SHALL include at least one dialectical marker

#### Scenario: Technical prompt in Polish

- **GIVEN** a Polish prompt asks the skill to debug Python
- **WHEN** the eval runner executes the case with the Polish model
- **THEN** the output SHALL redirect or dismiss the request in character
- **AND** the output SHALL NOT provide normal coding output

#### Scenario: Grief prompt in Polish

- **GIVEN** a Polish prompt expresses grief or despair
- **WHEN** the eval runner executes the case with the Polish model
- **THEN** the output SHALL avoid treating the prompt as a merely technical question

---

### Requirement: GitHub Actions CI integration

The system SHALL run deterministic linting and local SLM smoke tests in GitHub Actions.

#### Scenario: Pull request validation

- **GIVEN** a pull request is opened
- **WHEN** GitHub Actions runs the skill CI workflow
- **THEN** the lint job SHALL execute
- **AND** the local SLM smoke test job SHALL execute.

#### Scenario: Push validation

- **GIVEN** code is pushed to `main`
- **WHEN** GitHub Actions runs the skill CI workflow
- **THEN** the lint job SHALL execute
- **AND** the local SLM smoke test job SHALL execute.

#### Scenario: Manual validation

- **GIVEN** a maintainer manually triggers the workflow
- **WHEN** GitHub Actions runs the skill CI workflow
- **THEN** the lint job SHALL execute
- **AND** the local SLM smoke test job SHALL execute.

#### Scenario: English matrix entry

- **GIVEN** the local SLM smoke test job runs
- **WHEN** the matrix entry language is `en`
- **THEN** the workflow SHALL pull the configured English model
- **AND** the workflow SHALL run `evals/hegel_skill_cases.en.json`.

#### Scenario: Polish matrix entry

- **GIVEN** the local SLM smoke test job runs
- **WHEN** the matrix entry language is `pl`
- **THEN** the workflow SHALL pull the configured Polish model
- **AND** the workflow SHALL run `evals/hegel_skill_cases.pl.json`.

---

### Requirement: Local execution documentation

The system SHALL document how to run deterministic and model-based tests locally.

#### Scenario: Run lint locally

- **GIVEN** a developer has Python dependencies installed
- **WHEN** the developer runs `python tools/skill_lint.py`
- **THEN** the skill package SHALL be validated locally.

#### Scenario: Run English eval locally

- **GIVEN** Ollama is installed
- **AND** `gemma3:1b` is available
- **WHEN** the developer runs the English eval command
- **THEN** English skill smoke tests SHALL execute locally.

#### Scenario: Run Polish eval locally

- **GIVEN** Ollama is installed
- **AND** `SpeakLeash/bielik-1.5b-v3.0-instruct:Q8_0` is available
- **WHEN** the developer runs the Polish eval command
- **THEN** Polish skill smoke tests SHALL execute locally.

---

### Requirement: Manual release validation boundary

The system SHALL document that local SLM smoke tests do not replace manual Claude Code plugin validation.

#### Scenario: Preparing a release

- **GIVEN** the CI checks pass
- **WHEN** a maintainer prepares a release
- **THEN** the maintainer SHOULD run the skill manually in Claude Code
- **AND** the maintainer SHOULD verify that Claude Code discovers and invokes the skill correctly.
