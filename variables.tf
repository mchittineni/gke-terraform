# ==================== Core Project Variables ====================
variable "project_name" {
  description = "Project identifier used in naming and labeling resources"
  type        = string
  default     = "cloud-platform"
}

variable "environment" {
  description = "Target deployment environment (e.g. dev, staging, production)"
  type        = string
  default     = "dev"
}

variable "owner_email" {
  description = "Email of the project owner for resource tagging"
  type        = string
  default     = "platform-team@example.com"
}

# ==================== GCP Provider Variables ====================
variable "gcp_project_id" {
  description = "The Google Cloud Project ID where resources will be provisioned"
  type        = string
  default     = "my-gcp-project-id"
}

variable "gcp_region" {
  description = "Default GCP Region for regional infrastructure"
  type        = string
  default     = "us-central1"
}

# ==================== GCP Networking Variables ====================
variable "gcp_subnet_cidr" {
  description = "CIDR range for the primary VPC subnetwork"
  type        = string
  default     = "10.10.0.0/20"
}

# ==================== GKE Compute Variables ====================
variable "gke_release_channel" {
  description = "GKE Release Channel (RAPID, REGULAR, STABLE)"
  type        = string
  default     = "REGULAR"
}

variable "gcp_machine_type" {
  description = "Compute Engine machine type for worker nodes"
  type        = string
  default     = "e2-standard-4"
}

variable "gcp_node_count" {
  description = "Initial number of worker nodes per zone"
  type        = number
  default     = 2
}

# ==================== Cloud SQL Database Variables ====================
variable "gcp_db_name" {
  description = "Name of the initial Cloud SQL database"
  type        = string
  default     = "appdb"
}

variable "gcp_db_version" {
  description = "Database engine and version (e.g. POSTGRES_16)"
  type        = string
  default     = "POSTGRES_16"
}

variable "gcp_db_tier" {
  description = "Machine tier for the Cloud SQL instance"
  type        = string
  default     = "db-custom-2-7680"
}

variable "gcp_db_availability_type" {
  description = "Availability type for Cloud SQL (ZONAL or REGIONAL)"
  type        = string
  default     = "ZONAL"
}

# ==================== Monitoring & Observability ====================
variable "enable_monitoring" {
  description = "Enable Cloud Logging custom buckets and Cloud Monitoring alert policies"
  type        = bool
  default     = true
}

variable "alert_email" {
  description = "Email address for Cloud Monitoring notification channels"
  type        = string
  default     = "alerts@example.com"
}
