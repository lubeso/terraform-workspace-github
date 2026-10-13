# terraform-workspace-github

Terraform configuration for managing GitHub resources via the
[`integrations/github`](https://registry.terraform.io/providers/integrations/github/latest)
provider.

- **Terraform:** `~> 1.16.0`
- **Provider:** `integrations/github ~> 6.13`
- **Runs:** plan and apply execute in HCP Terraform (Terraform Cloud); state lives
  there. The workspace's repo connection and backend are configured in HCP
  Terraform, not in this configuration.

## Overview

This workspace declaratively provisions and bootstraps static website
repositories corresponding to sites hosted under `www.<domain>` in Google Cloud
Storage (managed by [`terraform-workspace-gcp`](https://github.com/lubeso/terraform-workspace-gcp)).

Each static site repository created via `modules/static_site_repo` includes:
- **Repository & branch ruleset:** Protected default branch requiring signed commits,
  pull request reviews, linear history, and squash/rebase merges.
- **Actions variables:** Non-sensitive GCP identity parameters (`GCP_PROJECT_ID`,
  `GCP_REGION`, `GCP_STORAGE_BUCKET`, `GCP_WORKLOAD_IDENTITY_PROVIDER`,
  `GCP_SERVICE_ACCOUNT_EMAIL`, `BUCKET_PATH`) for keyless authentication via
  Workload Identity Federation (WIF).
- **Starter scaffold:** Framework starter boilerplate (Astro 5.x) complete with
  icon assets (`favicon.ico`, `favicon.svg`, `apple-touch-icon.png`, `icon-192.png`,
  `icon-512.png`), OpenGraph / Twitter Card metadata in `Layout.astro`,
  `.editorconfig`, `.gitignore`, `LICENSE`, `README.md`, and `AGENTS.md`.
- **CI/CD Workflows:**
  - **CI (`.github/workflows/ci.yaml`):** Runs on pushes and pull requests to `main`
    to build and validate the application.
  - **CD (`.github/workflows/cd.yaml`):** Runs on **published releases**. Authenticates
    to Google Cloud via Workload Identity Federation (WIF) and uploads static assets
    to the designated path in the GCS static bucket.

## One-time setup

### 1. Environment variables

On the HCP Terraform workspace, configure these **environment variables** (the
provider block is empty; all credentials are read from the environment):

| Name | Value | Sensitive |
|------|-------|-----------|
| `GITHUB_OWNER` | organization (or user) login this workspace manages | no |
| `GITHUB_TOKEN` | fine-grained PAT or GitHub App user access token | **yes** |
| `GITHUB_AUTH_MODE` | `token` (optional; pins the auth mode) | no |

The token never appears in configuration or state.

### 2. Terraform variables

Configure these workspace input variables in HCP Terraform:

| Name | Description | Source |
|------|-------------|--------|
| `static_sites` | Map of site configurations (framework, visibility, base_path, bucket_path) | Managed in HCP |
| `domain` | Root domain for websites (e.g. `lubeso.dev`) | Managed in HCP |
| `gcp_project_id` | Target GCP project ID | From `terraform-workspace-gcp` outputs |
| `gcp_region` | Target GCP region | From `terraform-workspace-gcp` outputs |
| `gcp_storage_bucket` | Target GCS static bucket | From `terraform-workspace-gcp` |
| `gcp_workload_identity_provider` | WIF provider resource name | From `terraform-workspace-gcp` outputs |
| `gcp_service_account_email` | GitHub Actions service account email | From `terraform-workspace-gcp` outputs |

## Local use

```sh
terraform init
terraform plan
```

With no `cloud`/`backend` block in the configuration, `terraform init` uses the
local backend. To drive the HCP Terraform workspace from the CLI instead, add a
`cloud` block (or `terraform init` with a `remote` `-backend-config`), and export
`GITHUB_OWNER` / `GITHUB_TOKEN` locally.

## Checks

```sh
pre-commit run --all-files
```
