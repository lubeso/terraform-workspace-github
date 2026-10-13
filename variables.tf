variable "webhooks" {
  description = <<-EOF
    Nested map of provider name => API version => per-endpoint config. MUST mirror
    terraform-workspace-gcp's var.webhooks of the same name EXACTLY (identical keys
    and `runtime` values) - one GitHub repository ("webhook-<provider>-<version>") is
    created per entry here, containing the source + CI for the Cloud Run service that
    terraform-workspace-gcp provisions under the same key.

    KNOWN LIMITATION (accepted tradeoff): this is a plain, hand-duplicated variable,
    not a cross-workspace remote-state lookup. Whenever an entry is added, changed, or
    removed in one repo's workspace variables, the same change must be made by hand in
    the other repo's workspace variables, or the GitHub repo and its Cloud Run service
    will drift out of sync.
  EOF
  type = map(map(object({
    runtime = optional(string, "go") # or "nodejs"
  })))
  default = {}

  validation {
    condition = alltrue(flatten([
      for provider, versions in var.webhooks : [
        for version, _ in versions :
        can(regex("^[a-z][a-z0-9-]*$", provider)) && can(regex("^[a-z0-9][a-z0-9-]*$", version))
      ]
    ]))
    error_message = "Provider and version keys must be lowercase alphanumeric/hyphens only (they become GitHub repo-name components)."
  }
}

# --- Plain GCP identity inputs -------------------------------------------------
# These duplicate values that live in terraform-workspace-gcp. All 5 values are
# directly exported by that workspace's outputs (see `output.gcp_project_id`,
# `output.gcp_region`, `output.artifact_registry_repository_id`,
# `output.github_actions_workload_identity_provider`, and
# `output.github_actions_service_account_email` there) via terraform-module-gcp-oidc
# v1.1.0+. Retrieve them via `terraform output` (or the HCP Terraform Outputs tab)
# and supply them as workspace variables here.

variable "gcp_project_id" {
  description = "GCP project ID terraform-workspace-gcp deploys the webhooks' Cloud Run services and Artifact Registry repository into."
  type        = string
}

variable "gcp_region" {
  description = "GCP region terraform-workspace-gcp deploys the webhooks' Cloud Run services and Artifact Registry repository to. Must match that workspace's own region."
  type        = string
}

variable "artifact_registry_repository_id" {
  description = "Artifact Registry Docker repository ID terraform-workspace-gcp creates for webhook images (google_artifact_registry_repository.webhooks.repository_id there)."
  type        = string
  default     = "webhooks"
}

variable "workload_identity_provider" {
  description = <<-EOF
    Full resource name of the WIF provider GitHub Actions authenticates through, e.g.
    "projects/123456789/locations/global/workloadIdentityPools/github-actions-ab12/providers/oidc".
    Copy from terraform-workspace-gcp's output.github_actions_workload_identity_provider.
  EOF
  type        = string
}

variable "github_actions_service_account_email" {
  description = <<-EOF
    Email of the service account for GitHub Actions CI/CD, e.g.
    "github-actions-ab12@<project>.iam.gserviceaccount.com".
    Copy from terraform-workspace-gcp's output.github_actions_service_account_email.
  EOF
  type        = string
}
