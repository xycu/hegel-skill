# Infrastructure as code

OpenTofu defines the CI/eval environment (GCP) and this repo's GitHub configuration.
Terraform-compatible — `tofu` and `terraform` both work; OpenTofu is the supported tool.

## Layout

```
infra/
  versions.tf            providers + GCS backend
  providers.tf           google + github providers
  variables.tf           inputs
  main.tf                APIs, Artifact Registry, module wiring
  outputs.tf             WIF provider, SA, job name, image
  modules/
    wif/                 Workload Identity Federation (keyless GHA -> GCP)
    cloud-run-eval/      L4 Cloud Run Job eval runner
    github-repo/         rulesets, evals environment, labels, CI variables
  docker/                eval-runner image (Ollama + promptfoo + baked models)
```

## One-time bootstrap (manual, before first apply)

These exist before OpenTofu runs, so create them by hand once:

1. A GCP project and billing.
2. **NVIDIA L4 quota** in your region (request early — it has lead time).
3. A **versioned GCS bucket** for state: `gsutil mb` + `gsutil versioning set on`.
4. Copy `backend.hcl.example` -> `backend.hcl` and `terraform.tfvars.example` ->
   `terraform.tfvars`; fill both in.
5. A **fine-grained PAT** (repo admin) for the github provider, exported as
   `GITHUB_TOKEN` locally / `GH_ADMIN_TOKEN` secret in CI.

> Confirm Cloud Run **GPU-on-Jobs (L4)** is GA in your chosen region before applying.

## Usage

```sh
cd infra
tofu init -backend-config=backend.hcl
tofu plan
tofu apply
```

Build & push the eval image (from the repo root):

```sh
docker build -f infra/docker/Dockerfile \
  -t "$REGION-docker.pkg.dev/$PROJECT/hegel-eval/eval:latest" .
docker push "$REGION-docker.pkg.dev/$PROJECT/hegel-eval/eval:latest"
```

## Importing existing GitHub config

The `github-repo` module manages resources that already exist in the live repo.
Import them before the first apply so OpenTofu adopts (not recreates) them, e.g.:

```sh
tofu import 'module.github_repo.github_repository_environment.evals' hegel-skill:evals
tofu import 'module.github_repo.github_issue_label.in_progress'      hegel-skill:in progress
# rulesets import by numeric id: <repo>:<ruleset_id>
```

## What's verified

HCL is `fmt`/`validate`-clean. `apply`, the Docker build, and GPU execution are **not**
exercised here — they need a real GCP project, the L4 quota grant, and a GPU runtime.
Tracked in `openspec/changes/2026-06-23-ci-infrastructure-as-code/tasks.md` and issue #79.
