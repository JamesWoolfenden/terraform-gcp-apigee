resource "google_kms_crypto_key_iam_member" "apigee_service_agent" {
  crypto_key_id = google_kms_crypto_key.apigee.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${google_project_service_identity.apigee.email}"
}

resource "google_kms_crypto_key_iam_member" "apigee_service_agent_consumer_data" {
  crypto_key_id = google_kms_crypto_key.apigee_consumer_data.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${google_project_service_identity.apigee.email}"
}
