variable "project_id" {
  description = "GCP project id."
  type        = string
}

variable "github_owner" {
  description = "GitHub owner/org."
  type        = string
}

variable "github_repository" {
  description = "GitHub repository name (without owner)."
  type        = string
}

variable "tfstate_bucket" {
  description = "GCS bucket holding the OpenTofu remote state; the runner SA gets object read/write on it."
  type        = string
}
