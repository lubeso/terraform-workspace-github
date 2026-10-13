variable "static_sites" {
  description = "Map of static site configurations to manage."
  type = map(object({
    framework   = string
    description = optional(string)
    visibility  = optional(string, "public")
    base_path   = optional(string, "/")
    bucket_path = optional(string, "")
  }))
}

variable "domain" {
  description = "Root domain for static websites."
  type        = string
}

variable "gcp_project_id" {
  description = "GCP Project ID."
  type        = string
}

variable "gcp_region" {
  description = "GCP region hosting static resources."
  type        = string
}

variable "gcp_storage_bucket" {
  description = "GCS static bucket name."
  type        = string
}

variable "gcp_workload_identity_provider" {
  description = "Full resource name of the WIF provider for GitHub Actions."
  type        = string
}

variable "gcp_service_account_email" {
  description = "Email of the service account for GitHub Actions."
  type        = string
}
