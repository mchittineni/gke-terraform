output "log_bucket_name" {
  description = "Custom logging bucket name"
  value       = try(google_logging_project_bucket_config.cluster[0].bucket_id, null)
}

output "logging_metric_name" {
  description = "Name of the log-based metric"
  value       = google_logging_metric.gke_errors.name
}

output "alert_policy_id" {
  description = "Monitoring alert policy ID"
  value       = google_monitoring_alert_policy.gke_errors.name
}

output "notification_channel" {
  description = "Email notification channel resource name"
  value       = google_monitoring_notification_channel.email.name
}
