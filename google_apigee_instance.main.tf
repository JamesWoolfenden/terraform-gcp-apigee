resource "google_apigee_instance" "main" {
  name                     = var.instance_name
  location                 = var.location
  org_id                   = google_apigee_organization.main.id
  disk_encryption_key_name = var.kms_key_name
  description              = var.description
  ip_range                 = var.ip_range
}
