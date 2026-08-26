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
  instance_name      = "example-instance"
  environment_name   = "eval"
  analytics_region   = "europe-west2"
  location           = "europe-west2"
  authorized_network = google_compute_network.apigee.id
  kms_key_name       = google_kms_crypto_key.apigee.id
}
```

Apigee X peers with the authorized network, so that network needs private
services access with a `/16` (or larger) reserved range before the
organization is created. The KMS key must be in the same region as the runtime
instance, and the Apigee service agent needs
`roles/cloudkms.cryptoKeyEncrypterDecrypter` on it.

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
| <a name="input_authorized_network"></a> [authorized\_network](#input\_authorized\_network) | Self-link of the VPC peered with the Apigee runtime | `string` | n/a | yes |
| <a name="input_billing_type"></a> [billing\_type](#input\_billing\_type) | Billing type of the Apigee organization | `string` | `"PAYG"` | no |
| <a name="input_description"></a> [description](#input\_description) | Description applied to the organization, instance and environment | `string` | `"Managed by Terraform"` | no |
| <a name="input_environment_name"></a> [environment\_name](#input\_environment\_name) | Name of the Apigee environment | `string` | `"eval"` | no |
| <a name="input_instance_name"></a> [instance\_name](#input\_instance\_name) | Name of the Apigee runtime instance | `string` | n/a | yes |
| <a name="input_ip_range"></a> [ip\_range](#input\_ip\_range) | CIDR range used by the runtime instance, a /22 and a /28 separated by a comma | `string` | `null` | no |
| <a name="input_kms_key_name"></a> [kms\_key\_name](#input\_kms\_key\_name) | Resource name of the Cloud KMS key used for the runtime database and instance disks (CMEK) | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Region of the Apigee runtime instance | `string` | `"europe-west2"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project the Apigee organization is created in | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_environment_id"></a> [environment\_id](#output\_environment\_id) | ID of the Apigee environment |
| <a name="output_host"></a> [host](#output\_host) | Internal hostname of the Apigee runtime instance |
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | ID of the Apigee runtime instance |
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
