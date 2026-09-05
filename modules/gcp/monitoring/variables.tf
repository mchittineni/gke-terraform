variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "cluster_name" {
  description = "GKE cluster name for context"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "enable_cloud_logging" {
  description = "Enable creation of logging resources"
  type        = bool
  default     = true
}

variable "alert_email" {
  description = "Email for alert notifications"
  type        = string
}

variable "labels" {
  description = "Extra labels applied to monitoring resources"
  type        = map(string)
  default     = {}
}
