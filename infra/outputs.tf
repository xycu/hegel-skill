output "workload_identity_provider" {
  description = "WIF provider resource name — set as the GHA `workload_identity_provider` input."
  value       = module.wif.workload_identity_provider_name
}

output "runner_service_account" {
  description = "Service account GitHub Actions impersonates (via WIF) to read/write IaC state."
  value       = module.wif.runner_service_account_email
}
