resource "google_service_networking_connection" "apigee" {
  network                 = google_compute_network.apigee.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.apigee.name]
}
