# Resolve reviewer usernames to numeric ids the environment API needs.
data "github_user" "reviewers" {
  for_each = toset(var.eval_reviewers)
  username = each.value
}

# Backs up the "Require signed commits" ruleset.
resource "github_repository_ruleset" "signed_commits" {
  name        = "require-signed-commits"
  repository  = var.repository
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["~ALL"]
      exclude = []
    }
  }

  rules {
    required_signatures = true
  }
}

# The `evals` deployment gate: a run waits here; one approval releases it.
# Self-approve is intentionally allowed (prevent_self_review = false).
resource "github_repository_environment" "evals" {
  repository  = var.repository
  environment = "evals"

  prevent_self_review = false
  can_admins_bypass   = true

  reviewers {
    users = [for u in data.github_user.reviewers : u.id]
  }
}

# Operational label (see AGENTS.md "Way of working").
resource "github_issue_label" "in_progress" {
  repository  = var.repository
  name        = "in progress"
  color       = "0E8A16"
  description = "Actively being worked on"
}

# Non-secret values the Skill-CI workflow needs to auth to GCP and run the job.
resource "github_actions_variable" "wif_provider" {
  repository    = var.repository
  variable_name = "GCP_WORKLOAD_IDENTITY_PROVIDER"
  value         = var.workload_identity_provider
}

resource "github_actions_variable" "service_account" {
  repository    = var.repository
  variable_name = "GCP_SERVICE_ACCOUNT"
  value         = var.runner_service_account
}

resource "github_actions_variable" "eval_job" {
  repository    = var.repository
  variable_name = "EVAL_JOB_NAME"
  value         = var.eval_job_name
}

resource "github_actions_variable" "region" {
  repository    = var.repository
  variable_name = "GCP_REGION"
  value         = var.region
}

resource "github_actions_variable" "project_id" {
  repository    = var.repository
  variable_name = "GCP_PROJECT_ID"
  value         = var.project_id
}

resource "github_actions_variable" "tfstate_bucket" {
  repository    = var.repository
  variable_name = "GCP_TFSTATE_BUCKET"
  value         = var.tfstate_bucket
}
