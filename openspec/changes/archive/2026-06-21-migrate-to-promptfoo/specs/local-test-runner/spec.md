## MODIFIED Requirements

### Requirement: Single-command local test runner

The system SHALL provide a single executable command, runnable from the repository
root, that runs every existing local test: the deterministic skill lint and the
promptfoo SLM evals for English and Polish. (The former custom eval-runner unit stage is
removed, because the bespoke runner it tested no longer exists — its assertion logic is
now promptfoo's.)

#### Scenario: Run all tests

- **GIVEN** a developer is in the repository root
- **AND** Python 3.12 is available
- **AND** an Ollama server is running with the configured model pulled
- **WHEN** the developer runs the test runner with no arguments
- **THEN** the runner SHALL execute the deterministic skill lint
- **AND** the runner SHALL execute the English promptfoo SLM evals
- **AND** the runner SHALL execute the Polish promptfoo SLM evals.

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

The local test runner SHALL run the promptfoo SLM evals the same way CI does, so a local
pass predicts a CI pass. It SHALL NOT silently skip the SLM evals.

#### Scenario: Default model and eval sets match CI

- **GIVEN** the developer runs the test runner with no model override
- **WHEN** the promptfoo SLM eval stages execute
- **THEN** the runner SHALL use the same default model as the CI behavioural gate (`gemma4:e4b-it-qat`)
- **AND** the English stage SHALL run the English promptfoo eval test set
- **AND** the Polish stage SHALL run the Polish promptfoo eval test set.

#### Scenario: Ollama is not installed

- **GIVEN** Ollama is neither running nor installed
- **WHEN** the test runner executes
- **THEN** the runner SHALL fail
- **AND** the runner SHALL exit with a non-zero status code
- **AND** the runner SHALL report that Ollama is unavailable.

#### Scenario: Configured model is not present locally

- **GIVEN** the Ollama server is reachable
- **AND** the configured model is not present locally
- **WHEN** the test runner reaches the promptfoo SLM eval stages
- **THEN** the runner SHALL pull the configured model automatically
- **AND** the promptfoo SLM eval stages SHALL then run against it.

#### Scenario: Configured model cannot be pulled

- **GIVEN** the Ollama server is reachable
- **AND** the configured model is not present locally
- **AND** the model cannot be pulled (e.g. the name is invalid)
- **WHEN** the test runner attempts to pull it
- **THEN** the runner SHALL fail
- **AND** the runner SHALL exit with a non-zero status code.
