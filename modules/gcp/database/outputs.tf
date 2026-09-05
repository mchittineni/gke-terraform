output "instance_connection_name" {
  description = "Connection string for the Cloud SQL instance"
  value       = google_sql_database_instance.this.connection_name
}

output "db_self_link" {
  description = "Self link of the Cloud SQL database"
  value       = google_sql_database.default.self_link
}

output "db_password" {
  description = "Generated password for the application user"
  value       = random_password.db.result
  sensitive   = true
}

output "bucket_name" {
  description = "GCS bucket receiving exports and backups"
  value       = google_storage_bucket.backups.name
}

output "service_account_email" {
  description = "Service account used by the Cloud SQL instance"
  value       = google_sql_database_instance.this.service_account_email_address
}
