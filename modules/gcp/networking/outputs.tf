output "network_id" {
  description = "Self link of the VPC network"
  value       = google_compute_network.this.id
}

output "network_name" {
  description = "Name of the created VPC network"
  value       = google_compute_network.this.name
}

output "subnet_name" {
  description = "Primary subnet name"
  value       = google_compute_subnetwork.primary.name
}

output "subnet_self_link" {
  description = "Self link of the primary subnet"
  value       = google_compute_subnetwork.primary.self_link
}

output "pods_secondary_range" {
  description = "Secondary range name for Kubernetes pods"
  value       = google_compute_subnetwork.primary.secondary_ip_range[0].range_name
}

output "services_secondary_range" {
  description = "Secondary range name for Kubernetes services"
  value       = google_compute_subnetwork.primary.secondary_ip_range[1].range_name
}
