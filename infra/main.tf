locals {
  apis = [
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "secretmanager.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "sts.googleapis.com",
  ]

  eval_image = var.eval_image != "" ? var.eval_image : "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.eval.repository_id}/eval:latest"
}

resource "google_project_service" "this" {
  for_each = toset(local.apis)

  service            = each.value
  disable_on_destroy = false
}

resource "google_artifact_registry_repository" "eval" {
  location      = var.region
  repository_id = "hegel-eval"
  format        = "DOCKER"
  description   = "Eval-runner images (Ollama + promptfoo + baked SLM weights)."

  depends_on = [google_project_service.this]
}

module "wif" {
  source = "./modules/wif"

  project_id        = var.project_id
  github_owner      = var.github_owner
  github_repository = var.github_repository

  depends_on = [google_project_service.this]
}

module "cloud_run_eval" {
  source = "./modules/cloud-run-eval"

  region                 = var.region
  image                  = local.eval_image
  runner_service_account = module.wif.runner_service_account_email
  grader_model           = var.grader_model
  embed_model            = var.embed_model
  secrets                = var.eval_secrets

  depends_on = [google_project_service.this]
}

module "github_repo" {
  source = "./modules/github-repo"

  repository                 = var.github_repository
  eval_reviewers             = var.eval_reviewers
  workload_identity_provider = module.wif.workload_identity_provider_name
  runner_service_account     = module.wif.runner_service_account_email
  eval_job_name              = module.cloud_run_eval.job_name
  region                     = var.region
  project_id                 = var.project_id
  tfstate_bucket             = var.tfstate_bucket
}
