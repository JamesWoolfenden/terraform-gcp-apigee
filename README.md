# terraform-gcp-apigee

[![Build Status](https://github.com/JamesWoolfenden/terraform-gcp-apigee/workflows/Verify/badge.svg?branch=master)](https://github.com/JamesWoolfenden/terraform-gcp-apigee)
[![Latest Release](https://img.shields.io/github/release/terraform-gcp-apigee.svg)](https://github.com/JamesWoolfenden/terraform-gcp-apigee/releases/latest)
[![GitHub tag (latest SemVer)](https://img.shields.io/github/tag/JamesWoolfenden/terraform-gcp-apigee.svg?label=latest)](https://github.com/JamesWoolfenden/terraform-gcp-apigee/releases/latest)
![Terraform Version](https://img.shields.io/badge/tf-%3E%3D1.5.0-blue.svg)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)

Terraform module for an Apigee X organization, runtime instance and
environment, with the runtime database and instance disks encrypted by a
customer-managed key. Exercises holden's `google_apigee_organization` and
`google_apigee_instance` policies.

## Usage

Add **module.apigee.tf** to your code:-

```terraform
module "apigee" {
  source             = "jameswoolfenden/apigee/gcp"
  version            = "0.0.1"
  project_id         = data.google_project.current.project_id
  environment_name   = "eval"
  analytics_region   = local.region
  authorized_network = google_compute_network.apigee.name

  encryption = {
    runtime_database_key_name  = google_kms_crypto_key.apigee.id
    api_consumer_data_key_name = google_kms_crypto_key.apigee_consumer_data.id
    api_consumer_data_location = local.region
  }

  instances = {
    "example-instance" = {
      location                 = local.region
      disk_encryption_key_name = google_kms_crypto_key.apigee.id
    }
  }
}
```

`instances` is a map keyed by instance name. Apigee allows one organization per
project but several runtime instances beneath it, so add an entry per region to
survive a regional outage. Each entry's `disk_encryption_key_name` must be a
Cloud KMS key in that entry's own `location`.

`encryption` covers the organization's three data planes, which are separate
from the per-instance disk keys above:

| Field | Covers | Key location |
| ----- | ------ | ------------ |
| `runtime_database_key_name` | Analytics, key management and cached credentials | Regional, matching `analytics_region` |
| `api_consumer_data_key_name` | Developers, apps, API products and API keys | Regional, matching `api_consumer_data_location` |
| `control_plane_key_name` | Proxy bundles and configuration | Multi-region (`europe`, not `europe-west2`) |

Only `runtime_database_key_name` is required. Apigee mandates the other two for
US/EU regions when `billing_type` is `SUBSCRIPTION`; leaving either null falls
back to a Google-managed key for that plane.

Set `retention = "MINIMUM"` on disposable eval and CI stacks. Apigee soft-deletes
an organization for seven days by default, and because there can only be one per
project, a `destroy` followed by a re-apply is blocked for that whole week.

`node_config` bounds gateway node autoscaling (`min_node_count` /
`max_node_count`), and `timeouts` sets `create` / `delete` durations, both
defaulting to `60m`.

`instances` is a map keyed by instance name. Apigee allows one organization per
project but several runtime instances beneath it, so add an entry per region to
survive a regional outage. Each entry's `disk_encryption_key_name` must be a
Cloud KMS key in that entry's own `location`; the organization's
`runtime_database_encryption_key_name` is separate and regional to
`analytics_region`.

Set `retention = "MINIMUM"` on disposable eval and CI stacks. Apigee soft-deletes
an organization for seven days by default, and because there can only be one per
project, a `destroy` followed by a re-apply is blocked for that whole week.

Apigee X peers with the authorized network, so that network needs private
services access with a `/21` reserved range before the organization is
created (Apigee consumes a /22 plus a /28 per runtime instance; reserve a /20
if you plan a second instance). The KMS key must be in the same region as the
runtime instance, and the Apigee service agent needs
`roles/cloudkms.cryptoKeyEncrypterDecrypter` on it.

`authorized_network` takes the bare network name for a network in the same
project, or `projects/{host-project-id}/{region}/networks/{network-name}` for a
shared VPC. It is deliberately not `google_compute_network.id` — that renders
`projects/*/global/networks/*`, which matches neither accepted form.

An Apigee organization is one per project and cannot be renamed or moved. It
also takes 30-45 minutes to provision, so plan timeouts accordingly.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [google_apigee_environment.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/apigee_environment) | resource |
| [google_apigee_instance.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/apigee_instance) | resource |
| [google_apigee_instance_attachment.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/apigee_instance_attachment) | resource |
| [google_apigee_organization.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/apigee_organization) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_analytics_region"></a> [analytics\_region](#input\_analytics\_region) | Region analytics data is stored in | `string` | `"europe-west2"` | no |
| <a name="input_api_proxy_type"></a> [api\_proxy\_type](#input\_api\_proxy\_type) | API proxy type of the Apigee environment | `string` | `"PROGRAMMABLE"` | no |
| <a name="input_authorized_network"></a> [authorized\_network](#input\_authorized\_network) | Compute Engine network peered with the Apigee runtime. For a network in this project use its bare name (for example apigee-network); for a shared VPC use projects/{host-project-id}/{region}/networks/{network-name}. Note this is neither the self-link nor google\_compute\_network.id, which renders projects/*/global/networks/* and matches neither accepted form. | `string` | n/a | yes |
| <a name="input_billing_type"></a> [billing\_type](#input\_billing\_type) | Billing type of the Apigee organization | `string` | `"PAYG"` | no |
| <a name="input_deployment_type"></a> [deployment\_type](#input\_deployment\_type) | Deployment type of the Apigee environment | `string` | `"PROXY"` | no |
| <a name="input_description"></a> [description](#input\_description) | Description applied to the organization, instances and environment | `string` | `"Managed by Terraform"` | no |
| <a name="input_encryption"></a> [encryption](#input\_encryption) | Cloud KMS keys for the organization's three data planes. runtime\_database\_key\_name is required and regional to analytics\_region. api\_consumer\_data\_key\_name covers developers, apps, API products and API keys, and must match api\_consumer\_data\_location. control\_plane\_key\_name covers proxy bundles and configuration, which are stored multi-regionally, so that key must live in a multi-region KMS location such as europe rather than europe-west2. Runtime instance disks are keyed separately, per entry in var.instances. | <pre>object({<br/>    runtime_database_key_name  = string<br/>    api_consumer_data_key_name = optional(string)<br/>    api_consumer_data_location = optional(string)<br/>    control_plane_key_name     = optional(string)<br/>  })</pre> | n/a | yes |
| <a name="input_environment_name"></a> [environment\_name](#input\_environment\_name) | Name of the Apigee environment | `string` | `"eval"` | no |
| <a name="input_instances"></a> [instances](#input\_instances) | Apigee runtime instances keyed by instance name. Apigee allows one organization per project but several instances beneath it, so add an entry per region to survive a regional outage. Each disk\_encryption\_key\_name must be a Cloud KMS key in that entry's own location. | <pre>map(object({<br/>    location                 = string<br/>    ip_range                 = optional(string)<br/>    disk_encryption_key_name = string<br/>  }))</pre> | n/a | yes |
| <a name="input_node_config"></a> [node\_config](#input\_node\_config) | Gateway node autoscaling bounds for the environment. PAYG and SUBSCRIPTION organizations bill per node-hour, so min\_node\_count is the cost floor and max\_node\_count bounds spend during a spike. Leave both null to use Apigee's own defaults. | <pre>object({<br/>    min_node_count = optional(number)<br/>    max_node_count = optional(number)<br/>  })</pre> | `{}` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project the Apigee organization is created in | `string` | n/a | yes |
| <a name="input_retention"></a> [retention](#input\_retention) | Soft-delete retention applied when the organization is deleted. Apigee allows one organization per project, so the default seven-day retention blocks re-creating one in the same project for a week; MINIMUM shortens that to 24 hours for eval and CI stacks. | `string` | `null` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Create and delete timeouts for the organization and its instances. Apigee provisioning routinely takes 30-45 minutes. | <pre>object({<br/>    create = optional(string, "60m")<br/>    delete = optional(string, "60m")<br/>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_environment_id"></a> [environment\_id](#output\_environment\_id) | ID of the Apigee environment |
| <a name="output_hosts"></a> [hosts](#output\_hosts) | Internal hostnames of the Apigee runtime instances, keyed by instance name |
| <a name="output_instance_ids"></a> [instance\_ids](#output\_instance\_ids) | IDs of the Apigee runtime instances, keyed by instance name |
| <a name="output_organization_id"></a> [organization\_id](#output\_organization\_id) | ID of the Apigee organization |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Help

**Got a question?**

File a GitHub [issue](https://github.com/JamesWoolfenden/terraform-gcp-apigee/issues).

## Copyrights

Copyright © 2019-2026 [Jim Woolfenden](https://github.com/JamesWoolfenden)

## License

See [LICENSE](LICENSE) for full details.


<!-- BEGINNING OF PRE-COMMIT-PIKE DOCS HOOK -->
The Terraform resource required is:

```golang
# apply role
resource "google_project_iam_custom_role" "terraform_pike" {
  project     = "pike-477416"
  role_id     = "terraform_pike"
  title       = "terraform_pike"
  description = "A user with least privileges"
  permissions = [
    "apigee.instanceattachments.create",
    "apigee.instanceattachments.delete",
    "apigee.instanceattachments.get",
    "apigee.instances.create",
    "apigee.instances.delete",
    "apigee.instances.get",
    "apigee.instances.update",
    "apigee.operations.get",
    "apigee.organizations.create",
    "apigee.organizations.delete",
    "apigee.organizations.get",
    "apigee.organizations.update"
  ]
}

# plan role
resource "google_project_iam_custom_role" "terraform_pike_plan" {
  project     = "pike-477416"
  role_id     = "terraform_pike_plan"
  title       = "terraform_pike_plan"
  description = "A user with least privileges"
  permissions = [
    "apigee.instanceattachments.get",
    "apigee.instances.get",
    "apigee.operations.get",
    "apigee.organizations.get"
  ]
}


```
<!-- END OF PRE-COMMIT-PIKE DOCS HOOK -->
