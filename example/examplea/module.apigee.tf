# holden:ignore:HLD_TF_026 — examples intentionally use ../../ to reference the local module root
# holden:ignore:HLD_TF_065: for expansion
module "apigee" {
  source             = "../../"
  project_id         = data.google_project.current.project_id
  environment_name   = "eval"
  analytics_region   = local.region
  authorized_network = google_compute_network.apigee.name
  retention          = "MINIMUM"

  # Each data plane gets its own key. control_plane_key_name is left null:
  # control plane data is stored multi-regionally, so it needs a key in a
  # multi-region KMS location (europe), not the regional key ring this example
  # creates in europe-west2.
  encryption = {
    runtime_database_key_name  = google_kms_crypto_key.apigee.id
    api_consumer_data_key_name = google_kms_crypto_key.apigee_consumer_data.id
    api_consumer_data_location = local.region
  }

  node_config = {
    min_node_count = 1
    max_node_count = 3
  }

  instances = {
    "example-instance" = {
      location                 = local.region
      disk_encryption_key_name = google_kms_crypto_key.apigee.id
    }
  }

  depends_on = [
    google_service_networking_connection.apigee,
    time_sleep.kms_iam_propagation,
  ]
}
