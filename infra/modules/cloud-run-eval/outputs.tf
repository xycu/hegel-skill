output "job_name" {
  description = "Name of the Cloud Run eval job."
  value       = google_cloud_run_v2_job.eval.name
}
