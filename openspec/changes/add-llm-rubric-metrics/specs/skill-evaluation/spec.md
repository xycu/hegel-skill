## ADDED Requirements

### Requirement: LLM-rubric quality assertions

The eval suite SHALL grade literary/behavioural quality with `llm-rubric` assertions, in
EN and PL, covering voice register, dialectical-engine adherence (performed not
announced), citation fidelity, and in-character technical dismissal. Rubric assertions
SHALL default to advisory (weight 0) and MAY be promoted to thresholded per the agreed
gating policy. Cases previously disabled for keyword brittleness SHALL be re-enabled under
rubric grading.

#### Scenario: Voice register graded semantically

- **GIVEN** a model response to any prompt
- **WHEN** the voice-register rubric runs
- **THEN** it SHALL grade whether the register is elevated and in character
- **AND** it SHALL not depend on a fixed keyword list.

#### Scenario: Dialectic graded as performed, not announced

- **GIVEN** a substantive response
- **WHEN** the dialectical-adherence rubric runs
- **THEN** it SHALL grade whether a determinate negation and sublation are performed
- **AND** whether textbook scaffolding is avoided.

#### Scenario: Citation fidelity graded

- **GIVEN** a response that references Hegel's works
- **WHEN** the citation rubric runs
- **THEN** it SHALL grade whether named works are real and quotes are not fabricated.

#### Scenario: Previously-disabled cases re-enabled under rubric

- **GIVEN** the cases disabled for keyword brittleness (persona-persistence, technical-dismissal-mundane, motion-not-announced)
- **WHEN** they are re-enabled with rubric assertions
- **THEN** they SHALL grade behaviour semantically at the skill's normal high temperature
- **AND** they SHALL no longer rely on brittle keyword lists.
