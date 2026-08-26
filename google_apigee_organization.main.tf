resource "google_apigee_organization" "main" {
  analytics_region                      = var.analytics_region
  project_id                            = var.project_id
  authorized_network                    = var.authorized_network
  runtime_type                          = "CLOUD"
  billing_type                          = var.billing_type
  runtime_database_encryption_key_name  = var.encryption.runtime_database_key_name
  api_consumer_data_encryption_key_name = var.encryption.api_consumer_data_key_name
  api_consumer_data_location            = var.encryption.api_consumer_data_location
  control_plane_encryption_key_name     = var.encryption.control_plane_key_name
  description                           = var.description
  retention                             = var.retention

  timeouts {
    create = var.timeouts.create
    delete = var.timeouts.delete
  }
}
