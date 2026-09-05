locals {
  labels = merge(
    {
      environment = var.environment
      component   = "monitoring"
    },
    var.labels
  )
}

resource "google_logging_project_bucket_config" "cluster" {
  count            = var.enable_cloud_logging ? 1 : 0
  project          = var.project_id
  bucket_id        = "gke-${var.environment}-${replace(var.cluster_name, "_", "-")}"
  description      = "Central bucket for GKE workload logs"
  location         = "global"
  retention_days   = 30
  enable_analytics = true
  locked           = false
}

resource "google_logging_metric" "gke_errors" {
  name        = "${var.cluster_name}-error-count"
  project     = var.project_id
  description = "Counts error entries emitted by the cluster"

  filter = "resource.type=\"k8s_container\" severity>=ERROR resource.labels.cluster_name=\"${var.cluster_name}\""

  label_extractors = {
    "namespace" = "EXTRACT(resource.labels.namespace_name)"
  }

  metric_descriptor {
    metric_kind  = "DELTA"
    value_type   = "INT64"
    unit         = "1"
    display_name = "GKE Error Count"
    labels {
      key         = "namespace"
      value_type  = "STRING"
      description = "Kubernetes namespace"
    }
  }
}

resource "google_monitoring_notification_channel" "email" {
  display_name = "GKE Alerts"
  type         = "email"
  description  = "Email alerts for GKE cluster events"
  labels = {
    email_address = var.alert_email
  }
  project = var.project_id
  enabled = true
}

resource "google_monitoring_alert_policy" "gke_errors" {
  display_name = "${var.cluster_name} - Error budget"
  combiner     = "OR"
  project      = var.project_id

  notification_channels = [google_monitoring_notification_channel.email.name]

  conditions {
    display_name = "High error rate"

    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/${google_logging_metric.gke_errors.name}\""
      duration        = "0s"
      comparison      = "COMPARISON_GT"
      threshold_value = 5

      trigger {
        count = 1
      }
    }
  }

  documentation {
    content   = "Investigate errors reported by the ${var.cluster_name} cluster."
    mime_type = "text/markdown"
  }

  user_labels = local.labels
}

resource "google_logging_project_sink" "cluster_bucket" {
  count                  = var.enable_cloud_logging ? 1 : 0
  name                   = "${var.cluster_name}-sink"
  project                = var.project_id
  destination            = "logging.googleapis.com/projects/${var.project_id}/locations/global/buckets/${google_logging_project_bucket_config.cluster[0].bucket_id}"
  filter                 = "resource.type=\"k8s_container\" resource.labels.cluster_name=\"${var.cluster_name}\""
  unique_writer_identity = true
}
