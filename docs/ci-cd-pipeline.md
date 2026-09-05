# CI/CD Pipeline & GitHub Actions Guide

This project leverages automated GitHub Actions workflows with passwordless Workload Identity Federation (WIF).

---

## Workflows Overview

| Workflow | Trigger | Description |
| :--- | :--- | :--- |
| `validate.yml` | Push & PR | Checks format, validates syntax, runs TFLint (google) and Checkov |
| `plan.yml` | Pull Request | Runs plan via GCP OIDC, generates architecture SVG, posts PR comment |
| `apply.yml` | Merge to `main` | Deploys infrastructure and updates post-apply architecture diagram |
| `diagram.yml` | Dispatch / HCL push | Renders standalone SVG diagram and commits to repo |
| `destroy.yml` | Manual Dispatch | Tears down resources when confirmed with `DESTROY` keyword |

---

## Workload Identity Federation (WIF) Setup

Authenticate to GCP without long-lived service account keys:

### Required GitHub Secrets
1. `GCP_WORKLOAD_IDENTITY_PROVIDER`: e.g. `projects/123456789/locations/global/workloadIdentityPools/github-pool/providers/github-provider`
2. `GCP_SERVICE_ACCOUNT`: The deployment service account email with Project Editor / Admin roles.
