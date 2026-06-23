terraform {
  required_version = ">= 1.6"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }

  # Remote state in a versioned GCS bucket. The bucket name is supplied at init
  # time so it is not hard-coded here:
  #   tofu init -backend-config=backend.hcl
  backend "gcs" {
    prefix = "hegel-skill/ci-infrastructure"
  }
}
