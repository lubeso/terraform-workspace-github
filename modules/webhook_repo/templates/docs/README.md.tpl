# ${repo_name}

Webhook handler for **${provider_name}** (API/version `${version_name}`).

This repository contains only the application source for this webhook handler. It
does not provision any GCP infrastructure — the Cloud Run service, Artifact Registry
repository, load-balancer route, and IAM this handler depends on are all provisioned
by [`terraform-workspace-gcp`](https://github.com/lubeso/terraform-workspace-gcp)
(see `var.webhooks["${provider_name}"]["${version_name}"]` there). This repository
itself is provisioned by
[`terraform-workspace-github`](https://github.com/lubeso/terraform-workspace-github)
(see `modules/webhook_repo`).

## Runtime

Runtime: **`${runtime}`**. This picked which starter scaffold this repo was seeded
with (`go.mod` vs `package.json`) — Cloud Native Buildpacks auto-detects the runtime
from that marker file at build time regardless, so there's no deploy-time check
against the Cloud Run service's `runtime` label in terraform-workspace-gcp; keep them
in sync by convention, not enforcement.

## Deployment

Every push to `main` (and every tag push) triggers `.github/workflows/cd.yaml`,
which:
1. Authenticates to Google Cloud via Workload Identity Federation (no stored keys).
2. Builds and publishes a container image with Cloud Native Buildpacks
   (`pack build --publish`, using Google's `gcr.io/buildpacks/builder:google-22`,
   which auto-detects both Go and Node.js).
3. Deploys that image to the existing Cloud Run service `${repo_name}` via the
   `google-github-actions/deploy-cloudrun` action.

GCP project/region/Artifact Registry/WIF values the workflow needs are read from this
repository's Actions variables (`vars.*`), not hardcoded in the workflow file.

Direct pushes to `main` require repository admin (or an approved pull request with a
signed commit) — see the branch ruleset on this repository.

## Local development

<!-- TODO: document how to run this handler locally. -->
