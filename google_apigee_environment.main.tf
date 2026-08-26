resource "google_apigee_environment" "main" {
  org_id          = google_apigee_organization.main.id
  name            = var.environment_name
  display_name    = var.environment_name
  description     = var.description
  deployment_type = "PROXY"
  api_proxy_type  = "PROGRAMMABLE"
}
