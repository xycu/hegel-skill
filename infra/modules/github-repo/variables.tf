variable "repository" {
  description = "Repository name (without owner)."
  type        = string
}

variable "eval_reviewers" {
  description = "GitHub usernames that may approve the `evals` deployment gate."
  type        = list(string)
  default     = []
}

variable "workload_identity_provider" {
  description = "WIF provider resource name (exposed to CI as a repo variable)."
  type        = string
}

variable "runner_service_account" {
  description = "Runner SA email (exposed to CI as a repo variable)."
  type        = string
}

variable "eval_job_name" {
  description = "Cloud Run eval job name (exposed to CI as a repo variable)."
  type        = string
}

variable "region" {
  description = "GCP region (exposed to CI as a repo variable)."
  type        = string
}
