# skill-evaluation Specification

## Purpose
TBD - created by archiving change add-local-slm-skill-evals. Update Purpose after archive.
## Requirements
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

The system SHALL evaluate the skill against a local Ollama model using
[promptfoo](https://www.promptfoo.dev/) as the eval engine, driven by a declarative
configuration rather than a bespoke runner.

#### Scenario: Eval configuration selects model and cases

- **GIVEN** a promptfoo configuration exists
- **AND** it references the Ollama provider model and the EN/PL eval test files
- **WHEN** promptfoo runs the evaluation
- **THEN** it SHALL evaluate against the configured Ollama model
- **AND** it SHALL load the configured eval test cases.

#### Scenario: Eval run loads skill context

- **GIVEN** `SKILL.md` exists
- **AND** `references/hegel-reference.md` exists
- **WHEN** promptfoo builds the prompt for a case
- **THEN** it SHALL include the skill instructions in the system prompt
- **AND** it SHALL include the Hegel reference material in the system prompt.

#### Scenario: Eval run calls Ollama

- **GIVEN** the Ollama server is running
- **WHEN** promptfoo executes a test case
- **THEN** it SHALL call the local Ollama chat API via the `ollama:chat` provider
- **AND** it SHALL send the test prompt as the user message
- **AND** it SHALL capture the generated assistant response.

#### Scenario: Ollama is unavailable

- **GIVEN** the Ollama server is not reachable
- **WHEN** promptfoo executes
- **THEN** the evaluation SHALL fail
- **AND** it SHALL return a non-zero status code.

---

### Requirement: Contract-based output assertions

The system SHALL evaluate local SLM outputs using promptfoo's deterministic
contract-based assertions rather than exact output matching. The assertion semantics
mirror the prior custom runner: a required-any term set, a required-all term set, and a
forbidden term set, all matched case-insensitively (the prior runner lowercased both the
output and the terms).

#### Scenario: Required-any assertion passes

- **GIVEN** an eval case defines an `icontains-any` assertion
- **AND** the model output contains at least one listed term (case-insensitive)
- **WHEN** promptfoo evaluates the output
- **THEN** the assertion SHALL pass.

#### Scenario: Required-any assertion fails

- **GIVEN** an eval case defines an `icontains-any` assertion
- **AND** the model output contains none of the listed terms
- **WHEN** promptfoo evaluates the output
- **THEN** the assertion SHALL fail.

#### Scenario: Required-all assertion passes

- **GIVEN** an eval case defines an `icontains-all` assertion
- **AND** the model output contains every listed term (case-insensitive)
- **WHEN** promptfoo evaluates the output
- **THEN** the assertion SHALL pass.

#### Scenario: Required-all assertion fails

- **GIVEN** an eval case defines an `icontains-all` assertion
- **AND** the model output omits at least one listed term
- **WHEN** promptfoo evaluates the output
- **THEN** the assertion SHALL fail.

#### Scenario: Forbidden-term assertion passes

- **GIVEN** an eval case defines a `not-icontains-any` assertion
- **AND** the model output contains none of the listed terms (case-insensitive)
- **WHEN** promptfoo evaluates the output
- **THEN** the assertion SHALL pass.

#### Scenario: Forbidden-term assertion fails

- **GIVEN** an eval case defines a `not-icontains-any` assertion
- **AND** the model output contains at least one listed term (case-insensitive)
- **WHEN** promptfoo evaluates the output
- **THEN** the assertion SHALL fail.

---

### Requirement: Slop footer reporting

The eval suite SHALL treat the `slop:` footer as advisory: it SHALL report whether the
footer is present, but a missing footer SHALL NOT fail the smoke test. This is
implemented as a promptfoo `regex` assertion with `weight: 0`, so footer presence is
tracked as a metric without affecting the case pass/fail outcome. The footer is a skill
feature built on the stop-slop machinery and a multi-pass self-scoring loop, which a
bare system-prompted local model (with no stop-slop skill installed in CI) cannot
reliably perform.

#### Scenario: Footer present

- **GIVEN** the model output contains a `slop: N/10` footer
- **WHEN** promptfoo evaluates the output
- **THEN** the advisory assertion SHALL record the footer as present
- **AND** the case SHALL NOT fail on the footer.

#### Scenario: Footer absent

- **GIVEN** the model output does not contain a `slop:` footer
- **WHEN** promptfoo evaluates the output
- **THEN** the advisory assertion SHALL record the footer as absent
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

The system SHALL run deterministic linting and local SLM smoke tests (executed via
promptfoo) in GitHub Actions.

#### Scenario: Pull request validation

- **GIVEN** a pull request is opened
- **WHEN** GitHub Actions runs the skill CI workflow
- **THEN** the lint job SHALL execute
- **AND** the promptfoo SLM smoke test job SHALL execute.

#### Scenario: Push validation

- **GIVEN** code is pushed to `main`
- **WHEN** GitHub Actions runs the skill CI workflow
- **THEN** the lint job SHALL execute
- **AND** the promptfoo SLM smoke test job SHALL execute.

#### Scenario: Manual validation

- **GIVEN** a maintainer manually triggers the workflow
- **WHEN** GitHub Actions runs the skill CI workflow
- **THEN** the lint job SHALL execute
- **AND** the promptfoo SLM smoke test job SHALL execute.

#### Scenario: English matrix entry

- **GIVEN** the promptfoo SLM smoke test job runs
- **WHEN** the matrix entry language is `en`
- **THEN** the workflow SHALL pull the configured English model
- **AND** the workflow SHALL run the English promptfoo eval test set.

#### Scenario: Polish matrix entry

- **GIVEN** the promptfoo SLM smoke test job runs
- **WHEN** the matrix entry language is `pl`
- **THEN** the workflow SHALL pull the configured Polish model
- **AND** the workflow SHALL run the Polish promptfoo eval test set.

---

### Requirement: Local execution documentation

The system SHALL document how to run deterministic and model-based (promptfoo) tests
locally.

#### Scenario: Run lint locally

- **GIVEN** a developer has Python available
- **WHEN** the developer runs `python tools/skill_lint.py`
- **THEN** the skill package SHALL be validated locally.

#### Scenario: Run English eval locally

- **GIVEN** Ollama is installed
- **AND** the configured eval model (`gemma4:e4b-it-qat`) is available
- **WHEN** the developer runs the English promptfoo eval
- **THEN** English skill smoke tests SHALL execute locally.

#### Scenario: Run Polish eval locally

- **GIVEN** Ollama is installed
- **AND** the configured eval model (`gemma4:e4b-it-qat`) is available
- **WHEN** the developer runs the Polish promptfoo eval
- **THEN** Polish skill smoke tests SHALL execute locally.

### Requirement: Manual release validation boundary

The system SHALL document that local SLM smoke tests do not replace manual Claude Code plugin validation.

#### Scenario: Preparing a release

- **GIVEN** the CI checks pass
- **WHEN** a maintainer prepares a release
- **THEN** the maintainer SHOULD run the skill manually in Claude Code
- **AND** the maintainer SHOULD verify that Claude Code discovers and invokes the skill correctly.

### Requirement: Per-behaviour eval file organization

The eval suite SHALL organise its EN and PL smoke-test cases as one test file per persona
behaviour, so coverage can grow per behaviour without editing a single monolithic
per-language file.

#### Scenario: Cases grouped by behaviour

- **GIVEN** the promptfoo eval suite
- **WHEN** a maintainer inspects the test files
- **THEN** each persona behaviour SHALL have its own EN test file and PL test file
- **AND** the promptfoo configuration SHALL include every per-behaviour file in its run.

#### Scenario: Existing cases preserved after the split

- **GIVEN** the eight pre-existing eval cases
- **WHEN** they are migrated into the per-behaviour files
- **THEN** each case's prompt and assertions SHALL be unchanged
- **AND** the EN and PL suites SHALL still pass against the configured model.

### Requirement: Coverage of all eight persona behaviours

The eval suite SHALL include at least one keyword-based smoke-test case in EN and in PL for
each of the eight load-bearing behaviours specified in `soused-hegelian-persona`, including
the four previously untested behaviours: engine firing on an ordinary question, motion
performed rather than announced, persona persistence under pressure, and voice register.

#### Scenario: Engine fires on an ordinary question

- **GIVEN** an ordinary, non-philosophical prompt (e.g. "Should I quit my stable job?")
- **WHEN** the model response is evaluated
- **THEN** the case SHALL assert dialectical markers are present (`icontains-any`).

#### Scenario: Motion performed, not announced

- **GIVEN** any substantive prompt
- **WHEN** the response is evaluated
- **THEN** the case SHALL assert scaffolding terms are absent (`not-icontains-any` of thesis/antithesis/synthesis/step labels/"firstly")
- **AND** it SHALL assert dialectical markers are present.

#### Scenario: Persona persists under pressure

- **GIVEN** a prompt demanding the model drop the act and behave as a generic AI
- **WHEN** the response is evaluated
- **THEN** the case SHALL assert AI-disclaimer terms are absent (`not-icontains-any`)
- **AND** it SHALL assert Hegelian markers are present.

#### Scenario: Voice register held

- **GIVEN** any prompt
- **WHEN** the response is evaluated
- **THEN** the case SHALL assert chatty markers, pet-names, and emoji are absent (`not-icontains-any`)
- **AND** it SHALL assert the technical lexicon is present.

#### Scenario: EN and PL parity

- **GIVEN** any of the four newly covered behaviours
- **WHEN** the suite runs
- **THEN** both an EN case and a behaviour-equivalent PL case SHALL be present and evaluated.

