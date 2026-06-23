output "workload_identity_provider" {
  description = "WIF provider resource name — set as the GHA `workload_identity_provider` input."
  value       = module.wif.workload_identity_provider_name
}

output "runner_service_account" {
  description = "Service account GHA impersonates to run the eval job."
  value       = module.wif.runner_service_account_email
}

output "eval_image" {
  description = "Image the Cloud Run eval job runs."
  value       = local.eval_image
}

output "eval_job_name" {
  description = "Cloud Run Job name to execute from CI."
  value       = module.cloud_run_eval.job_name
}

output "artifact_registry_repo" {
  description = "Artifact Registry repository for eval images."
  value       = google_artifact_registry_repository.eval.id
}
