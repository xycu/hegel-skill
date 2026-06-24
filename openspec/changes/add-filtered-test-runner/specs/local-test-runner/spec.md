## ADDED Requirements

### Requirement: Filter the eval stages to a single behaviour

The local test runner SHALL accept an optional filter argument (`-k <pattern>` or
`--filter <pattern>`) that narrows the promptfoo eval stages to the cases whose
description matches `<pattern>`. The pattern SHALL be passed through to promptfoo's
description filter unchanged. When no filter argument is given, the runner SHALL run
every behaviour in both languages exactly as it does today.

#### Scenario: A filter narrows the run to matching cases

- **GIVEN** a developer runs the test runner with `-k persona-persistence`
- **WHEN** the eval stages execute
- **THEN** only cases whose description matches `persona-persistence` are evaluated
- **AND** cases that do not match are not evaluated.

#### Scenario: No filter runs the full suite

- **GIVEN** a developer runs the test runner with no filter argument
- **WHEN** the eval stages execute
- **THEN** every behaviour in both languages is evaluated, unchanged from the default behaviour.

#### Scenario: A language with no matching cases passes

- **GIVEN** a filter that matches cases in only one language (e.g. `en-grief$`)
- **WHEN** the eval stage for the other language runs
- **THEN** that stage evaluates zero cases and SHALL be reported as passed, not failed.

#### Scenario: The filter coexists with the model argument

- **GIVEN** the runner is invoked with both a model override and a filter
- **WHEN** the runner parses its arguments
- **THEN** the model override is honoured for the eval stages
- **AND** the filter narrows those stages to the matching cases.
