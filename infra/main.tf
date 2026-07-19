locals {
  # APIs the IaC needs: WIF (IAM/STS/credentials) so GitHub Actions can authenticate
  # keylessly, Cloud Storage for the remote-state bucket, plus — for the eval runner
  # migration (#79 Phase 0) — Artifact Registry to host the eval image and Cloud Run to
  # execute it as a Job. No GPU is enabled here; the CPU-vs-GPU decision is deferred to
  # the Phase 3 discovery run.
  apis = [
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "sts.googleapis.com",
    "storage.googleapis.com",
    "artifactregistry.googleapis.com",
    "run.googleapis.com",
  ]
}

# Docker repository that holds the eval runtime image (Ollama + promptfoo + baked models).
# CI pushes here over WIF (no SA JSON key); the Cloud Run Job pulls from it. Located in the
# same region as the state bucket for locality. Immutable tags are intentionally NOT set:
# the eval image is re-pushed under a moving tag during the strangler-fig migration.
resource "google_artifact_registry_repository" "evals" {
  location      = var.region
  repository_id = var.eval_repository_id
  format        = "DOCKER"
  description   = "Hegel skill eval runtime images (Ollama + promptfoo, models baked in)."

  depends_on = [google_project_service.this]
}

resource "google_project_service" "this" {
  for_each = toset(local.apis)

  service            = each.value
  disable_on_destroy = false
}

locals {
  # Docker path CI pushes to and the Cloud Run Job pulls from.
  eval_artifact_registry = "${google_artifact_registry_repository.evals.location}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.evals.repository_id}"
}

module "wif" {
  source = "./modules/wif"

  project_id        = var.project_id
  github_owner      = var.github_owner
  github_repository = var.github_repository
  tfstate_bucket    = var.tfstate_bucket

  # Eval-runner grants: push/pull to this AR repo + execute the Cloud Run Job.
  region             = var.region
  eval_repository_id = google_artifact_registry_repository.evals.repository_id

  depends_on = [google_project_service.this]
}

module "github_repo" {
  source = "./modules/github-repo"

  repository                 = var.github_repository
  eval_reviewers             = var.eval_reviewers
  workload_identity_provider = module.wif.workload_identity_provider_name
  runner_service_account     = module.wif.runner_service_account_email
  region                     = var.region
  project_id                 = var.project_id
  tfstate_bucket             = var.tfstate_bucket
  eval_artifact_registry     = local.eval_artifact_registry
}
