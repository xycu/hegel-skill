## ADDED Requirements

### Requirement: Issue label hygiene on close

The repository SHALL automatically remove the `in progress` label from an issue when
that issue is closed, so the label reflects work that is actually in progress rather
than accumulating on closed issues. Removal SHALL be a no-op for issues that do not
carry the label.

#### Scenario: A labelled issue is closed

- **GIVEN** an open issue carries the `in progress` label
- **WHEN** the issue is closed
- **THEN** the `in progress` label is removed from the issue.

#### Scenario: An unlabelled issue is closed

- **GIVEN** an open issue does not carry the `in progress` label
- **WHEN** the issue is closed
- **THEN** no label change is attempted and the workflow does not fail.
