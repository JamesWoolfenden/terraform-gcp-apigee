resource "google_apigee_environment" "main" {
  org_id          = google_apigee_organization.main.id
  name            = var.environment_name
  display_name    = var.environment_name
  description     = var.description
  deployment_type = var.deployment_type
  api_proxy_type  = var.api_proxy_type

  dynamic "node_config" {
    for_each = var.node_config.min_node_count == null && var.node_config.max_node_count == null ? [] : [1]

    content {
      min_node_count = var.node_config.min_node_count
      max_node_count = var.node_config.max_node_count
    }
  }
}
