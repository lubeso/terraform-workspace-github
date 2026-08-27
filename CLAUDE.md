# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Status

Single root-module Terraform workspace that manages GitHub resources via the
`integrations/github` provider (`~> 6.13`, Terraform `~> 1.16.0`). Only the
provider scaffold exists so far — no resources yet.

- `providers.tf` — the only `.tf` file: the `terraform` block (`required_version`,
  `required_providers`) and an **empty** `provider "github" {}` block. There is no
  `cloud`/`backend` block (the HCP Terraform workspace's repo connection and backend
  are configured in HCP), so a bare `terraform init` uses the local backend. No
  `variables.tf` — the provider takes nothing from Terraform variables.

## Authentication

Everything the provider needs comes from environment variables, set as workspace
variables in HCP Terraform:

- `GITHUB_OWNER` — org/user the workspace manages (not sensitive).
- `GITHUB_TOKEN` — fine-grained PAT or GitHub App user access token (**sensitive**).
- `GITHUB_AUTH_MODE` — optional; `token` to pin the mode instead of default `auto`.

Keeping these out of config keeps the secret out of state. Never wire the token
into a variable or `.tfvars`. Scope it to only what this workspace manages, and
rotate it.

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
- `.tfvars` / `.tfvars.json` are gitignored. The provider is configured entirely from
  environment variables (`GITHUB_*`), so there are no Terraform variables to set.
- State (`*.tfstate`) is gitignored; state lives in HCP Terraform, not locally.
- `terraform providers lock` must be re-run (all four platforms above) whenever the
  provider version changes, or the `terraform_providers_lock` pre-commit hook fails.
- `terraform init` uses the local backend (no `cloud`/`backend` block). `terraform
  validate` still needs `init` to have downloaded the provider first.
