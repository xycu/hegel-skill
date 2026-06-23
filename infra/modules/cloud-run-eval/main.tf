resource "google_cloud_run_v2_job" "eval" {
  name     = "hegel-eval"
  location = var.region

  # GPU on Cloud Run requires the BETA launch stage on current provider versions.
  launch_stage = "BETA"

  template {
    template {
      service_account = var.runner_service_account
      timeout         = "3600s"
      max_retries     = 0

      # One L4 per task; no zonal redundancy keeps GPU cost to actual run time.
      node_selector {
        accelerator = "nvidia-l4"
      }
      gpu_zonal_redundancy_disabled = true

      containers {
        image = var.image

        resources {
          limits = {
            "cpu"            = "8"
            "memory"         = "32Gi"
            "nvidia.com/gpu" = "1"
          }
        }

        env {
          name  = "GRADER_MODEL"
          value = var.grader_model
        }
        env {
          name  = "EMBED_MODEL"
          value = var.embed_model
        }

        dynamic "env" {
          for_each = var.secrets
          content {
            name = env.key
            value_source {
              secret_key_ref {
                secret  = env.value
                version = "latest"
              }
            }
          }
        }
      }
    }
  }
}
