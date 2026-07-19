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

# Least-privilege: in GCP GitHub Actions reads/writes the OpenTofu remote state and
# runs the eval workload, so the runner gets object read/write on the state bucket
# plus (below) read-only visibility into enabled project services and the two
# eval-runner grants (Artifact Registry push/pull + Cloud Run Job execution). No
# write/create grants on any other project resource, no Secret Manager, and no
# service-account impersonation beyond the WIF principal impersonating this runner SA.
resource "google_storage_bucket_iam_member" "runner_state" {
  bucket = var.tfstate_bucket
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.runner.email}"
}

# `tofu plan` refreshes every managed resource's live state before diffing,
# including the root module's google_project_service resources — that read needs
# project-level serviceusage visibility, which no other grant here provides.
# `serviceUsageViewer` is read-only (list/get enabled services only; it cannot
# enable, disable, or otherwise write anything), so this doesn't reopen the door
# the state-bucket-only design closed — CI still can't create or configure any
# project resource, it can only see which APIs are already enabled (#73).
resource "google_project_iam_member" "runner_service_usage_viewer" {
  project = var.project_id
  role    = "roles/serviceusage.serviceUsageViewer"
  member  = "serviceAccount:${google_service_account.runner.email}"
}

# serviceUsageViewer alone still 403'd on the same read: Terraform's read of
# google_project_service also needs basic project-metadata visibility
# (resourcemanager.projects.get), which that narrower role doesn't include.
# `roles/browser` is the standard, still read-only pairing for exactly this case —
# it grants read access to a project's basic metadata and nothing else (no service
# configuration, no data plane access to any resource).
resource "google_project_iam_member" "runner_browser" {
  project = var.project_id
  role    = "roles/browser"
  member  = "serviceAccount:${google_service_account.runner.email}"
}

# The runner SA also self-references this module's own resources on every plan
# (its own service account, the WIF pool/provider), which needs the matching
# read-only viewer roles — none of the grants above cover reading a service
# account's or workload identity pool's own metadata/IAM policy. Both are
# read-only: neither lets the runner SA create, delete, or reconfigure anything,
# or grant itself (or anyone else) additional impersonation rights.
resource "google_project_iam_member" "runner_service_account_viewer" {
  project = var.project_id
  role    = "roles/iam.serviceAccountViewer"
  member  = "serviceAccount:${google_service_account.runner.email}"
}

resource "google_project_iam_member" "runner_workload_identity_pool_viewer" {
  project = var.project_id
  role    = "roles/iam.workloadIdentityPoolViewer"
  member  = "serviceAccount:${google_service_account.runner.email}"
}

# tofu plan also needs to read the state bucket's own IAM policy (to refresh
# google_storage_bucket_iam_member.runner_state) — storage.buckets.getIamPolicy.
# No bucket-scoped role grants that without also granting setIamPolicy
# (roles/storage.legacyBucketOwner/Writer — a write/escalation-capable
# permission on the bucket's own IAM policy, not something to hand to CI just to
# unblock a read). roles/iam.securityReviewer is the project-level role Google
# built for exactly this: get-IAM-policy visibility across resources, read-only,
# no ability to modify anything.
resource "google_project_iam_member" "runner_security_reviewer" {
  project = var.project_id
  role    = "roles/iam.securityReviewer"
  member  = "serviceAccount:${google_service_account.runner.email}"
}

# Eval-runner grant #1 (#79 Phase 0): push/pull the eval image. Scoped to the single
# eval repository (not project-wide artifactregistry.writer) — `roles/artifactregistry.writer`
# covers both push and pull, so CI can publish the image and the Cloud Run Job can read it.
resource "google_artifact_registry_repository_iam_member" "runner_eval_writer" {
  project    = var.project_id
  location   = var.region
  repository = var.eval_repository_id
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${google_service_account.runner.email}"
}

# Eval-runner grant #2 (#79 Phase 0): execute the eval Cloud Run Job. `roles/run.invoker`
# grants `run.jobs.run` (invoke/execute an existing job) — it does NOT let the runner create,
# deploy, or reconfigure Cloud Run resources, and it is deliberately not paired with
# `roles/iam.serviceAccountUser`, so the runner cannot act-as/impersonate a job runtime SA
# (keeps the no-impersonation guardrail). Granted at project scope because the Job resource
# does not exist yet — its shape is fixed by the Phase 3 discovery run.
resource "google_project_iam_member" "runner_run_invoker" {
  project = var.project_id
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.runner.email}"
}
