## ADDED Requirements

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
