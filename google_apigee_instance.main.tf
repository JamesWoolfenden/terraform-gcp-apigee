resource "google_apigee_instance" "main" {
  for_each = var.instances

  name                     = each.key
  location                 = each.value.location
  org_id                   = google_apigee_organization.main.id
  disk_encryption_key_name = each.value.disk_encryption_key_name
  description              = var.description
  ip_range                 = each.value.ip_range

  timeouts {
    create = var.timeouts.create
    delete = var.timeouts.delete
  }
}
