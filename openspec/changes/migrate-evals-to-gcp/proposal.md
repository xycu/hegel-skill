## Why

The promptfoo SLM eval suite runs Ollama on GitHub's `ubuntu-latest` (CPU) runners; the full graded suite once blew the 90-minute PR envelope (#76), which is why it was split into a fast per-PR subset plus a nightly full run (#80). A GCP-hosted container runner is the path to reproducible, right-sized eval compute — but the earlier attempt (#79) was a big-bang GPU/IaC epic that stalled `blocked` on NVIDIA L4 quota assumed up front. This change migrates the workload incrementally (strangler-fig) so the *real* infrastructure blocker is discovered on the smallest possible workload instead of pre-declared.

## What Changes

- Package the eval runtime (Ollama + models baked in, promptfoo pinned to `PROMPTFOO_VERSION`, `run-tests.sh`, `promptfoo/` configs) into a reproducible container image.
- Add local tooling to run the suite **inside** the container, matching CI exit-code semantics.
- Prove a single behaviour on a GCP Cloud Run Job manually (the discovery step that surfaces the real CPU-vs-GPU / quota / region blocker).
- Migrate the eval steps onto the GCP container runner one workflow at a time — shortest CI step → full PR gate → nightly full graded suite — via keyless Workload Identity Federation.
- Keep the `ubuntu-latest` path live for each step until its GCP path is green; every phase is independently shippable and revertible.
- Codify the GCP side (Artifact Registry, Cloud Run Job, WIF, IAM) in OpenTofu once Phase 3 fixes the shape.
- Out of scope unless the discovery run proves it necessary: NVIDIA L4 GPU, Secret Manager model-serving.

## Capabilities

### New Capabilities
- `containerised-eval-runner`: the reproducible eval container image, the local containerised runner tooling, and the GCP Cloud Run Job execution path that CI workflows delegate to.

### Modified Capabilities
- `ci-infrastructure`: WIF is extended from state-bucket-only access to also authorise Artifact Registry push and Cloud Run Job execution; the GCP-side compute (Artifact Registry repo, Cloud Run Job, IAM) becomes IaC-managed; the required `core-slm-smoke` status checks are produced by the GCP runner rather than `ubuntu-latest`.

## Impact

- **CI:** `.github/workflows/skill-ci.yml` (PR gate) and `.github/workflows/skill-ci-nightly.yml` (nightly) gain a GCP execution path; the sticky eval-results comment (#27/#28) continues to post.
- **New assets:** a `Dockerfile` for the eval runtime, a local container-run script/target, OpenTofu config under `infra/` (or existing IaC location) for the GCP compute.
- **GCP:** project, Artifact Registry repo, versioned GCS state bucket, Cloud Run Job, WIF provider/SA.
- **Dependencies:** Ollama + model artifacts baked into the image; `gcloud` in CI via WIF (no long-lived SA keys).
- **Refs:** #79 (this issue), #76 (runtime budget), #80 (scheduling split), #27/#28 (sticky comment).
