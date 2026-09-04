output "webhook_repositories" {
  description = "Map of \"<provider>-<version>\" => created GitHub repository full name, for manual verification against terraform-workspace-gcp's Cloud Run service names."
  value       = { for k, m in module.webhook_repos : k => m.repository_full_name }
}
