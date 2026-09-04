# Managed by terraform-workspace-github (modules/webhook_repo) - do not edit by hand,
# changes will be reverted on the next apply. Source: templates/workflows/deploy.yml.tpl
name: Deploy

on:
  push:
    branches: [main]
    tags: ['*']

permissions:
  contents: read
  id-token: write

env:
  GCP_PROJECT_ID: ${gcp_project_id}
  GCP_REGION: ${gcp_region}
  SERVICE_NAME: ${cloud_run_service_name}
  IMAGE_REPOSITORY: ${artifact_registry_image}
  BUILDER_IMAGE: gcr.io/buildpacks/builder:google-22

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: google-github-actions/auth@v2
        with:
          workload_identity_provider: ${workload_identity_provider}
          service_account: ${service_account_email}

      - uses: google-github-actions/setup-gcloud@v2

      - name: Verify Cloud Run service runtime label
        run: |
          runtime=$(gcloud run services describe "$SERVICE_NAME" \
            --project "$GCP_PROJECT_ID" \
            --region "$GCP_REGION" \
            --format='value(metadata.labels.runtime)')
          echo "Detected runtime label: $runtime"
          if [ "$runtime" != "go" ] && [ "$runtime" != "nodejs" ]; then
            echo "::error::Unsupported or missing runtime label '$runtime' on Cloud Run service $SERVICE_NAME"
            exit 1
          fi

      - name: Install pack CLI
        uses: buildpacks/github-actions/setup-pack@v5.9.2

      - name: Configure Docker auth for Artifact Registry
        run: gcloud auth configure-docker "$GCP_REGION-docker.pkg.dev" --quiet

      - name: Build and publish image with Cloud Native Buildpacks
        run: |
          IMAGE_TAG="$IMAGE_REPOSITORY:$GITHUB_SHA"
          pack build "$IMAGE_TAG" --builder "$BUILDER_IMAGE" --publish
          echo "IMAGE_TAG=$IMAGE_TAG" >> "$GITHUB_ENV"

      - name: Deploy to Cloud Run
        run: |
          gcloud run deploy "$SERVICE_NAME" \
            --project "$GCP_PROJECT_ID" \
            --region "$GCP_REGION" \
            --image "$IMAGE_TAG" \
            --quiet
