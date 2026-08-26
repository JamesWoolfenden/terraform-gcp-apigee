output "organization_id" {
  value       = google_apigee_organization.main.id
  description = "ID of the Apigee organization"
}

output "instance_id" {
  value       = google_apigee_instance.main.id
  description = "ID of the Apigee runtime instance"
}

output "environment_id" {
  value       = google_apigee_environment.main.id
  description = "ID of the Apigee environment"
}

output "host" {
  value       = google_apigee_instance.main.host
  description = "Internal hostname of the Apigee runtime instance"
}
