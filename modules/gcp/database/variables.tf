variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "Region where the Cloud SQL instance will run"
  type        = string
}

variable "network_id" {
  description = "Self link of the VPC network for private services access"
  type        = string
}

variable "instance_name" {
  description = "Name of the Cloud SQL instance"
  type        = string
}

variable "database_name" {
  description = "Initial database name"
  type        = string
}

variable "database_version" {
  description = "Cloud SQL database version"
  type        = string
}

variable "tier" {
  description = "Machine tier for Cloud SQL"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "availability_type" {
  description = "ZONAL or REGIONAL availability"
  type        = string
  default     = "ZONAL"
}

variable "labels" {
  description = "Labels applied to Cloud SQL resources"
  type        = map(string)
  default     = {}
}
