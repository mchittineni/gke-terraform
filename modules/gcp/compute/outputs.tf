output "cluster_name" {
  description = "GKE cluster name"
  value       = google_container_cluster.this.name
}

output "cluster_id" {
  description = "Self link of the cluster"
  value       = google_container_cluster.this.id
}

output "cluster_endpoint" {
  description = "API endpoint for the GKE control plane"
  value       = google_container_cluster.this.endpoint
  sensitive   = true
}

output "node_pool_name" {
  description = "Primary node pool name"
  value       = google_container_node_pool.primary.name
}

output "node_service_account" {
  description = "Service account used by worker nodes"
  value       = google_service_account.nodes.email
}
