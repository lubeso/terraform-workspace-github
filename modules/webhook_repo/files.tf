data "local_file" "static" {
  for_each = {
    for filename in fileset("${path.module}/static", "**")
    : filename => true
  }
  filename = "${path.module}/static/${each.key}"
}

resource "github_repository_file" "static" {
  for_each            = data.local_file.static
  repository          = github_repository.main.name
  branch              = data.github_branch.main.branch
  file                = each.key
  content             = each.value.content
  commit_message      = "chore: add ${each.key}"
  overwrite_on_create = true
}

locals {
  artifact_registry_image = "${var.gcp_region}-docker.pkg.dev/${var.gcp_project_id}/${var.artifact_registry_repository_id}/${local.repo_name}"

  workflow_content = templatefile("${path.module}/templates/workflows/deploy.yml.tpl", {
    cloud_run_service_name     = local.repo_name
    gcp_project_id             = var.gcp_project_id
    gcp_region                 = var.gcp_region
    artifact_registry_image    = local.artifact_registry_image
    workload_identity_provider = var.workload_identity_provider
    service_account_email      = var.github_actions_service_account_email
  })

  readme_content = templatefile("${path.module}/templates/docs/README.md.tpl", {
    repo_name     = local.repo_name
    provider_name = var.provider_name
    version_name  = var.version_name
    runtime       = var.runtime
  })

  claude_content = templatefile("${path.module}/templates/docs/CLAUDE.md.tpl", {
    repo_name     = local.repo_name
    provider_name = var.provider_name
    version_name  = var.version_name
    runtime       = var.runtime
  })

  starter_files = var.runtime == "nodejs" ? {
    "index.js"     = templatefile("${path.module}/templates/starter/nodejs/index.js.tpl", { provider_name = var.provider_name })
    "package.json" = templatefile("${path.module}/templates/starter/nodejs/package.json.tpl", { repo_name = local.repo_name })
    } : {
    "main.go" = templatefile("${path.module}/templates/starter/go/main.go.tpl", { provider_name = var.provider_name })
    "go.mod"  = templatefile("${path.module}/templates/starter/go/go.mod.tpl", { module_name = local.repo_name })
  }
}

resource "github_repository_file" "workflow" {
  repository          = github_repository.main.name
  branch              = data.github_branch.main.branch
  file                = ".github/workflows/deploy.yml"
  content             = local.workflow_content
  commit_message      = "ci: add deploy workflow"
  overwrite_on_create = true
}

resource "github_repository_file" "readme" {
  repository          = github_repository.main.name
  branch              = data.github_branch.main.branch
  file                = "README.md"
  content             = local.readme_content
  commit_message      = "docs: add README"
  overwrite_on_create = true # overwrites the README auto_init already created
}

resource "github_repository_file" "claude" {
  repository          = github_repository.main.name
  branch              = data.github_branch.main.branch
  file                = "CLAUDE.md"
  content             = local.claude_content
  commit_message      = "docs: add CLAUDE.md"
  overwrite_on_create = true
}

resource "github_repository_file" "starter" {
  for_each            = local.starter_files
  repository          = github_repository.main.name
  branch              = data.github_branch.main.branch
  file                = each.key
  content             = each.value
  commit_message      = "feat: add starter ${var.runtime} scaffold"
  overwrite_on_create = true
}
