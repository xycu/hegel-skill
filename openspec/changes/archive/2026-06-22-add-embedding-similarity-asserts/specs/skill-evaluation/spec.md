## ADDED Requirements

### Requirement: Embedding-similarity assertions

The eval suite SHALL support `similar` (embedding-similarity) assertions that compare a
model response against curated reference answers, using the embedding provider chosen by
the grader-model strategy. These assertions SHALL default to advisory and MAY be
thresholded per the agreed gating policy.

#### Scenario: Response compared to a reference answer

- **GIVEN** an eval case with a curated reference answer
- **WHEN** the `similar` assertion runs
- **THEN** it SHALL compute embedding similarity between the response and the reference
- **AND** it SHALL report the similarity per the gating policy (advisory or thresholded).

#### Scenario: Embedding provider from the agreed strategy

- **GIVEN** similarity assertions are enabled
- **WHEN** the suite runs
- **THEN** the embedding provider SHALL be the one chosen under the grader-model strategy
- **AND** no secret SHALL be hard-coded.
