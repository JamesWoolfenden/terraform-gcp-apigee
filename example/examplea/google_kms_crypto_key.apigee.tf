resource "google_kms_crypto_key" "apigee" {
  name            = "apigee-key"
  key_ring        = google_kms_key_ring.apigee.id
  rotation_period = "2592000s"

  lifecycle {
    prevent_destroy = true
  }
}
