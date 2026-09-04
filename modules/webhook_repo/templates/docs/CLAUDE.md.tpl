# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in
this repository.

## Overview

`${repo_name}` is the application source for one webhook handler: provider
`${provider_name}`, API version `${version_name}`. It is deployed to an existing
Google Cloud Run v2 service of the same name, which is provisioned — along with its
Artifact Registry repository, load-balancer route, and IAM — by a sibling repository,
`terraform-workspace-gcp`, NOT by this repository. This repository owns application
code and CI only; do not add Terraform or other GCP-provisioning code here.

## Runtime contract

Runtime: `${runtime}`. Cloud Native Buildpacks auto-detects this from the presence of
`go.mod` (Go) or `package.json` (Node.js) in the repo root — keep exactly one such
marker file present. The Cloud Run service's `runtime` label (set in
terraform-workspace-gcp) should be kept in sync with whichever runtime this repo
actually uses, but nothing enforces this at deploy time — buildpacks auto-detection
picks the right builder regardless of the label.

## CI/CD

`.github/workflows/cd.yaml` runs on every push to `main` and every tag push:
authenticate via Workload Identity Federation (`google-github-actions/auth`) →
`docker/login-action` against Artifact Registry using the WIF access token →
`pack build --publish` → deploy via `google-github-actions/deploy-cloudrun`. GCP
project/region/Artifact Registry repo/WIF provider/service account values come from
this repository's Actions variables (`vars.*`, provisioned by
`terraform-workspace-github`), not hardcoded in the workflow. This repo is public
(for free GitHub Actions minutes); the branch ruleset (required signed commits,
required PR review) is the actual protection against unwanted or malicious
contributions reaching `main` and triggering a deploy — the workflow only triggers on
`push`, never `pull_request`, so fork PRs can't run it regardless.

## Conventions

- This repo was bootstrapped by `terraform-workspace-github`'s `modules/webhook_repo`
  — keep the generated `.editorconfig` / `.pre-commit-config.yaml` conventions unless
  there's a specific reason to diverge.
- `.github/workflows/cd.yaml`, `README.md`, and this file are managed by
  `terraform-workspace-github` and regenerated on every apply — edit their source
  (`static/.github/workflows/cd.yaml` or `templates/docs/*.tpl`) there, not this
  copy, or changes will be reverted.
