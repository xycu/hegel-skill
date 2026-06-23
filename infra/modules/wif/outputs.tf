output "runner_service_account_email" {
  description = "Email of the runner service account."
  value       = google_service_account.runner.email
}

output "workload_identity_provider_name" {
  description = "Full WIF provider resource name for the GHA auth action."
  value       = google_iam_workload_identity_pool_provider.github.name
}
