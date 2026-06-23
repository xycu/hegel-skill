## ADDED Requirements

### Requirement: Infrastructure defined as code

The CI/eval environment and the repository's GitHub configuration SHALL be defined as
version-controlled IaC using OpenTofu, with remote state held in a versioned GCS bucket.
The system SHALL NOT depend on hand-applied console changes for any managed resource.

#### Scenario: Provision from clean state

- **GIVEN** an empty GCP project and the IaC remote state initialised
- **WHEN** the maintainer runs `tofu apply`
- **THEN** the GCP eval resources (Artifact Registry, Cloud Run Job, Secret Manager, IAM)
  SHALL be created
- **AND** the run SHALL complete without manual console steps.

#### Scenario: Plan is reviewable on a pull request

- **GIVEN** a change to the IaC under review
- **WHEN** the pull-request workflow runs
- **THEN** it SHALL produce an OpenTofu plan
- **AND** the plan SHALL be visible on the pull request before any apply.

#### Scenario: State is remote and versioned

- **GIVEN** the IaC backend is configured
- **WHEN** an apply writes state
- **THEN** the state SHALL be stored in the GCS backend, not on a contributor's machine
- **AND** the backend bucket SHALL have object versioning enabled.

### Requirement: Keyless GitHub-to-GCP authentication

GitHub Actions SHALL authenticate to GCP via Workload Identity Federation (OIDC). The
system SHALL NOT store long-lived service-account keys in the repository, in CI secrets,
or in IaC state.

#### Scenario: CI authenticates without stored keys

- **GIVEN** a CI workflow that needs GCP access
- **WHEN** the workflow authenticates to GCP
- **THEN** it SHALL exchange a GitHub OIDC token through the Workload Identity provider
- **AND** no service-account JSON key SHALL be required.

#### Scenario: Federation is scoped to this repository

- **GIVEN** the Workload Identity provider configuration
- **WHEN** an OIDC token is presented
- **THEN** the provider SHALL only trust tokens issued for this repository
- **AND** the federated principal SHALL hold least-privilege IAM for the eval job and its secrets.

### Requirement: GitHub configuration as code

The repository's GitHub configuration SHALL be managed by IaC so it is backed up and
drift-detectable. This MUST cover repo settings, branch protection, the signed-commits
ruleset, the `evals` environment with its reviewers and prevent-self-review setting,
labels, and Actions secrets and variables.

#### Scenario: Restore reproduces live configuration

- **GIVEN** the GitHub configuration is managed by IaC
- **WHEN** the configuration is destroyed and re-applied
- **THEN** the resulting live settings SHALL match the IaC definition
- **AND** the `evals` environment, its reviewers, and prevent-self-review SHALL be restored.

#### Scenario: Drift is detectable

- **GIVEN** a setting is changed in the GitHub web UI out-of-band
- **WHEN** an OpenTofu plan is run
- **THEN** the plan SHALL report the drift against the IaC definition.

### Requirement: GPU-backed eval execution

The Skill-CI SLM evals SHALL run on a GPU-backed Cloud Run Job (NVIDIA L4), with the eval
model weights baked into an Artifact Registry image to avoid cold-start model pulls. The
job's outcome SHALL propagate to the pull request, and results SHALL be posted via the
existing sticky eval-results comment.

#### Scenario: Evals run on the GPU job

- **GIVEN** a pull request that triggers Skill CI
- **WHEN** the eval stage runs
- **THEN** it SHALL execute the promptfoo SLM evals on the L4 Cloud Run Job
- **AND** the job SHALL use models baked into its image rather than pulling them at start.

#### Scenario: Outcome propagates to the pull request

- **GIVEN** the eval job has finished
- **WHEN** Skill CI reports status
- **THEN** a failing job SHALL fail the eval stage and a passing job SHALL pass it
- **AND** the results SHALL be posted to the pull request via the sticky eval-results comment.

### Requirement: Secrets sourced from a secret manager

Secrets needed by the eval pipeline SHALL be sourced from GCP Secret Manager at run time.
The system SHALL NOT store secret values in plaintext IaC state or in the repository.

#### Scenario: Job reads secrets at run time

- **GIVEN** the eval job requires a secret
- **WHEN** the job runs
- **THEN** it SHALL read the secret from Secret Manager
- **AND** the secret value SHALL NOT appear in plaintext IaC state or in the repository.
