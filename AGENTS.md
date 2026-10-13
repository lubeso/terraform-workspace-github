# AGENTS.md

This file provides guidance to AI coding agents when working with code in this repository.

## Status

Root-module Terraform workspace that manages GitHub resources via the
`integrations/github` provider (`~> 6.13`) and `hashicorp/local` provider (`~> 2.7.0`)
on Terraform `~> 1.16.0`.

The workspace provisions and bootstraps webhook application repositories
(`webhook-<provider>-<version>`) via `modules/webhook_repo`, driven by `var.webhooks`
to mirror endpoints defined in `terraform-workspace-gcp`.

- `providers.tf` — Terraform block (`required_version`, `required_providers`) and an
  **empty** `provider "github" {}` block. There is no `cloud`/`backend` block (the
  HCP Terraform workspace's repo connection and backend are configured in HCP), so a
  bare `terraform init` uses the local backend.
- `main.tf` — Flattens `var.webhooks` into `"<provider>-<version>"` keys and calls
  `module.webhook_repos` with `for_each`.
- `variables.tf` — `var.webhooks` configuration map and GCP identity inputs
  (`gcp_project_id`, `gcp_region`, `artifact_registry_repository_id`,
  `workload_identity_provider`, `github_actions_service_account_email`).
- `outputs.tf` — `webhook_repositories` output mapping each webhook key to its full
  GitHub repository name.
- `modules/webhook_repo` — Submodule creating a public GitHub repository, branch
  ruleset (signatures, PR review, squash/rebase merges), Actions variables, starter
  scaffold (Go or Node.js), and CD workflow.

## Authentication

Provider credentials come from environment variables, set as workspace variables in
HCP Terraform:

- `GITHUB_OWNER` — org/user the workspace manages (not sensitive).
- `GITHUB_TOKEN` — fine-grained PAT or GitHub App user access token (**sensitive**).
- `GITHUB_AUTH_MODE` — optional; `token` to pin the mode instead of default `auto`.

Keeping these out of config keeps the secret out of state. Never wire the token
into a variable or `.tfvars`. Scope it to only what this workspace manages, and
rotate it.

## Workspace Variables

In addition to provider environment variables, HCP Terraform workspace variables must
supply the Terraform input variables defined in `variables.tf`:

- `webhooks` — nested map of `provider => version => { runtime }`, mirroring the
  same variable in `terraform-workspace-gcp`.
- GCP identity values — `gcp_project_id`, `gcp_region`,
  `artifact_registry_repository_id`, `workload_identity_provider`, and
  `github_actions_service_account_email` (copied from `terraform-workspace-gcp` post-apply).

## Commands

```sh
terraform init                 # initialize backend + providers
terraform validate             # static validation (also a pre-commit hook)
terraform fmt -recursive       # format (also a pre-commit hook)
terraform plan
terraform apply
terraform providers lock \
  -platform=darwin_arm64 -platform=darwin_amd64 \
  -platform=linux_amd64 -platform=linux_arm64   # regenerate .terraform.lock.hcl (keep all four platforms)

pre-commit run --all-files     # run every hook against the whole tree
pre-commit run terraform_validate --all-files    # run a single hook
```

There is no test suite. `pre-commit` is the gate: it runs `terraform_fmt`,
`terraform_providers_lock`, and `terraform_validate` (plus YAML / whitespace / EOF
fixers). Install hooks once with `pre-commit install`.

## Conventions

- 2-space indent, LF endings, max line length 88, final newline required
  (enforced by `.editorconfig`).
- `.tfvars` / `.tfvars.json` are gitignored.
- State (`*.tfstate`) is gitignored; state lives in HCP Terraform, not locally.
- `terraform providers lock` must be re-run (all four platforms above) whenever the
  provider version changes, or the `terraform_providers_lock` pre-commit hook fails.
- `terraform init` uses the local backend (no `cloud`/`backend` block). `terraform
  validate` still needs `init` to have downloaded the provider first.
