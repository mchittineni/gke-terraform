# Google Cloud GKE Architecture Specification

This document details the architectural layout, VPC-native network topology, Workload Identity model, and component interactions of the Google Kubernetes Engine infrastructure.

---

## Visual Architecture

![GCP Architecture Diagram](architecture.svg)

---

## Core Components

### 1. VPC & Network Architecture
- **Network**: Custom Google Cloud VPC in `GLOBAL` routing mode.
- **Primary Subnet**: `10.10.0.0/20` in `us-central1`.
- **Secondary Ranges**:
  - `pods`: `10.10.16.0/24` for Kubernetes pod IP allocation.
  - `services`: `10.10.32.0/24` for Kubernetes cluster services.
- **Cloud NAT & Router**: Provides secure outbound egress for private node pools without assigning external public IPs to worker instances.

### 2. Google Kubernetes Engine (GKE)
- **Mode**: VPC-native cluster with Alias IPs.
- **Release Channel**: `REGULAR` automated version management.
- **Security & Identity**:
  - Workload Identity (`<project_id>.svc.id.goog`) mapping Kubernetes service accounts to GCP IAM roles.
  - Shielded GKE Nodes with Secure Boot and Integrity Monitoring.
  - Dedicated least-privilege worker node Service Account.

### 3. Database Layer (Cloud SQL)
- **Engine**: PostgreSQL 16.
- **Connectivity**: Private Service Access (PSA) using internal VPC peering (`servicenetworking.googleapis.com`).
- **Resilience**: Point-in-time recovery, automated daily backups, and GCS export bucket.

### 4. Cloud Logging & Monitoring
- **Logging**: Custom project log sink routing GKE container logs to a designated log bucket with 30-day retention.
- **Monitoring**: Alert policies tracking container error budgets and notification channels via email.
