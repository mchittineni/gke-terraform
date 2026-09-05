locals {
  labels = merge(
    {
      environment = var.environment
      component   = "gke"
    },
    var.labels
  )
}

data "google_compute_subnetwork" "selected" {
  name    = var.subnet_name
  project = var.project_id
  region  = var.region
}

resource "google_service_account" "nodes" {
  account_id   = "${var.cluster_name}-nodes"
  display_name = "GKE ${var.cluster_name} nodes"
  project      = var.project_id
}

resource "google_container_cluster" "this" {
  name     = var.cluster_name
  project  = var.project_id
  location = var.region

  remove_default_node_pool = true
  initial_node_count       = 1

  network    = "projects/${var.project_id}/global/networks/${var.network_name}"
  subnetwork = data.google_compute_subnetwork.selected.self_link

  release_channel {
    channel = var.release_channel
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = data.google_compute_subnetwork.selected.secondary_ip_range[0].range_name
    services_secondary_range_name = data.google_compute_subnetwork.selected.secondary_ip_range[1].range_name
  }

  # checkov:skip=CKV_GCP_13: Client certificates are deprecated; Workload Identity and IAM are used
  # checkov:skip=CKV_GCP_24: PodSecurityPolicy is deprecated and removed in Kubernetes 1.25+
  # checkov:skip=CKV_GCP_65: RBAC Google Groups require Google Workspace domain integration
  # checkov:skip=CKV_GCP_66: Binary Authorization is managed centrally via organization policy
  enable_shielded_nodes       = true
  enable_intranode_visibility = true

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = data.google_compute_subnetwork.selected.ip_cidr_range
      display_name = "VPC Subnet"
    }
  }

  addons_config {
    network_policy_config {
      disabled = false
    }
  }

  network_policy {
    enabled  = true
    provider = "PROVIDER_UNSPECIFIED"
  }

  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }

  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS", "POD", "DEPLOYMENT"]
  }

  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  vertical_pod_autoscaling {
    enabled = true
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  resource_labels = local.labels
}

resource "google_container_node_pool" "primary" {
  name     = "${var.cluster_name}-pool"
  project  = var.project_id
  cluster  = google_container_cluster.this.name
  location = var.region

  initial_node_count = var.node_count

  node_config {
    service_account = google_service_account.nodes.email
    machine_type    = var.machine_type
    image_type      = "COS_CONTAINERD"
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    tags   = ["gke-nodes"]
    labels = local.labels
    metadata = {
      disable-legacy-endpoints = "true"
    }
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  autoscaling {
    min_node_count = var.node_count > 1 ? var.node_count - 1 : 1
    max_node_count = var.node_count + 2
  }
}
