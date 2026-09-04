locals {
  repo_name = "webhook-${var.provider_name}-${var.version_name}"
}

resource "github_repository" "main" {
  name        = local.repo_name
  description = "Webhook handler for ${var.provider_name} (${var.version_name}). Deployed via GitHub Actions + Cloud Native Buildpacks to a Cloud Run service provisioned by terraform-workspace-gcp."
  # Public so GitHub Actions minutes are free. The branch ruleset below (required
  # signed commits + required PR review, admin-bypassable) is the actual defense
  # against unwanted/malicious outside contributions, not repo visibility.
  visibility = "public"

  allow_merge_commit     = false
  allow_squash_merge     = true
  allow_update_branch    = true
  auto_init              = true
  delete_branch_on_merge = true
  has_discussions        = false
  has_issues             = true
  has_projects           = false
  has_wiki               = false
}

data "github_branch" "main" {
  repository = github_repository.main.name
  branch     = "main"
}

resource "github_repository_ruleset" "main" {
  depends_on = [
    github_repository_file.static,
    github_repository_file.workflow,
    github_repository_file.readme,
    github_repository_file.claude,
    github_repository_file.starter,
  ]
  name        = "main"
  repository  = github_repository.main.name
  target      = "branch"
  enforcement = "active"

  bypass_actors {
    actor_id    = 5 # RepositoryRole "admin" - lets the user push/merge directly via admin override
    actor_type  = "RepositoryRole"
    bypass_mode = "always"
  }

  conditions {
    ref_name {
      exclude = []
      include = ["~DEFAULT_BRANCH"]
    }
  }

  rules {
    creation                = true
    update                  = true
    deletion                = true
    required_linear_history = true
    required_signatures     = true
    non_fast_forward        = true
    pull_request {
      dismiss_stale_reviews_on_push   = true
      require_last_push_approval      = true
      required_approving_review_count = 1
      allowed_merge_methods           = ["rebase"]
    }
  }
}
