locals {
  common_files = {
    ".editorconfig" = file("${path.module}/static/common/.editorconfig")
    ".gitignore"    = file("${path.module}/static/common/.gitignore")
    "LICENSE"       = file("${path.module}/static/common/LICENSE")
  }

  readme_content = templatefile("${path.module}/templates/docs/README.md.tpl", {
    repo_name   = var.repo_name
    description = var.description
    framework   = var.framework
    domain      = var.domain
    base_path   = var.base_path
  })

  agents_content = templatefile("${path.module}/templates/docs/AGENTS.md.tpl", {
    repo_name = var.repo_name
    framework = var.framework
    domain    = var.domain
    base_path = var.base_path
  })

  favicons_text_files = {
    "public/favicon.svg" = file("${path.module}/static/favicons/favicon.svg")
  }

  favicons_binary_files = {
    "public/apple-touch-icon.png" = filebase64("${path.module}/static/favicons/apple-touch-icon.png")
    "public/favicon.ico"          = filebase64("${path.module}/static/favicons/favicon.ico")
    "public/icon-192.png"         = filebase64("${path.module}/static/favicons/icon-192.png")
    "public/icon-512.png"         = filebase64("${path.module}/static/favicons/icon-512.png")
  }

  workflow_files = {
    ".github/workflows/ci.yaml" = templatefile("${path.module}/templates/workflows/ci.yaml.tpl", {})
    ".github/workflows/cd.yaml" = templatefile("${path.module}/templates/workflows/cd.yaml.tpl", {})
  }

  astro_starter_files = var.framework == "astro" ? {
    "package.json"             = templatefile("${path.module}/templates/starter/astro/package.json.tpl", { repo_name = var.repo_name })
    "astro.config.mjs"         = templatefile("${path.module}/templates/starter/astro/astro.config.mjs.tpl", { domain = var.domain, base_path = var.base_path })
    "tsconfig.json"            = templatefile("${path.module}/templates/starter/astro/tsconfig.json.tpl", {})
    "src/layouts/Layout.astro" = templatefile("${path.module}/templates/starter/astro/src/layouts/Layout.astro.tpl", { site_title = var.repo_name, site_description = var.description })
    "src/pages/index.astro"    = templatefile("${path.module}/templates/starter/astro/src/pages/index.astro.tpl", { site_title = var.repo_name, site_description = var.description })
  } : {}
}

resource "github_repository_file" "common" {
  for_each            = local.common_files
  repository          = github_repository.main.name
  branch              = data.github_branch.main.branch
  file                = each.key
  content             = each.value
  commit_message      = "chore: add ${each.key}"
  overwrite_on_create = true
}

resource "github_repository_file" "readme" {
  repository          = github_repository.main.name
  branch              = data.github_branch.main.branch
  file                = "README.md"
  content             = local.readme_content
  commit_message      = "docs: add README"
  overwrite_on_create = true
}

resource "github_repository_file" "agents" {
  repository          = github_repository.main.name
  branch              = data.github_branch.main.branch
  file                = "AGENTS.md"
  content             = local.agents_content
  commit_message      = "docs: add AGENTS.md"
  overwrite_on_create = true
}

resource "github_repository_file" "favicons_text" {
  for_each            = local.favicons_text_files
  repository          = github_repository.main.name
  branch              = data.github_branch.main.branch
  file                = each.key
  content             = each.value
  commit_message      = "feat: add ${each.key}"
  overwrite_on_create = true
}

resource "github_repository_file" "favicons_binary" {
  for_each            = local.favicons_binary_files
  repository          = github_repository.main.name
  branch              = data.github_branch.main.branch
  file                = each.key
  content             = each.value
  commit_message      = "feat: add ${each.key}"
  overwrite_on_create = true
}

resource "github_repository_file" "workflows" {
  for_each            = local.workflow_files
  repository          = github_repository.main.name
  branch              = data.github_branch.main.branch
  file                = each.key
  content             = each.value
  commit_message      = "ci: add ${each.key}"
  overwrite_on_create = true
}

resource "github_repository_file" "starter" {
  for_each            = local.astro_starter_files
  repository          = github_repository.main.name
  branch              = data.github_branch.main.branch
  file                = each.key
  content             = each.value
  commit_message      = "feat: add starter ${var.framework} scaffold (${each.key})"
  overwrite_on_create = true
}
