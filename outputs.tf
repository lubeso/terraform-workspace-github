output "static_site_repositories" {
  description = "Map of created static site repositories and their metadata."
  value = {
    for k, v in module.static_site_repos : k => {
      name          = v.repository_name
      html_url      = v.repository_html_url
      ssh_clone_url = v.repository_ssh_clone_url
    }
  }
}
