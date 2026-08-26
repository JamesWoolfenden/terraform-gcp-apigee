resource "google_apigee_organization" "main" {
  analytics_region                     = var.analytics_region
  project_id                           = var.project_id
  authorized_network                   = var.authorized_network
  runtime_type                         = "CLOUD"
  billing_type                         = var.billing_type
  runtime_database_encryption_key_name = var.kms_key_name
  description                          = var.description
}
