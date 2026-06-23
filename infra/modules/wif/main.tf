resource "google_service_account" "runner" {
  account_id   = "hegel-eval-ci"
  display_name = "Hegel skill — CI eval runner (GHA via WIF)"
}

resource "google_iam_workload_identity_pool" "github" {
  workload_identity_pool_id = "github-actions"
  display_name              = "GitHub Actions"
  description               = "OIDC federation for GitHub Actions."
}

resource "google_iam_workload_identity_pool_provider" "github" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-oidc"
  display_name                       = "GitHub OIDC"

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
    "attribute.ref"        = "assertion.ref"
  }

  # Only trust tokens issued for this exact repository.
  attribute_condition = "assertion.repository == \"${var.github_owner}/${var.github_repository}\""

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

# Let this repo's GHA workflows impersonate the runner service account.
resource "google_service_account_iam_member" "wif_impersonation" {
  service_account_id = google_service_account.runner.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/${var.github_owner}/${var.github_repository}"
}

# Least-privilege project roles for the runner.
locals {
  runner_roles = [
    "roles/run.developer",                # execute the Cloud Run Job
    "roles/artifactregistry.reader",      # pull the eval image
    "roles/secretmanager.secretAccessor", # read run-time secrets
    "roles/iam.serviceAccountUser",       # act as the job's service account
  ]
}

resource "google_project_iam_member" "runner" {
  for_each = toset(local.runner_roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.runner.email}"
}
