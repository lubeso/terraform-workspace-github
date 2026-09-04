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

Runtime: **`${runtime}`**. This must match the `runtime` label on the
`${repo_name}` Cloud Run service in terraform-workspace-gcp — CI reads that label at
deploy time and fails the deploy if it isn't a supported value.

## Deployment

Every push to `main` (and every tag push) triggers `.github/workflows/deploy.yml`,
which:
1. Authenticates to Google Cloud via Workload Identity Federation (no stored keys).
2. Confirms the target Cloud Run service's `runtime` label is a supported value.
3. Builds and publishes a container image with Cloud Native Buildpacks
   (`pack build --publish`, using Google's `gcr.io/buildpacks/builder:google-22`,
   which auto-detects both Go and Node.js).
4. Deploys that image to the existing Cloud Run service `${repo_name}` with
   `gcloud run deploy`.

Direct pushes to `main` require repository admin (or an approved pull request with a
signed commit) — see the branch ruleset on this repository.

## Local development

<!-- TODO: document how to run this handler locally. -->
