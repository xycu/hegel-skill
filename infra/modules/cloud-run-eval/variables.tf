variable "region" {
  description = "GCP region (must offer Cloud Run GPU-on-Jobs / L4)."
  type        = string
}

variable "image" {
  description = "Eval-runner image to run."
  type        = string
}

variable "runner_service_account" {
  description = "Service account the job runs as."
  type        = string
}

variable "grader_model" {
  description = "Ollama judge model."
  type        = string
}

variable "embed_model" {
  description = "Ollama embedding model."
  type        = string
}

variable "secrets" {
  description = "Map of ENV var name => Secret Manager secret id."
  type        = map(string)
  default     = {}
}
