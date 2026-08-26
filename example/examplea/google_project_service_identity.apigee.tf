resource "google_project_service_identity" "apigee" {
  provider = google-beta
  service  = "apigee.googleapis.com"

  depends_on = [google_project_service.apigee]
}
