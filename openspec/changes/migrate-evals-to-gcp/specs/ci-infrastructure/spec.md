## MODIFIED Requirements

### Requirement: Keyless GitHub-to-GCP authentication

The plan workflow SHALL authenticate to GCP via Workload Identity Federation (OIDC). The
system SHALL NOT store long-lived service-account keys in the repository, in CI secrets,
or in IaC state. The federated principal SHALL hold least-privilege IAM — read/write to
the state bucket, plus read-only visibility into enabled project services
(`roles/serviceusage.serviceUsageViewer`), basic project metadata (`roles/browser`), its
own identity infrastructure's metadata (`roles/iam.serviceAccountViewer`,
`roles/iam.workloadIdentityPoolViewer`), and read-only IAM-policy visibility across the
project's resources (`roles/iam.securityReviewer`, needed to refresh the state bucket's
own IAM policy without granting bucket-level `setIamPolicy`) so a plan can refresh those
resources — plus the grants needed to run the eval workload: push/pull to the eval
Artifact Registry repository and execution of the eval Cloud Run Job (`roles/run.invoker`
and job-execution). The principal SHALL NOT have write or enable/disable permission over
project services, SHALL NOT be able to impersonate or reconfigure any service account or
identity pool beyond itself, SHALL NOT set or modify any IAM policy, SHALL NOT read or
manage any other project resource's data plane, and SHALL NOT hold any Secret Manager
grant.

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

#### Scenario: Plan can read project service state without broader grants

- **GIVEN** the root module declares `google_project_service` resources
- **WHEN** `tofu plan` refreshes their live state
- **THEN** the federated principal's `serviceUsageViewer` role SHALL be sufficient to read
  them
- **AND** the principal SHALL NOT be able to enable, disable, or otherwise modify any
  project service.

#### Scenario: CI can execute the eval job but not reach secrets

- **GIVEN** the federated principal is configured for the eval workload
- **WHEN** a CI workflow pushes the eval image and executes the eval Cloud Run Job
- **THEN** the push to Artifact Registry and the job execution SHALL succeed
- **AND** the principal SHALL still hold no Secret Manager grant.

### Requirement: Nightly full eval suite

A scheduled nightly workflow SHALL run the full eval suite: all behaviours — the three core
plus the five restored cases (`motion-not-announced`, `ordinary-engine`, `persona-explicit`,
`persona-persistence`, `voice-register`) — in English and Polish, with the `llm-rubric` and
`similar` semantic asserts enabled. It SHALL run on the containerised eval runner — the GCP
Cloud Run Job — once that path is green, with the `ubuntu-latest` path retained as a
fallback until then; either way with a timeout long enough for the full graded suite. It
SHALL surface its pass/fail outcome where the maintainer can see it (a job summary and/or a
tracking issue).

#### Scenario: Nightly runs the full graded suite

- **GIVEN** the nightly schedule fires
- **WHEN** the nightly workflow runs
- **THEN** it SHALL run all eight behaviours EN+PL with the `llm-rubric` and `similar`
  asserts enabled
- **AND** it SHALL run without the per-PR manual-approval gate (no PR to approve).

#### Scenario: Nightly runs on the GCP container runner once proven

- **GIVEN** the eval Cloud Run Job path has produced consecutive green runs
- **WHEN** the nightly workflow runs
- **THEN** it SHALL execute the full graded suite on the Cloud Run Job
- **AND** the `ubuntu-latest` fallback SHALL be retired for the nightly step.

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
