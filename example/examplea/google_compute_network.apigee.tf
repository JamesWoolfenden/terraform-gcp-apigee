# holden:ignore:HLD_GCP_094: sample drives an example only
# holden:ignore:HLD_GCP_303: sample drives an example only
# holden:ignore:HLD_GCP_093: sample drives an example only
resource "google_compute_network" "apigee" {
  name                    = "apigee-network"
  auto_create_subnetworks = false
}
