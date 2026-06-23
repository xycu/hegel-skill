resource "google_service_account" "runner" {
  account_id   = "hegel-eval-ci"
  display_name = "Hegel skill — IaC state access for GitHub Actions (via WIF)"
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

# Least-privilege: the only thing GitHub Actions does in GCP is read/write the
# OpenTofu remote state, so the runner gets object read/write on the state bucket
# and nothing else. No project-level roles, no Cloud Run / Artifact Registry /
# Secret Manager — those were dropped with the GPU eval runner.
resource "google_storage_bucket_iam_member" "runner_state" {
  bucket = var.tfstate_bucket
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.runner.email}"
}
