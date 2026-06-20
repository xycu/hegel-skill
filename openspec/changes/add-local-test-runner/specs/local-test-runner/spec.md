## ADDED Requirements

### Requirement: Single-command local test runner

The system SHALL provide a single executable command, runnable from the repository
root, that runs every existing local test: the deterministic skill lint, the
eval-runner unit test, and the SLM evals for English and Polish.

#### Scenario: Run all tests

- **GIVEN** a developer is in the repository root
- **AND** Python 3.12 is available
- **AND** an Ollama server is running with the configured model pulled
- **WHEN** the developer runs the test runner with no arguments
- **THEN** the runner SHALL execute the deterministic skill lint
- **AND** the runner SHALL execute the eval-runner unit test
- **AND** the runner SHALL execute the English SLM evals
- **AND** the runner SHALL execute the Polish SLM evals.

#### Scenario: All stages pass

- **GIVEN** every test stage succeeds
- **WHEN** the test runner finishes
- **THEN** the runner SHALL exit with status code `0`
- **AND** the runner SHALL print a summary showing each stage as passed.

#### Scenario: A stage fails

- **GIVEN** at least one test stage fails
- **WHEN** the test runner finishes
- **THEN** the runner SHALL exit with a non-zero status code
- **AND** the summary SHALL identify which stage(s) failed.

---

### Requirement: CI-mirroring eval execution

The local test runner SHALL run the SLM evals the same way CI does, so a local pass
predicts a CI pass. It SHALL NOT silently skip the SLM evals.

#### Scenario: Default model and eval files match CI

- **GIVEN** the developer runs the test runner with no model override
- **WHEN** the SLM eval stages execute
- **THEN** the runner SHALL use the same default model as the CI behavioural gate (`gemma4:e4b-it-qat`)
- **AND** the English stage SHALL run `evals/hegel_skill_cases.en.json`
- **AND** the Polish stage SHALL run `evals/hegel_skill_cases.pl.json`.

#### Scenario: Ollama is unavailable

- **GIVEN** the Ollama server is not reachable
- **WHEN** the test runner executes
- **THEN** the runner SHALL fail
- **AND** the runner SHALL exit with a non-zero status code
- **AND** the runner SHALL report that Ollama is unreachable.

#### Scenario: Configured model is not available

- **GIVEN** the Ollama server is reachable
- **AND** the configured model is not present locally
- **WHEN** the SLM eval stage executes
- **THEN** the runner SHALL fail
- **AND** the runner SHALL exit with a non-zero status code.

---

### Requirement: Model override

The test runner SHALL allow the developer to override the eval model for local
experimentation without editing the script.

#### Scenario: Override the model

- **GIVEN** the developer wants to run the evals against a different Ollama model
- **WHEN** the developer supplies a model override (argument or environment variable)
- **THEN** the SLM eval stages SHALL use the supplied model
- **AND** the deterministic stages SHALL run unchanged.

---

### Requirement: Local execution documentation

The system SHALL document the single command as the canonical way to run all tests
locally before pushing.

#### Scenario: Documented command

- **GIVEN** a developer reads the project documentation
- **WHEN** they look for how to run all tests locally
- **THEN** the documentation SHALL name the single root-level command
- **AND** it SHALL state the prerequisites (Python and a running Ollama with the model pulled).
