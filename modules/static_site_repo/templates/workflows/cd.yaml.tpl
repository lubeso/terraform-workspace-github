name: Continuous Deployment

on:
  release:
    types:
      - published
  workflow_dispatch:

jobs:
  deploy:
    name: Build & Deploy to Cloud Storage
    runs-on: ubuntu-latest
    permissions:
      contents: read
      id-token: write

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - id: auth
        name: Authenticate to Google Cloud
        uses: google-github-actions/auth@v2
        with:
          workload_identity_provider: $${{ vars.GCP_WORKLOAD_IDENTITY_PROVIDER }}
          service_account: $${{ vars.GCP_SERVICE_ACCOUNT_EMAIL }}

      - name: Set up Node.js
        uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: npm

      - name: Install dependencies
        run: npm ci

      - name: Build site
        run: npm run build

      - name: Upload to Cloud Storage
        uses: google-github-actions/upload-cloud-storage@v2
        with:
          path: dist
          destination: '$${{ vars.GCP_STORAGE_BUCKET }}$${{ vars.BUCKET_PATH != "" && format("/{0}", vars.BUCKET_PATH) || "" }}'
          parent: false
