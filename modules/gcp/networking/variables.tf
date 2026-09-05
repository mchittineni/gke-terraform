variable "project_id" {
  description = "GCP project identifier"
  type        = string
}

variable "region" {
  description = "Region for regional resources"
  type        = string
}

variable "network_name" {
  description = "Name of the VPC network"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR range for the primary subnet"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "project_name" {
  description = "Project label for tagging"
  type        = string
}

variable "labels" {
  description = "Additional labels applied to resources"
  type        = map(string)
  default     = {}
}
