# terraform-workspace-github

Terraform configuration for managing GitHub resources via the
[`integrations/github`](https://registry.terraform.io/providers/integrations/github/latest)
provider.

- **Terraform:** `~> 1.16.0`
- **Provider:** `integrations/github ~> 6.13`, `hashicorp/local ~> 2.7.0`
- **Runs:** plan and apply execute in HCP Terraform (Terraform Cloud); state lives
  there. The workspace's repo connection and backend are configured in HCP
  Terraform, not in this configuration.

## Overview

This workspace declaratively provisions and bootstraps webhook application
repositories (`webhook-<provider>-<version>`) corresponding to endpoints managed by
[`terraform-workspace-gcp`](https://github.com/lubeso/terraform-workspace-gcp).

Each webhook repository created via `modules/webhook_repo` includes:
- **Repository & branch ruleset:** Public repo with protected default branch requiring
  signed commits, pull request reviews, linear history, and squash/rebase merges.
- **Actions variables:** Non-sensitive GCP identity parameters (`GCP_PROJECT_ID`,
  `GCP_REGION`, `ARTIFACT_REGISTRY_REPOSITORY_ID`, `WORKLOAD_IDENTITY_PROVIDER`,
  `GCP_SERVICE_ACCOUNT_EMAIL`) for keyless authentication via Workload Identity
  Federation (WIF).
- **Starter scaffold:** Minimal runtime boilerplate (`go` or `nodejs`) with
  HTTP handling.
- **Continuous Deployment:** `.github/workflows/cd.yaml` builds images using
  Cloud Native Buildpacks and deploys directly to the target Cloud Run service.

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

Configure the workspace input variables defined in `variables.tf`:

| Name | Description | Source |
|------|-------------|--------|
| `webhooks` | Map of provider => version => `{ runtime }` | Mirrored from `terraform-workspace-gcp` |
| `gcp_project_id` | Target GCP project ID | From GCP workspace |
| `gcp_region` | Target GCP region | From GCP workspace |
| `artifact_registry_repository_id` | Artifact Registry repo ID for webhook images (default `webhooks`) | From GCP workspace |
| `workload_identity_provider` | WIF provider resource name | Copied from GCP workspace after first apply |
| `github_actions_service_account_email` | GitHub Actions service account email | Copied from GCP workspace after first apply |

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
