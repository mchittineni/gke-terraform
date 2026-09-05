# ==================== Terraform Configuration ====================
# Defines the required Terraform version, providers, and Google Cloud Storage (GCS) backend.
terraform {
  required_version = ">= 1.15.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.20.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 6.20.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.9.0"
    }
  }

  # Configuration for the GCS backend to store the Terraform state file securely.
  backend "gcs" {
    bucket = "terraform-state-gke-multicloud"
    prefix = "gke/state"
  }
}

# ==================== Provider Configurations ====================
provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

provider "google-beta" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# ==================== Locals ====================
locals {
  common_labels = {
    project     = var.project_name
    environment = var.environment
    application = "gcp-gke-terraform"
    owner       = replace(replace(var.owner_email, "@", "-at-"), ".", "-dot-")
  }
}

# ==================== GCP Infrastructure Modules ====================
# Module for configuring VPC, Subnets with secondary ranges, Cloud Router, and Cloud NAT.
module "gcp_networking" {
  source       = "./modules/gcp/networking"
  project_id   = var.gcp_project_id
  region       = var.gcp_region
  network_name = "${var.project_name}-${var.environment}-vpc"
  subnet_cidr  = var.gcp_subnet_cidr
}

# Module for provisioning GKE VPC-native Cluster and Node Pools with Workload Identity.
module "gcp_compute" {
  source          = "./modules/gcp/compute"
  project_id      = var.gcp_project_id
  region          = var.gcp_region
  network_name    = module.gcp_networking.network_name
  subnet_name     = module.gcp_networking.subnet_name
  cluster_name    = "${var.project_name}-${var.environment}-gke"
  machine_type    = var.gcp_machine_type
  node_count      = var.gcp_node_count
  release_channel = var.gke_release_channel
  environment     = var.environment
  labels          = local.common_labels
}

# Module for provisioning Cloud SQL PostgreSQL with Private Service Access.
module "gcp_database" {
  source            = "./modules/gcp/database"
  project_id        = var.gcp_project_id
  region            = var.gcp_region
  network_id        = module.gcp_networking.network_id
  instance_name     = "${var.project_name}-${var.environment}-db"
  database_name     = var.gcp_db_name
  database_version  = var.gcp_db_version
  tier              = var.gcp_db_tier
  environment       = var.environment
  availability_type = var.gcp_db_availability_type
  labels            = local.common_labels
}

# Module for configuring Cloud Logging bucket, error metrics, and Cloud Monitoring alert policies.
module "gcp_monitoring" {
  source               = "./modules/gcp/monitoring"
  project_id           = var.gcp_project_id
  cluster_name         = module.gcp_compute.cluster_name
  environment          = var.environment
  enable_cloud_logging = var.enable_monitoring
  alert_email          = var.alert_email
  labels               = local.common_labels
}
