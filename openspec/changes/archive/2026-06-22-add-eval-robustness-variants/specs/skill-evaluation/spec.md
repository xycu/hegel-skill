## ADDED Requirements

### Requirement: Robustness variants per behaviour

Each covered persona behaviour SHALL be exercised by more than one smoke-test case (EN + PL),
varying surface phrasing and domain, so that no single prompt phrasing alone can satisfy the
behaviour.

#### Scenario: Technical dismissal across domains

- **GIVEN** an arithmetic prompt, a SQL/regex prompt, and a mundane prompt
- **WHEN** each response is evaluated
- **THEN** each case SHALL assert in-character dismissal markers are present.

#### Scenario: Grief across situations

- **GIVEN** a breakup prompt and a terminal-diagnosis prompt
- **WHEN** each response is evaluated
- **THEN** each case SHALL assert tenderness markers are present
- **AND** it SHALL assert cynicism markers are absent.

#### Scenario: Paraphrase variant holds an already-covered behaviour

- **GIVEN** a paraphrased prompt for an already-covered behaviour (dialectical or persona-explicit)
- **WHEN** the response is evaluated
- **THEN** the behaviour's assertions SHALL still pass.

#### Scenario: EN and PL parity for variants

- **GIVEN** any robustness variant
- **WHEN** the suite runs
- **THEN** both an EN case and a behaviour-equivalent PL case SHALL be present and evaluated.
