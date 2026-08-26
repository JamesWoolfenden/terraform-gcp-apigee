output "organization_id" {
  value       = google_apigee_organization.main.id
  description = "ID of the Apigee organization"
}

output "instance_ids" {
  value       = { for name, instance in google_apigee_instance.main : name => instance.id }
  description = "IDs of the Apigee runtime instances, keyed by instance name"
}

output "environment_id" {
  value       = google_apigee_environment.main.id
  description = "ID of the Apigee environment"
}

output "hosts" {
  value       = { for name, instance in google_apigee_instance.main : name => instance.host }
  description = "Internal hostnames of the Apigee runtime instances, keyed by instance name"
}
