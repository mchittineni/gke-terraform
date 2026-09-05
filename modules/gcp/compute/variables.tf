variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "Region where the GKE cluster will run"
  type        = string
}

variable "network_name" {
  description = "Name of the VPC network"
  type        = string
}

variable "subnet_name" {
  description = "Name of the subnet used by the cluster"
  type        = string
}

variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
}

variable "machine_type" {
  description = "Machine type for worker nodes"
  type        = string
}

variable "node_count" {
  description = "Desired number of worker nodes"
  type        = number
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "release_channel" {
  description = "GKE release channel"
  type        = string
  default     = "REGULAR"
}

variable "labels" {
  description = "Labels applied to cluster resources"
  type        = map(string)
  default     = {}
}
