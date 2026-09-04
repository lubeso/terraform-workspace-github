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
terraform-workspace-gcp) must be kept in sync with whichever runtime this repo
actually uses; CI validates this at deploy time and fails if the label is missing or
unsupported.

## CI/CD

`.github/workflows/deploy.yml` runs on every push to `main` and every tag push:
authenticate via Workload Identity Federation → validate the Cloud Run runtime label
→ `pack build --publish` → `gcloud run deploy ${repo_name}`. This repo is public (for
free GitHub Actions minutes); the branch ruleset (required signed commits, required
PR review) is the actual protection against unwanted or malicious contributions
reaching `main` and triggering a deploy — the workflow only triggers on `push`, never
`pull_request`, so fork PRs can't run it regardless.

## Conventions

- This repo was bootstrapped by `terraform-workspace-github`'s `modules/webhook_repo`
  — keep the generated `.editorconfig` / `.pre-commit-config.yaml` conventions unless
  there's a specific reason to diverge.
- `.github/workflows/deploy.yml`, `README.md`, and this file are managed by
  `terraform-workspace-github` and regenerated on every apply — edit their source
  templates there, not this copy, or changes will be reverted.
