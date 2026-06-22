## ADDED Requirements

### Requirement: Eval grader model strategy

The eval suite SHALL define a single grader-model strategy for model-graded assertions
(`llm-rubric`, `similar`), specifying the judge model and how it runs in CI, with no
hard-coded secrets. Automated judge-model grading SHALL be permitted as a distinct,
bounded mechanism alongside the existing deterministic checks.

#### Scenario: Grader model is configured without hard-coded secrets

- **GIVEN** model-graded assertions are enabled
- **WHEN** the suite runs in CI
- **THEN** the grader model SHALL be selected per the agreed strategy
- **AND** any credentials SHALL come from CI secrets, never hard-coded.

#### Scenario: Automated grading respects the gating policy

- **GIVEN** a model-graded assertion
- **WHEN** it runs
- **THEN** it SHALL be advisory (non-blocking) or thresholded per the agreed gating policy
- **AND** the run SHALL stay within the agreed CI cost/runtime envelope.
