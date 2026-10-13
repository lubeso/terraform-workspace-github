resource "github_repository" "main" {
  name        = var.repo_name
  description = var.description
  visibility  = var.visibility

  allow_merge_commit     = false
  allow_squash_merge     = true
  allow_rebase_merge     = true
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
    github_repository_file.common,
    github_repository_file.readme,
    github_repository_file.agents,
    github_repository_file.favicons_text,
    github_repository_file.favicons_binary,
    github_repository_file.workflows,
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
      allowed_merge_methods           = ["squash", "rebase"]
    }
  }
}

resource "github_actions_variable" "gcp_project_id" {
  repository    = github_repository.main.name
  variable_name = "GCP_PROJECT_ID"
  value         = var.gcp_project_id
}

resource "github_actions_variable" "gcp_region" {
  repository    = github_repository.main.name
  variable_name = "GCP_REGION"
  value         = var.gcp_region
}

resource "github_actions_variable" "gcp_storage_bucket" {
  repository    = github_repository.main.name
  variable_name = "GCP_STORAGE_BUCKET"
  value         = var.gcp_storage_bucket
}

resource "github_actions_variable" "gcp_workload_identity_provider" {
  repository    = github_repository.main.name
  variable_name = "GCP_WORKLOAD_IDENTITY_PROVIDER"
  value         = var.gcp_workload_identity_provider
}

resource "github_actions_variable" "gcp_service_account_email" {
  repository    = github_repository.main.name
  variable_name = "GCP_SERVICE_ACCOUNT_EMAIL"
  value         = var.gcp_service_account_email
}

resource "github_actions_variable" "bucket_path" {
  repository    = github_repository.main.name
  variable_name = "BUCKET_PATH"
  value         = var.bucket_path
}
