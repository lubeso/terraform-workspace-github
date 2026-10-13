# ${repo_name}

${description}

- **Framework**: ${framework}
- **Domain**: https://${domain}${base_path}
- **Managed by**: [terraform-workspace-github](https://github.com/lubeso/terraform-workspace-github)

## Development

```bash
# Install dependencies
npm ci

# Start local development server
npm run dev

# Build for production
npm run build

# Preview production build locally
npm run preview
```

## Deployment

Deployments are fully automated via GitHub Actions:
- **Continuous Integration (`.github/workflows/ci.yaml`)**: Runs on pushes and pull requests to `main` to build and validate the application.
- **Continuous Deployment (`.github/workflows/cd.yaml`)**: Runs on **published releases**. Authenticates to Google Cloud via Workload Identity Federation (WIF) and uploads static assets to Cloud Storage (`$${vars.GCP_STORAGE_DESTINATION}`).
