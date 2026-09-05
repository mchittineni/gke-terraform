# Deployment Guide

Step-by-step instructions for provisioning the Google Cloud GKE Terraform infrastructure locally or through CI/CD.

---

## Prerequisites
1. **Google Cloud SDK**: `gcloud auth application-default login`
2. **Terraform**: `1.16.1+`
3. **IAM Permissions**: Owner or Editor role on the Google Cloud Project.

---

## Deployment Steps

### Step 1: Clone Repository
```bash
git clone https://github.com/mchittineni/gke-terraform.git
cd gke-terraform
```

### Step 2: Configure Environment
```bash
cp terraform.tfvars.example terraform.tfvars
```

Update `terraform.tfvars`:
```hcl
gcp_project_id = "your-gcp-project-id"
gcp_region     = "us-central1"
project_name   = "cloud-platform"
environment    = "dev"
```

### Step 3: Initialize Terraform
```bash
terraform init
```

### Step 4: Validate and Plan
```bash
terraform validate
terraform plan -out=tfplan
```

### Step 5: Apply Infrastructure
```bash
terraform apply tfplan
```

### Step 6: Configure kubectl
```bash
gcloud container clusters get-credentials cloud-platform-dev-gke --region us-central1 --project your-gcp-project-id
kubectl get nodes
```
