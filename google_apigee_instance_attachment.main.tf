resource "google_apigee_instance_attachment" "main" {
  instance_id = google_apigee_instance.main.id
  environment = google_apigee_environment.main.name
}
