locals {
  labels = merge(
    {
      environment = var.environment
      component   = "cloud-sql"
    },
    var.labels
  )
}

resource "random_password" "db" {
  length      = 20
  special     = true
  min_numeric = 4
  min_upper   = 2
  min_lower   = 4
  min_special = 2
}

resource "random_id" "bucket" {
  byte_length = 4
}

resource "google_compute_global_address" "private_service" {
  name          = "${var.instance_name}-psa"
  project       = var.project_id
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  network       = var.network_id
  prefix_length = 24
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = var.network_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_service.name]
}

resource "google_storage_bucket" "backups" {
  # checkov:skip=CKV_GCP_114: ADD REASON
  name          = lower(replace("${var.instance_name}-${random_id.bucket.hex}", "_", "-"))
  project       = var.project_id
  location      = var.region
  force_destroy = false
  storage_class = "STANDARD"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 30
    }
  }

  labels = local.labels
}

resource "google_sql_database_instance" "this" {
  name             = var.instance_name
  project          = var.project_id
  region           = var.region
  database_version = var.database_version

  depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier              = var.tier
    availability_type = var.availability_type
    disk_type         = "PD_SSD"
    disk_size         = 50
    disk_autoresize   = true
    pricing_plan      = "PER_USE"

    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = var.network_id
      enable_private_path_for_google_cloud_services = true
    }

    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = true
      transaction_log_retention_days = 7
    }

    maintenance_window {
      day  = 7
      hour = 3
    }

    insights_config {
      query_insights_enabled  = true
      query_plans_per_minute  = 5
      query_string_length     = 1024
      record_application_tags = true
    }

    database_flags {
      name  = "cloudsql.iam_authentication"
      value = "on"
    }

    user_labels = local.labels
  }

  deletion_protection = var.environment == "production"
}

resource "google_sql_database" "default" {
  name     = var.database_name
  project  = var.project_id
  instance = google_sql_database_instance.this.name
}

resource "google_sql_user" "application" {
  name     = "app_user"
  project  = var.project_id
  instance = google_sql_database_instance.this.name
  password = random_password.db.result
}

resource "google_storage_bucket_iam_member" "backup_writer" {
  bucket = google_storage_bucket.backups.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_sql_database_instance.this.service_account_email_address}"
}
