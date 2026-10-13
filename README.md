# terraform-workspace-github

Terraform configuration for managing GitHub resources via the
[`integrations/github`](https://registry.terraform.io/providers/integrations/github/latest)
provider.

- **Terraform:** `~> 1.16.0`
- **Provider:** `integrations/github ~> 6.13`
- **Runs:** plan and apply execute in HCP Terraform (Terraform Cloud); state lives
  there. The workspace's repo connection and backend are configured in HCP
  Terraform, not in this configuration.

## One-time setup

1. Create a token for the target organization — a fine-grained personal access
   token (or a GitHub App user access token) scoped to only what this workspace
   manages.
2. On the HCP Terraform workspace, add these **environment variables** (the
   provider block is empty; every value is read from the environment):

   | Name | Value | Sensitive |
   |------|-------|-----------|
   | `GITHUB_OWNER` | organization (or user) login this workspace manages | no |
   | `GITHUB_TOKEN` | the token | **yes** |
   | `GITHUB_AUTH_MODE` | `token` (optional; pins the auth mode) | no |

   The token never appears in configuration or state.

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
