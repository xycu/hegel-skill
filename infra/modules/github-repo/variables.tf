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

variable "region" {
  description = "GCP region (exposed to CI as a repo variable)."
  type        = string
}

variable "project_id" {
  description = "GCP project id (exposed to CI as a repo variable)."
  type        = string
}

variable "tfstate_bucket" {
  description = "GCS state bucket name (exposed to CI as a repo variable)."
  type        = string
}
