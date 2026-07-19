# Infrastructure as code

OpenTofu defines this repo's **GitHub configuration** and the keyless auth GitHub Actions
uses to reach GCP. Terraform-compatible — `tofu` and `terraform` both work; OpenTofu is the
supported tool.

The GCP footprint is a Workload Identity pool for keyless auth, the IAM that lets GitHub
Actions read/write the OpenTofu remote state, and — for the eval-runner migration (#79) — an
**Artifact Registry** Docker repository for the eval image plus **Cloud Run Job execution**
grants. **No GPU** is enabled: the CPU-vs-GPU decision is deferred to the Phase 3 discovery
run. The SLM evals currently still run on GitHub-hosted runners (a fast subset per PR, the
full suite nightly — see `.github/workflows/`); they migrate onto the Cloud Run Job one step
at a time.

## Layout

```
infra/
  versions.tf            providers + GCS backend
  providers.tf           google + github providers
  variables.tf           inputs
  main.tf                APIs + module wiring
  outputs.tf             WIF provider, runner SA
  modules/
    wif/                 Workload Identity Federation (keyless GHA -> GCP: state access + eval-runner grants)
    github-repo/         rulesets, evals environment, labels, CI variables
```

## One-time bootstrap (manual, before first apply)

These exist before OpenTofu runs, so create them by hand once:

1. A GCP project and billing.
2. A **versioned GCS bucket** for state: `gsutil mb` + `gsutil versioning set on`.
3. Copy `backend.hcl.example` -> `backend.hcl` and `terraform.tfvars.example` ->
   `terraform.tfvars`; fill both in.
4. A **fine-grained PAT** (repo admin) for the github provider, exported as
   `GITHUB_TOKEN` locally / `GH_ADMIN_TOKEN` secret in CI.

No GPU, no L4 quota, no region capability check at this stage — the APIs OpenTofu enables
are Cloud Storage (state), IAM/STS (federation), and Artifact Registry + Cloud Run (eval
runner). The versioned state bucket is the only pre-created dependency.

## Usage

```sh
cd infra
tofu init -backend-config=backend.hcl
tofu plan
tofu apply
```

The apply publishes every value CI needs as **repo variables** (`GCP_PROJECT_ID`,
`GCP_REGION`, `GCP_TFSTATE_BUCKET`, `GCP_WORKLOAD_IDENTITY_PROVIDER`,
`GCP_SERVICE_ACCOUNT`, `GCP_ARTIFACT_REGISTRY`) — so don't set those by hand, or the apply
will clash with an existing variable. The first apply is therefore **local**; plan-on-PR
works afterwards.

## Importing existing GitHub config

The `github-repo` module manages resources that already exist in the live repo.
Import them before the first apply so OpenTofu adopts (not recreates) them, e.g.:

```sh
tofu import 'module.github_repo.github_repository_environment.evals' hegel-skill:evals
tofu import 'module.github_repo.github_issue_label.in_progress'      hegel-skill:in progress
# rulesets import by numeric id: <repo>:<ruleset_id>
```

## What's verified

HCL is `fmt`/`validate`-clean. `apply` is **not** exercised here — it needs a real GCP
project, a state bucket, and the repo-admin PAT. Tracked in
`openspec/changes/2026-06-23-ci-infrastructure-as-code/tasks.md` and issue #79.
