## ADDED Requirements

### Requirement: Local-first eval tuning gate

New or changed eval cases SHALL be run and tuned to green against the local Ollama model
before being pushed, so that CI is not used to discover keyword-list misfires.

#### Scenario: Cases green locally before push

- **GIVEN** new or modified eval cases
- **WHEN** the maintainer runs `./run-tests.sh`
- **THEN** the EN and PL suites SHALL pass locally
- **AND** the changes SHALL be pushed only after that local pass.

#### Scenario: Keyword lists tuned to the local model

- **GIVEN** a case fails locally because its keyword list misfires on the model output
- **WHEN** the maintainer tunes the assertion terms
- **THEN** the case SHALL pass locally
- **AND** the tuning SHALL NOT weaken the behaviour the case checks.
