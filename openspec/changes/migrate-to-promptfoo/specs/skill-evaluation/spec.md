## MODIFIED Requirements

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
forbidden term set (case-insensitive).

#### Scenario: Required-any assertion passes

- **GIVEN** an eval case defines a `contains-any` assertion
- **AND** the model output contains at least one listed term
- **WHEN** promptfoo evaluates the output
- **THEN** the assertion SHALL pass.

#### Scenario: Required-any assertion fails

- **GIVEN** an eval case defines a `contains-any` assertion
- **AND** the model output contains none of the listed terms
- **WHEN** promptfoo evaluates the output
- **THEN** the assertion SHALL fail.

#### Scenario: Required-all assertion passes

- **GIVEN** an eval case defines a `contains-all` assertion
- **AND** the model output contains every listed term
- **WHEN** promptfoo evaluates the output
- **THEN** the assertion SHALL pass.

#### Scenario: Required-all assertion fails

- **GIVEN** an eval case defines a `contains-all` assertion
- **AND** the model output omits at least one listed term
- **WHEN** promptfoo evaluates the output
- **THEN** the assertion SHALL fail.

#### Scenario: Forbidden-term assertion passes

- **GIVEN** an eval case defines a `not-icontains` assertion
- **AND** the model output contains none of the listed terms (case-insensitive)
- **WHEN** promptfoo evaluates the output
- **THEN** the assertion SHALL pass.

#### Scenario: Forbidden-term assertion fails

- **GIVEN** an eval case defines a `not-icontains` assertion
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
