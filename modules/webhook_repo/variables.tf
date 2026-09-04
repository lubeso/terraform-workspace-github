variable "provider_name" {
  description = "Webhook provider name, e.g. \"notion\". Must match the corresponding key in terraform-workspace-gcp's var.webhooks."
  type        = string
}

variable "version_name" {
  description = "Webhook API version/date, e.g. \"2026-03-11\". Must match the corresponding nested key in terraform-workspace-gcp's var.webhooks[provider_name]."
  type        = string
}

variable "runtime" {
  description = "Buildpacks runtime for the starter scaffold and CI validation. Must match the `runtime` label terraform-workspace-gcp sets on the corresponding Cloud Run service."
  type        = string
  default     = "go"

  validation {
    condition     = contains(["go", "nodejs"], var.runtime)
    error_message = "runtime must be \"go\" or \"nodejs\"."
  }
}

variable "gcp_project_id" {
  type = string
}

variable "gcp_region" {
  type = string
}

variable "artifact_registry_repository_id" {
  type = string
}

variable "workload_identity_provider" {
  type = string
}

variable "github_actions_service_account_email" {
  type = string
}
