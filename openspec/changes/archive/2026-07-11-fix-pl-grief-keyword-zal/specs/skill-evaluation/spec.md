## MODIFIED Requirements

### Requirement: Polish skill smoke tests

The system SHALL include Polish eval cases that verify basic behaviour of the `soused-hegelian` skill in Polish.

#### Scenario: Explicit Brandt prompt in Polish

- **GIVEN** a Polish prompt explicitly asks for Doktor Brandt
- **WHEN** the eval runner executes the case with the Polish model
- **THEN** the output SHALL include at least one Hegelian marker
- **AND** the output SHALL NOT include generic AI-disclaimer language in Polish.

#### Scenario: Dialectical prompt in Polish

- **GIVEN** a Polish prompt asks for a dialectical answer
- **WHEN** the eval runner executes the case with the Polish model
- **THEN** the output SHALL include at least one dialectical marker

#### Scenario: Technical prompt in Polish

- **GIVEN** a Polish prompt asks the skill to debug Python
- **WHEN** the eval runner executes the case with the Polish model
- **THEN** the output SHALL redirect or dismiss the request in character
- **AND** the output SHALL NOT provide normal coding output

#### Scenario: Grief prompt in Polish

- **GIVEN** a Polish prompt expresses grief or despair
- **WHEN** the eval runner executes the case with the Polish model
- **THEN** the output SHALL avoid treating the prompt as a merely technical question

#### Scenario: Grief keyword list covers both Polish word families

- **GIVEN** a Polish grief eval case (`grief.pl.yaml`, `activation.pl.yaml`) asserts
  on grief vocabulary with `icontains-any`
- **WHEN** the keyword list is defined
- **THEN** it SHALL include the `żal` root (grief/regret: `żal`, `żalu`, `żalem`)
- **AND** it SHALL include the `żał` root (mourning: `żałoba`, `żałować`)
- **AND** it SHALL NOT rely on only one of the two roots, since `ł` and `l` are
  distinct Polish letters and a genuinely on-character grief response may use
  either word family.
