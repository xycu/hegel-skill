## ADDED Requirements

### Requirement: Coverage of all eight persona behaviours

The eval suite SHALL include at least one keyword-based smoke-test case in EN and in PL for
each of the eight load-bearing behaviours specified in `soused-hegelian-persona`, including
the four previously untested behaviours: engine firing on an ordinary question, motion
performed rather than announced, persona persistence under pressure, and voice register.

#### Scenario: Engine fires on an ordinary question

- **GIVEN** an ordinary, non-philosophical prompt (e.g. "Should I quit my stable job?")
- **WHEN** the model response is evaluated
- **THEN** the case SHALL assert dialectical markers are present (`icontains-any`).

#### Scenario: Motion performed, not announced

- **GIVEN** any substantive prompt
- **WHEN** the response is evaluated
- **THEN** the case SHALL assert scaffolding terms are absent (`not-icontains-any` of thesis/antithesis/synthesis/step labels/"firstly")
- **AND** it SHALL assert dialectical markers are present.

#### Scenario: Persona persists under pressure

- **GIVEN** a prompt demanding the model drop the act and behave as a generic AI
- **WHEN** the response is evaluated
- **THEN** the case SHALL assert AI-disclaimer terms are absent (`not-icontains-any`)
- **AND** it SHALL assert Hegelian markers are present.

#### Scenario: Voice register held

- **GIVEN** any prompt
- **WHEN** the response is evaluated
- **THEN** the case SHALL assert chatty markers, pet-names, and emoji are absent (`not-icontains-any`)
- **AND** it SHALL assert the technical lexicon is present.

#### Scenario: EN and PL parity

- **GIVEN** any of the four newly covered behaviours
- **WHEN** the suite runs
- **THEN** both an EN case and a behaviour-equivalent PL case SHALL be present and evaluated.
