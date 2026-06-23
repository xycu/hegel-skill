variable "project_id" {
  description = "GCP project that hosts the CI/eval infrastructure."
  type        = string
}

variable "region" {
  description = "GCP region for Artifact Registry and the Cloud Run eval job. Must offer Cloud Run GPU (L4) on Jobs."
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

variable "eval_image" {
  description = "Fully-qualified eval-runner image. Empty = derive from the Artifact Registry repo (:latest)."
  type        = string
  default     = ""
}

variable "eval_reviewers" {
  description = "GitHub usernames that may approve the `evals` deployment gate."
  type        = list(string)
  default     = []
}

variable "grader_model" {
  description = "Ollama model used as the llm-rubric judge inside the eval job."
  type        = string
  default     = "gemma2:9b-instruct-q4_0"
}

variable "embed_model" {
  description = "Ollama embedding model used by the `similar` asserts."
  type        = string
  default     = "nomic-embed-text"
}

variable "eval_secrets" {
  description = "Map of ENV var name => Secret Manager secret id, injected into the eval job at run time."
  type        = map(string)
  default     = {}
}
