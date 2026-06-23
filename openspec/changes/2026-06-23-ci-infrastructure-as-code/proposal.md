## Why

The CI/eval environment is hand-built and undocumented, and the GitHub configuration that
governs this repo (the signed-commits ruleset, the `evals` deployment gate, required
reviewers, prevent-self-review) lives only in the web UI — unbacked-up and easy to break
by a misclick. Separately, the SLM evals are CPU-bound: a single Ollama on `ubuntu-latest`
blew the 90-minute envelope, forcing 5 behaviours to be parked (#76).

**User story —**
**As** the maintainer,
**I want** all CI / GCP / GitHub infrastructure defined as version-controlled code, and the
Skill-CI eval workload running on a GPU-backed Cloud Run Job,
**so that** the environment is reproducible from scratch, my GitHub configuration is backed
up and restorable, GitHub Actions authenticates to GCP without long-lived keys, and the
parked eval behaviours can return within the time budget.

Tracking issue #79. This is the "larger runner / hardware" option from **#76**, plus the
IaC and GitHub-config-backup scope. Refs #76.

## What Changes

- Introduce **OpenTofu** as the IaC tool (Terraform-compatible, license-clean). **No
  Terragrunt** — a single project/env makes it pure overhead.
- Store remote state in a **versioned GCS bucket**; never local state. Secrets sourced from
  **Secret Manager**, never committed to plaintext state.
- Provision the GCP side with the `google` provider: an **Artifact Registry** image (Ollama
  + models + promptfoo, models baked in to kill cold-start), a **Cloud Run Job on an NVIDIA
  L4 (24 GB)** as the eval runner, **Secret Manager**, and **IAM**.
- Authenticate GitHub Actions to GCP with **Workload Identity Federation (OIDC)** — no
  long-lived service-account keys.
- Manage **GitHub configuration as code** with the `integrations/github` provider: repo
  settings, branch protection, rulesets (signed commits), the `evals` environment +
  reviewers + prevent-self-review, labels, and Actions secrets/variables — so the config
  is backed up and drift-detectable.
- Wire Skill CI to the runner: GHA runs `gcloud run jobs execute --wait`; the job's exit
  code propagates pass/fail; artifacts land in GCS; the existing sticky eval-results comment
  (#27/#28) posts the table.
- Lint IaC with **tflint + trivy/checkov**; a **plan-on-PR** GHA workflow (WIF) — **no
  Atlantis** (solo overkill).
- Once the GPU runner lands, **restore the 5 parked behaviours** (`promptfoo/tests/_disabled/`)
  EN+PL within a documented time budget.

## Capabilities

### Added Capabilities
- `ci-infrastructure`: the CI/eval environment and the repo's GitHub configuration are
  defined as version-controlled IaC, GHA authenticates to GCP keylessly via WIF, and the
  SLM evals run on a GPU-backed Cloud Run Job.

## Impact

- **New files:** an IaC root + small modules (`wif/`, `cloud-run-eval/`, `github-repo/`),
  a GCS state backend config, an eval container `Dockerfile`, a plan-on-PR GHA workflow,
  and IaC-lint config.
- **Modified files:** `.github/workflows/skill-ci.yml` (eval jobs invoke the Cloud Run
  Job instead of running Ollama on the GH runner); contributor docs (`AGENTS.md` /
  `CONTRIBUTING.md`) gain an IaC section.
- **External prerequisites:** a GCP project, an NVIDIA **L4 quota** grant (per-region, has
  lead time), and confirmation that Cloud Run **GPU on Jobs** is GA in the chosen region.
- **Depends on / closes the hardware half of:** #76. Unblocks restoring the parked
  behaviours (and, downstream, #50).
- **Security:** removes any long-lived SA keys in favour of WIF; keeps secrets out of
  plaintext state.
