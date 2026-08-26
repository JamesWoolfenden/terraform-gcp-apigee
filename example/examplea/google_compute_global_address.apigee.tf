# holden:ignore:HLD_GCP_340: sample drives an example only
resource "google_compute_global_address" "apigee" {
  name          = "apigee-psa-range"
  address_type  = "INTERNAL"
  purpose       = "VPC_PEERING"
  prefix_length = 21
  network       = google_compute_network.apigee.id
}
