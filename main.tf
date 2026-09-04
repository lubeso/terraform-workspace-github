locals {
  # Mirrors terraform-workspace-gcp's local.flattened_webhooks exactly, so the two
  # repos' resource keys ("<provider>-<version>") always line up 1:1.
  flattened_webhooks = merge([
    for provider, versions in var.webhooks : {
      for version, config in versions :
      "${provider}-${version}" => {
        provider = provider
        version  = version
        config   = config
      }
    }
  ]...)
}

module "webhook_repos" {
  source   = "./modules/webhook_repo"
  for_each = local.flattened_webhooks

  provider_name = each.value.provider
  version_name  = each.value.version
  runtime       = each.value.config.runtime

  gcp_project_id                       = var.gcp_project_id
  gcp_region                           = var.gcp_region
  artifact_registry_repository_id      = var.artifact_registry_repository_id
  workload_identity_provider           = var.workload_identity_provider
  github_actions_service_account_email = var.github_actions_service_account_email
}
