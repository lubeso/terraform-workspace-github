output "repository_name" {
  description = "The name of the repository."
  value       = github_repository.main.name
}

output "repository_html_url" {
  description = "URL to the repository on GitHub."
  value       = github_repository.main.html_url
}

output "repository_ssh_clone_url" {
  description = "URL that can be provided to git clone to clone the repository via SSH."
  value       = github_repository.main.ssh_clone_url
}
