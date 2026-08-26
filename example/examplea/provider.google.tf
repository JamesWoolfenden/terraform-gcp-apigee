# holden:ignore:HLD_GCP_059 — per-repo WIF SA with attribute.repository scoping
# provides equivalent least-privilege without impersonation.
#
# project is deliberately not set here: wiring it from data.google_project.current
# creates a provider/data-source dependency cycle, so the project still comes from
# the ambient GOOGLE_PROJECT / ADC configuration.
provider "google" {
  region = local.region

  default_labels = {
    "owner"    = "holden"
    module     = "terraform-gcp-apigee"
    created_by = "terraform"
  }
}
