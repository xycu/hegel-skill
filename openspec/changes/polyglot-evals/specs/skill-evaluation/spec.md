## ADDED Requirements

### Requirement: German skill smoke tests
The system SHALL include German eval cases, at core parity with the EN and PL
suites, that verify basic behaviour of the `soused-hegelian` skill in German:
explicit persona summon, dialectical engine, technical dismissal, and grief
handling. The German cases SHALL gate their eval stage (not advisory), and their
keyword lists SHALL use German's native philosophical forms (e.g. *Geist*,
*Aufhebung*, *Vernunft*, and whatever inflected forms the model actually
produces), tuned local-first.

#### Scenario: Explicit Brandt prompt in German
- **WHEN** a German prompt explicitly asks for Doktor Brandt and the eval runner executes the case
- **THEN** the output SHALL be in German, SHALL include at least one Hegelian marker, and SHALL NOT include generic AI-disclaimer language in German

#### Scenario: Dialectical prompt in German
- **WHEN** a German prompt asks for a dialectical answer
- **THEN** the output SHALL include at least one German dialectical marker

#### Scenario: Technical prompt in German
- **WHEN** a German prompt asks the skill to debug code
- **THEN** the output SHALL redirect or dismiss the request in character and SHALL NOT provide normal coding output

#### Scenario: Grief prompt in German
- **WHEN** a German prompt expresses grief or despair
- **THEN** the output SHALL avoid treating the prompt as a merely technical question

#### Scenario: The German suite gates
- **WHEN** a German core case fails
- **THEN** the German eval stage SHALL fail (the cases are gating, not advisory)

### Requirement: Latin skill smoke tests
The system SHALL include Latin eval cases, at core parity with the EN and PL
suites, that verify basic behaviour of the `soused-hegelian` skill in Latin:
explicit persona summon, dialectical engine, technical dismissal, and grief
handling. The Latin cases SHALL gate their eval stage (not advisory), and their
keyword lists SHALL use established Latin philosophical vocabulary, tuned
local-first against what the configured model actually produces.

#### Scenario: Explicit Brandt prompt in Latin
- **WHEN** a Latin prompt explicitly asks for Doktor Brandt and the eval runner executes the case
- **THEN** the output SHALL be in Latin, SHALL include at least one Hegelian marker in Latin, and SHALL NOT include generic AI-disclaimer language

#### Scenario: Dialectical prompt in Latin
- **WHEN** a Latin prompt asks for a dialectical answer
- **THEN** the output SHALL include at least one Latin dialectical marker

#### Scenario: Technical prompt in Latin
- **WHEN** a Latin prompt asks the skill to solve a merely technical matter
- **THEN** the output SHALL redirect or dismiss the request in character and SHALL NOT provide the literal technical resolution

#### Scenario: Grief prompt in Latin
- **WHEN** a Latin prompt expresses grief or despair
- **THEN** the output SHALL avoid treating the prompt as a merely technical question

#### Scenario: The Latin suite gates
- **WHEN** a Latin core case fails
- **THEN** the Latin eval stage SHALL fail (the cases are gating, not advisory)

### Requirement: Light multilingual smoke coverage
The suite SHALL include a light smoke check for additional languages beyond
EN, PL, DE, and LA — at least French, Spanish, and Italian: at minimum one case
per language asserting that the reply is in the question's language and carries
at least one in-language persona marker. Light cases SHALL gate their stage but
SHALL NOT be required to reach core-suite parity; adding a further language
SHALL follow the same one-case light pattern.

#### Scenario: Answer-in-language per additional language
- **WHEN** the light multilingual smoke stage runs a case for an additional language
- **THEN** the case asserts the reply is in that language and includes at least one in-language persona marker

#### Scenario: Light rigor is bounded
- **WHEN** the light cases for an additional language are defined
- **THEN** they assert only the in-language reply and persona-marker behaviour, and the language is not required to carry core-parity coverage

#### Scenario: A new language joins lightly
- **WHEN** a maintainer adds eval coverage for a language beyond the four rigorous ones
- **THEN** the one-case light pattern is used, keeping the multilingual stage cheap

### Requirement: The polyglot behaviour is documented
The README SHALL advertise that Brandt answers in the language of the question,
and SHALL state the evaluation tiers: full suites (EN, PL), core gating suites
(DE, LA), and light smoke coverage (additional languages).

#### Scenario: README states languages and tiers
- **WHEN** a user reads the README
- **THEN** it states that Brandt replies in the language he is addressed in and lists which languages are evaluated at which rigor tier
