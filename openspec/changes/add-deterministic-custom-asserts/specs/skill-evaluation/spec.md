## ADDED Requirements

### Requirement: Deterministic custom assertions

The eval suite SHALL support deterministic custom (code) assertions — promptfoo
`javascript` or `python` asserts — for quality checks that need no judge model, network,
or secrets.

#### Scenario: Footer score parsed as a metric

- **GIVEN** a model output that contains a `slop: N/10` footer
- **WHEN** the custom assert runs
- **THEN** it SHALL extract the numeric score as a reported metric
- **AND** it SHALL not require any network call or secret.

#### Scenario: Deterministic structural check

- **GIVEN** an eval case with a deterministic structural assert
- **WHEN** promptfoo evaluates the output
- **THEN** the custom assert SHALL run as part of the case
- **AND** its result SHALL be recorded alongside the keyword assertions.
