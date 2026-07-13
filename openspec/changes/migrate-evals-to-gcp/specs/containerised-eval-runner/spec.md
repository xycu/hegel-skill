## ADDED Requirements

### Requirement: Reproducible eval container image

The system SHALL provide a container image that packages the complete eval runtime: the
Ollama server, the model(s) under test **baked into the image** (so no model is pulled at
run time), promptfoo pinned to the single-source-of-truth `PROMPTFOO_VERSION`, the
`run-tests.sh` entrypoint, and the `promptfoo/` configs. The image SHALL build from a clean
checkout with no network model pull at run time.

#### Scenario: Image builds from a clean checkout

- **WHEN** the image is built from a fresh clone at a given commit
- **THEN** the build SHALL succeed and produce an image containing the pinned promptfoo
  version and the model artifacts
- **AND** running the image SHALL NOT trigger a model download.

#### Scenario: Pinned promptfoo version matches the runner

- **GIVEN** `PROMPTFOO_VERSION` is the single source of truth
- **WHEN** the image is built
- **THEN** the promptfoo installed in the image SHALL equal `PROMPTFOO_VERSION`.

### Requirement: Local containerised test run

The system SHALL provide a single command (script or make target), runnable from the
repository root, that runs the promptfoo eval suite **inside** the container image and
mirrors CI pass/fail semantics: exit code `0` on success, non-zero on any failure.

#### Scenario: Suite passes inside the container

- **GIVEN** a developer has built the image locally
- **WHEN** they run the containerised test command and every case passes
- **THEN** the command SHALL exit with status code `0`.

#### Scenario: A failing case propagates a non-zero exit

- **GIVEN** the containerised suite is running locally
- **WHEN** any eval case fails
- **THEN** the command SHALL exit with a non-zero status code.

### Requirement: GCP Cloud Run Job execution path

The eval container SHALL be executable as a GCP Cloud Run Job. CI workflows SHALL trigger a
run via `gcloud run jobs execute --wait`, and the job's exit code SHALL propagate to the
triggering workflow as pass/fail. The eval result SHALL continue to be posted through the
existing sticky eval-results comment.

#### Scenario: Job exit code drives the CI result

- **GIVEN** the eval image is published to Artifact Registry and configured as a Cloud Run
  Job
- **WHEN** a CI workflow executes the job and waits for completion
- **THEN** a job exit code of `0` SHALL mark the CI step passed
- **AND** a non-zero exit code SHALL mark it failed.

#### Scenario: Discovery run documents the real hardware need

- **GIVEN** a single behaviour is run manually on the Cloud Run Job
- **WHEN** the run completes
- **THEN** the observed runtime, CPU-vs-GPU sufficiency, region availability, and cost
  SHALL be recorded so the GPU decision is evidence-based, not assumed.

### Requirement: Incremental, revertible migration

Eval steps SHALL be migrated from the `ubuntu-latest` runner to the GCP container runner one
workflow step at a time, and each step's existing `ubuntu-latest` path SHALL remain live
until that step's GCP path is green. Each migrated step SHALL be revertible to the prior
runner without affecting any other step.

#### Scenario: A migrated step can be reverted independently

- **GIVEN** one eval step has been migrated to the GCP container runner
- **WHEN** that step is reverted to `ubuntu-latest`
- **THEN** the revert SHALL restore a working step
- **AND** it SHALL NOT require changing any step that has not yet been migrated.

#### Scenario: Fallback is retired only after sustained green

- **GIVEN** a step's GCP path is passing
- **WHEN** the maintainer decides to retire the `ubuntu-latest` fallback for that step
- **THEN** retirement SHALL occur only after the GCP path has produced consecutive green
  runs.
