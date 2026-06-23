locals {
  # APIs the GitHub-config IaC needs: WIF (IAM/STS/credentials) so GitHub Actions can
  # authenticate keylessly, plus Cloud Storage for the remote-state bucket. There is no
  # GPU/Cloud Run/Artifact Registry footprint — the evals run on GitHub-hosted runners.
  apis = [
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "sts.googleapis.com",
    "storage.googleapis.com",
  ]
}

resource "google_project_service" "this" {
  for_each = toset(local.apis)

  service            = each.value
  disable_on_destroy = false
}

module "wif" {
  source = "./modules/wif"

  project_id        = var.project_id
  github_owner      = var.github_owner
  github_repository = var.github_repository
  tfstate_bucket    = var.tfstate_bucket

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
}
