
resource "google_compute_network" "this" {
  name                            = var.network_name
  project                         = var.project_id
  auto_create_subnetworks         = false
  routing_mode                    = "GLOBAL"
  mtu                             = 1460
  delete_default_routes_on_create = false
}

resource "google_compute_subnetwork" "primary" {
  name                     = "${var.network_name}-primary"
  project                  = var.project_id
  region                   = var.region
  network                  = google_compute_network.this.id
  ip_cidr_range            = var.subnet_cidr
  private_ip_google_access = true
  stack_type               = "IPV4_ONLY"

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = cidrsubnet(var.subnet_cidr, 4, 1)
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = cidrsubnet(var.subnet_cidr, 4, 2)
  }

  purpose = "PRIVATE"

  dynamic "log_config" {
    for_each = [1]
    content {
      aggregation_interval = "INTERVAL_10_MIN"
      flow_sampling        = 0.5
      metadata             = "INCLUDE_ALL_METADATA"
    }
  }
}

resource "google_compute_firewall" "allow_internal" {
  name    = "${var.network_name}-allow-internal"
  network = google_compute_network.this.name
  project = var.project_id

  allow {
    protocol = "all"
  }

  source_ranges = [var.subnet_cidr]

  target_tags = ["internal"]
}

resource "google_compute_firewall" "allow_health_checks" {
  name    = "${var.network_name}-allow-health-checks"
  network = google_compute_network.this.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = [
    "35.191.0.0/16",
    "130.211.0.0/22"
  ]
}

resource "google_compute_router" "nat" {
  name    = "${var.network_name}-router"
  project = var.project_id
  region  = var.region
  network = google_compute_network.this.id

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "this" {
  name                                = "${var.network_name}-nat"
  project                             = var.project_id
  region                              = var.region
  router                              = google_compute_router.nat.name
  nat_ip_allocate_option              = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat  = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  enable_endpoint_independent_mapping = true

  log_config {
    enable = true
    filter = "ALL"
  }
}
