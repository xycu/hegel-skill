## Why

The CI/eval environment is hand-built and undocumented, and the GitHub configuration that
governs this repo (the signed-commits ruleset, the `evals` deployment gate, required
reviewers, prevent-self-review) lives only in the web UI — unbacked-up and easy to break
by a misclick. Separately, the SLM evals are CPU-bound: a single Ollama on `ubuntu-latest`
blew the 90-minute envelope, forcing 5 behaviours to be parked (#76).

The original plan answered the runtime problem with GPU hardware — an NVIDIA **L4** Cloud
Run Job. That hardware is **not available** (no L4 quota access), so the GPU approach is
abandoned. The runtime fix is now **scheduling, not hardware**: the slow full suite runs on
a **nightly schedule** where wall-clock time is free, and every PR runs a **fast subset**.

**User story —**
**As** the maintainer,
**I want** the GitHub configuration that governs this repo defined as version-controlled
code, a fast eval on every pull request, and the full eval suite (all behaviours, both
languages, with semantic grading) run nightly,
**so that** my GitHub config is backed up and restorable, PRs get quick behavioural signal
without blowing the runner budget, and the parked behaviours return to coverage without
needing a GPU.

Tracking issue #79. This supersedes the GPU/L4 "hardware" half of **#76** with a
scheduling split. Refs #76.

## What Changes

- **Drop the GPU/GCP eval runner entirely.** No Cloud Run Job, no NVIDIA L4, no Artifact
  Registry eval image, no Secret Manager for eval secrets. Evals keep running on
  `ubuntu-latest` via Ollama, as today.
- **Split the eval workload by trigger:**
  - **Per pull request (fast):** deterministic skill lint + the **3 core behaviours**
    (`dialectical`, `grief`, `technical-dismissal`) EN+PL, with the slow model-graded
    asserts (`llm-rubric`, `similar`) **disabled** — pass/fail on the deterministic +
    behavioural keyword asserts only, so a PR run finishes in minutes.
  - **Nightly (scheduled cron):** the **full suite** — all 8 behaviours EN+PL **including
    the 5 restored parked cases** — with the semantic `llm-rubric` / `similar` grading
    enabled. Runs on `ubuntu-latest` with a long timeout; nightly wall-clock is free, so
    the 90-minute pressure that parked them no longer applies.
- **Restore the 5 parked behaviours** (`promptfoo/tests/_disabled/`) into the nightly suite:
  `motion-not-announced`, `ordinary-engine`, `persona-explicit`, `persona-persistence`,
  `voice-register`. They were parked for **runtime only**, not because the model fails them.
- **Keep the manual approval gate** (the `evals` environment) on the PR eval run.
- **Keep GitHub configuration as code** with OpenTofu + the `integrations/github` provider:
  repo settings, branch protection, the signed-commits ruleset, the `evals` environment +
  reviewers + prevent-self-review, labels, and Actions variables — so the config is backed
  up and drift-detectable. State stays in a **versioned GCS bucket** (object storage only —
  no GPU, no L4), and the plan-on-PR workflow authenticates via **WIF (OIDC)**, scoped down
  to **state access only** now that there is no Cloud Run / Secret Manager to reach.

## Capabilities

### Added Capabilities
- `ci-infrastructure`: the repo's GitHub configuration is defined as version-controlled IaC
  (keyless WIF auth, versioned remote state), and the SLM evals run on a two-tier schedule —
  a fast gated subset on every pull request and the full graded suite nightly.

## Impact

- **New files:** an IaC root + small modules (`wif/`, `github-repo/`), a GCS state backend
  config, a plan-on-PR GHA workflow, IaC-lint config, and a **nightly eval workflow**
  (`.github/workflows/skill-ci-nightly.yml`).
- **Modified files:** `.github/workflows/skill-ci.yml` (PR run drops to the fast subset with
  judge asserts off); `promptfoo/` (a way to toggle the judge asserts and to select the
  full vs core test set per trigger); the 5 parked behaviours move from
  `promptfoo/tests/_disabled/` back under `promptfoo/tests/`; contributor docs
  (`AGENTS.md` / `CONTRIBUTING.md`) document the two-tier eval split and the IaC.
- **Removed (vs the earlier GPU proposal):** the `cloud-run-eval/` module, the eval-runner
  `Dockerfile` / `infra/docker`, Secret Manager wiring, and the L4 / Artifact Registry IAM
  grants on the WIF principal.
- **External prerequisites:** a GCP project for the **GCS state bucket** only (no L4 quota,
  no GPU). The maintainer runs `tofu apply` for the GitHub-config module.
- **Security:** no long-lived SA keys (WIF only); the WIF principal is least-privilege —
  state-bucket read/write only. Secrets stay out of plaintext state.
