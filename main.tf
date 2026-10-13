module "static_site_repos" {
  for_each = var.static_sites
  source   = "./modules/static_site_repo"

  repo_name   = each.key
  description = each.value.description != null ? each.value.description : "Static website ${each.key}"
  framework   = each.value.framework
  visibility  = each.value.visibility != null ? each.value.visibility : "public"
  base_path   = each.value.base_path != null ? each.value.base_path : "/"
  bucket_path = each.value.bucket_path != null ? each.value.bucket_path : ""
  domain      = "www.${var.domain}"

  gcp_project_id                 = var.gcp_project_id
  gcp_region                     = var.gcp_region
  gcp_storage_bucket             = var.gcp_storage_bucket
  gcp_workload_identity_provider = var.gcp_workload_identity_provider
  gcp_service_account_email      = var.gcp_service_account_email
}
