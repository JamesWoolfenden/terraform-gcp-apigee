# holden:ignore:HLD_TF_026 — examples intentionally use ../../ to reference the local module root
# holden:ignore:HLD_TF_065: for expansion
module "apigee" {
  source             = "../../"
  project_id         = data.google_project.current.project_id
  instance_name      = "example-instance"
  environment_name   = "eval"
  analytics_region   = "europe-west2"
  location           = "europe-west2"
  authorized_network = google_compute_network.apigee.id
  kms_key_name       = google_kms_crypto_key.apigee.id

  depends_on = [
    google_service_networking_connection.apigee,
    google_kms_crypto_key_iam_member.apigee_service_agent,
  ]
}
