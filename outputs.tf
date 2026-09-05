# ==================== GKE Infrastructure Outputs ====================
output "network_name" {
  description = "Name of the VPC Network"
  value       = module.gcp_networking.network_name
}

output "subnet_name" {
  description = "Name of the primary subnetwork"
  value       = module.gcp_networking.subnet_name
}

output "cluster_name" {
  description = "Name of the provisioned GKE cluster"
  value       = module.gcp_compute.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint for connecting to the GKE control plane"
  value       = module.gcp_compute.cluster_endpoint
  sensitive   = true
}

output "gcloud_get_credentials_command" {
  description = "Command to authenticate kubectl with the GKE cluster"
  value       = "gcloud container clusters get-credentials ${module.gcp_compute.cluster_name} --region ${var.gcp_region} --project ${var.gcp_project_id}"
}

output "database_instance_connection_name" {
  description = "Cloud SQL instance connection name for Cloud SQL Auth Proxy"
  value       = module.gcp_database.instance_connection_name
}

output "db_password" {
  description = "Generated database administrator password"
  value       = module.gcp_database.db_password
  sensitive   = true
}

output "notification_channel" {
  description = "Name of the Cloud Monitoring notification channel"
  value       = module.gcp_monitoring.notification_channel
}
