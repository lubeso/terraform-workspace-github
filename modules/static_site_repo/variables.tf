variable "repo_name" {
  description = "Name of the GitHub repository."
  type        = string
}

variable "description" {
  description = "Description for the GitHub repository."
  type        = string
}

variable "framework" {
  description = "Static site framework (e.g. astro)."
  type        = string
}

variable "visibility" {
  description = "Repository visibility (public or private)."
  type        = string
}

variable "base_path" {
  description = "Base path for the static site (e.g. /)."
  type        = string
}

variable "bucket_path" {
  description = "Subpath destination in GCS static bucket (empty string for root)."
  type        = string
}

variable "domain" {
  description = "Full domain hosting the static site (e.g. www.lubeso.dev)."
  type        = string
}

variable "gcp_project_id" {
  description = "GCP Project ID."
  type        = string
}

variable "gcp_region" {
  description = "GCP Region."
  type        = string
}

variable "gcp_storage_bucket" {
  description = "GCS static bucket name."
  type        = string
}

variable "gcp_workload_identity_provider" {
  description = "WIF provider resource name for GitHub Actions."
  type        = string
}

variable "gcp_service_account_email" {
  description = "Service account email for GitHub Actions."
  type        = string
}
