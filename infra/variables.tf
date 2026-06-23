variable "project_id" {
  description = "GCP project that hosts the CI/eval infrastructure."
  type        = string
}

variable "region" {
  description = "GCP region (used for the state bucket's locality and published to CI as a repo variable)."
  type        = string
  default     = "europe-west4"
}

variable "github_owner" {
  description = "GitHub owner/org of the repository."
  type        = string
}

variable "tfstate_bucket" {
  description = "GCS bucket holding remote state (published to CI as a repo variable)."
  type        = string
}

variable "github_repository" {
  description = "GitHub repository name (without owner)."
  type        = string
}

variable "eval_reviewers" {
  description = "GitHub usernames that may approve the `evals` deployment gate."
  type        = list(string)
  default     = []
}
