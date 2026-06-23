## ADDED Requirements

### Requirement: GitHub configuration as code

The repository's GitHub configuration SHALL be defined as version-controlled IaC using
OpenTofu, with remote state held in a versioned GCS bucket, so it is backed up and
drift-detectable. The system SHALL NOT depend on hand-applied console changes for any
managed setting. This MUST cover repo settings, branch protection, the signed-commits
ruleset, the `evals` environment with its reviewers and prevent-self-review setting,
labels, and Actions variables.

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

### Requirement: Keyless GitHub-to-GCP authentication

The plan workflow SHALL authenticate to GCP via Workload Identity Federation (OIDC). The
system SHALL NOT store long-lived service-account keys in the repository, in CI secrets,
or in IaC state. The federated principal SHALL hold least-privilege IAM — read/write to the
state bucket only, with no Cloud Run, Artifact Registry, or Secret Manager grants.

#### Scenario: CI authenticates without stored keys

- **GIVEN** a CI workflow that needs to read or write IaC state
- **WHEN** the workflow authenticates to GCP
- **THEN** it SHALL exchange a GitHub OIDC token through the Workload Identity provider
- **AND** no service-account JSON key SHALL be required.

#### Scenario: Federation is scoped to this repository

- **GIVEN** the Workload Identity provider configuration
- **WHEN** an OIDC token is presented
- **THEN** the provider SHALL only trust tokens issued for this repository.

#### Scenario: Plan is reviewable on a pull request

- **GIVEN** a change to the IaC under review
- **WHEN** the pull-request workflow runs
- **THEN** it SHALL produce an OpenTofu plan
- **AND** the plan SHALL be visible on the pull request before any apply.

### Requirement: Fast eval gate on every pull request

Every pull request that touches the skill, evals, or tooling SHALL run a fast eval gate:
the deterministic skill lint plus the three core behaviours (`dialectical`, `grief`,
`technical-dismissal`) in English and Polish. The slow model-graded asserts (`llm-rubric`
and `similar`) SHALL be disabled for this run so it completes well within the runner
timeout. The run SHALL remain behind the `evals` environment manual-approval gate, and its
outcome SHALL be posted via the existing sticky eval-results comment.

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

### Requirement: Nightly full eval suite

A scheduled nightly workflow SHALL run the full eval suite: all behaviours — the three core
plus the five restored cases (`motion-not-announced`, `ordinary-engine`, `persona-explicit`,
`persona-persistence`, `voice-register`) — in English and Polish, with the `llm-rubric` and
`similar` semantic asserts enabled. It SHALL run on `ubuntu-latest` with a timeout long
enough for the full graded suite, and SHALL surface its pass/fail outcome where the
maintainer can see it (a job summary and/or a tracking issue).

#### Scenario: Nightly runs the full graded suite

- **GIVEN** the nightly schedule fires
- **WHEN** the nightly workflow runs
- **THEN** it SHALL run all eight behaviours EN+PL with the `llm-rubric` and `similar`
  asserts enabled
- **AND** it SHALL run without the per-PR manual-approval gate (no PR to approve).

#### Scenario: Restored behaviours are exercised nightly

- **GIVEN** the five previously parked behaviours have been restored under `promptfoo/tests/`
- **WHEN** the nightly suite runs
- **THEN** each restored behaviour SHALL be graded EN+PL
- **AND** a failure in any of them SHALL mark the nightly run as failed.

#### Scenario: Nightly outcome is visible

- **GIVEN** the nightly run has finished
- **WHEN** the maintainer inspects the result
- **THEN** the pass/fail outcome and per-suite counts SHALL be available without opening
  individual job logs.
