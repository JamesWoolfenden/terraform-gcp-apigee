resource "google_kms_key_ring" "apigee" {
  name     = "apigee-keyring"
  location = "europe-west2"
}
