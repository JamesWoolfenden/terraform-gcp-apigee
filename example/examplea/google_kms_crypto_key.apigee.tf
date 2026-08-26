resource "google_kms_crypto_key" "apigee" {
  name            = "apigee-key"
  key_ring        = google_kms_key_ring.apigee.id
  rotation_period = "2592000s"

  lifecycle {
    prevent_destroy = true
  }
}

# API consumer data — developers, apps, API products and API keys — is a
# distinct data plane from the runtime database, so it gets its own key rather
# than sharing one.
resource "google_kms_crypto_key" "apigee_consumer_data" {
  name            = "apigee-consumer-data-key"
  key_ring        = google_kms_key_ring.apigee.id
  rotation_period = "2592000s"

  lifecycle {
    prevent_destroy = true
  }
}
