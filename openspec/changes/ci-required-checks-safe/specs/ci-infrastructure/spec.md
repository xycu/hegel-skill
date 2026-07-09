## MODIFIED Requirements

### Requirement: GitHub configuration as code

The repository's GitHub configuration SHALL be defined as version-controlled IaC using
OpenTofu, with remote state held in a versioned GCS bucket, so it is backed up and
drift-detectable. The system SHALL NOT depend on hand-applied console changes for any
managed setting. This MUST cover repo settings, branch protection (including required
status checks on `main`), the signed-commits ruleset, the `evals` environment with its
reviewers and prevent-self-review setting, labels, and Actions variables.

#### Scenario: Restore reproduces live configuration

- **GIVEN** the GitHub configuration is managed by IaC
- **WHEN** the configuration is destroyed and re-applied
- **THEN** the resulting live settings SHALL match the IaC definition
- **AND** the `evals` environment, its reviewers, and prevent-self-review SHALL be restored.

#### Scenario: Drift is detectable

- **GIVEN** a setting is changed in the GitHub web UI out-of-band
- **WHEN** an OpenTofu plan is run
- **THEN** the plan SHALL report the drift against the IaC definition.

#### Scenario: State is remote and versioned

- **GIVEN** the IaC backend is configured
- **WHEN** an apply writes state
- **THEN** the state SHALL be stored in the GCS backend, not on a contributor's machine
- **AND** the backend bucket SHALL have object versioning enabled.

#### Scenario: Required status checks are backed up as code

- **GIVEN** the `main` branch protection requires the `lint` and `core-slm-smoke` (en/pl)
  status checks
- **WHEN** the GitHub configuration is destroyed and re-applied from IaC
- **THEN** the same status checks SHALL be required on `main` afterward
- **AND** no maintainer SHALL need to re-configure required checks by hand in the GitHub
  UI.

### Requirement: Fast eval gate on every pull request

Every pull request that touches the skill, evals, or tooling SHALL run a fast eval gate:
the deterministic skill lint plus the three core behaviours (`dialectical`, `grief`,
`technical-dismissal`) in English and Polish. The slow model-graded asserts (`llm-rubric`
and `similar`) SHALL be disabled for this run so it completes well within the runner
timeout. The run SHALL remain behind the `evals` environment manual-approval gate, and its
outcome SHALL be posted via the existing sticky eval-results comment. Every job that
contributes to this gate (`lint`, and each blocking `core-slm-smoke` matrix leg) SHALL
report a terminal GitHub status context — success, skipped, or failure, never left
unreported in `pending` — on every pull request, regardless of which files the pull
request changes, so that these checks are safe to mark as required on `main` without
wedging pull requests that don't touch the watched paths.

#### Scenario: Pull request runs the fast subset

- **GIVEN** a pull request that changes skill, eval, or tooling files
- **WHEN** Skill CI runs after the eval run is approved
- **THEN** it SHALL run the deterministic lint and the three core behaviours EN+PL
- **AND** it SHALL NOT run the `llm-rubric` or `similar` model-graded asserts.

#### Scenario: A failing core behaviour blocks the pull request

- **GIVEN** the fast eval gate is running on a pull request
- **WHEN** any core-behaviour case fails (100% gate)
- **THEN** the eval stage SHALL fail
- **AND** the result SHALL be posted to the pull request via the sticky eval-results comment.

#### Scenario: Eval run waits for approval

- **GIVEN** a pull request that triggers the eval run
- **WHEN** the workflow reaches the eval stage
- **THEN** it SHALL wait on the `evals` environment for a maintainer's approval before any
  eval runner starts.

#### Scenario: Unrelated pull request satisfies the gate without running it

- **GIVEN** a pull request that changes no path matched by the skill/eval/tooling filter
- **WHEN** Skill CI runs
- **THEN** the `lint` and `core-slm-smoke` (en/pl) jobs SHALL each be skipped and report a
  `skipped` status context under their required job name
- **AND** the `evals` environment approval prompt, the lint checks, and the Ollama-backed
  eval runs SHALL NOT execute.

#### Scenario: Required checks never stay pending

- **GIVEN** the `lint` and `core-slm-smoke` (en/pl) status checks are marked required on
  `main`
- **WHEN** any pull request is opened, regardless of the paths it touches
- **THEN** each required check SHALL reach a terminal state (success or failure)
- **AND** none SHALL remain in `Pending` indefinitely.
