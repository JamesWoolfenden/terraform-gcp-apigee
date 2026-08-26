resource "google_apigee_instance_attachment" "main" {
  for_each = var.instances

  instance_id = google_apigee_instance.main[each.key].id
  environment = google_apigee_environment.main.name
}
