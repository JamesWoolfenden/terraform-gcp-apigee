variable "project_id" {
  type        = string
  description = "Project the Apigee organization is created in"

  validation {
    condition     = length(trimspace(var.project_id)) > 0
    error_message = "var.project_id must be a non-empty string"
  }
}

variable "instances" {
  type = map(object({
    location                 = string
    ip_range                 = optional(string)
    disk_encryption_key_name = string
  }))
  description = "Apigee runtime instances keyed by instance name. Apigee allows one organization per project but several instances beneath it, so add an entry per region to survive a regional outage. Each disk_encryption_key_name must be a Cloud KMS key in that entry's own location."

  validation {
    condition     = length(var.instances) > 0
    error_message = "var.instances must contain at least one instance"
  }

  validation {
    condition     = alltrue([for name, _ in var.instances : can(regex("^[a-z][-a-z0-9]{0,30}$", name))])
    error_message = "every key of var.instances must be lowercase and start with a letter"
  }

  validation {
    condition     = alltrue([for _, i in var.instances : length(trimspace(i.location)) > 0])
    error_message = "every entry of var.instances must set a non-empty location"
  }

  validation {
    condition     = alltrue([for _, i in var.instances : length(trimspace(i.disk_encryption_key_name)) > 0])
    error_message = "every entry of var.instances must set a non-empty disk_encryption_key_name"
  }

  validation {
    condition = alltrue([
      for _, i in var.instances :
      i.ip_range == null || can(regex("^([0-9]{1,3}[.]){3}[0-9]{1,3}/[0-9]{1,2}(,([0-9]{1,3}[.]){3}[0-9]{1,3}/[0-9]{1,2})?$", i.ip_range))
    ])
    error_message = "every ip_range in var.instances must be a CIDR, optionally a /22 and a /28 separated by a comma"
  }
}

variable "environment_name" {
  type        = string
  description = "Name of the Apigee environment"
  default     = "eval"

  validation {
    condition     = can(regex("^[a-z][-a-z0-9]{0,30}$", var.environment_name))
    error_message = "var.environment_name must be lowercase and start with a letter"
  }
}

variable "analytics_region" {
  type        = string
  description = "Region analytics data is stored in"
  default     = "europe-west2"

  validation {
    condition     = length(trimspace(var.analytics_region)) > 0
    error_message = "var.analytics_region must be a non-empty string"
  }
}

variable "authorized_network" {
  type        = string
  description = "Compute Engine network peered with the Apigee runtime. For a network in this project use its bare name (for example apigee-network); for a shared VPC use projects/{host-project-id}/{region}/networks/{network-name}. Note this is neither the self-link nor google_compute_network.id, which renders projects/*/global/networks/* and matches neither accepted form."

  validation {
    condition = (
      can(regex("^[a-z]([-a-z0-9]*[a-z0-9])?$", var.authorized_network)) ||
      can(regex("^projects/[^/]+/[^/]+/networks/[^/]+$", var.authorized_network))
    )
    error_message = "var.authorized_network must be a bare network name, or projects/{host-project-id}/{region}/networks/{network-name} for a shared VPC"
  }
}

variable "billing_type" {
  type        = string
  description = "Billing type of the Apigee organization"
  default     = "PAYG"

  validation {
    condition     = contains(["EVALUATION", "PAYG", "SUBSCRIPTION"], var.billing_type)
    error_message = "var.billing_type must be EVALUATION, PAYG or SUBSCRIPTION"
  }
}

variable "encryption" {
  type = object({
    runtime_database_key_name  = string
    api_consumer_data_key_name = optional(string)
    api_consumer_data_location = optional(string)
    control_plane_key_name     = optional(string)
  })
  description = "Cloud KMS keys for the organization's three data planes. runtime_database_key_name is required and regional to analytics_region. api_consumer_data_key_name covers developers, apps, API products and API keys, and must match api_consumer_data_location. control_plane_key_name covers proxy bundles and configuration, which are stored multi-regionally, so that key must live in a multi-region KMS location such as europe rather than europe-west2. Runtime instance disks are keyed separately, per entry in var.instances."
  sensitive   = true

  validation {
    condition     = length(trimspace(var.encryption.runtime_database_key_name)) > 0
    error_message = "encryption.runtime_database_key_name must be a non-empty string"
  }

  validation {
    condition = alltrue([
      for key in [var.encryption.api_consumer_data_key_name, var.encryption.control_plane_key_name] :
      key == null || can(regex("^projects/[^/]+/locations/[^/]+/keyRings/[^/]+/cryptoKeys/[^/]+$", coalesce(key, "x")))
    ])
    error_message = "encryption key names must be projects/*/locations/*/keyRings/*/cryptoKeys/*"
  }

  validation {
    condition     = var.encryption.api_consumer_data_key_name == null || var.encryption.api_consumer_data_location != null
    error_message = "encryption.api_consumer_data_location must be set whenever api_consumer_data_key_name is"
  }
}

variable "timeouts" {
  type = object({
    create = optional(string, "60m")
    delete = optional(string, "60m")
  })
  description = "Create and delete timeouts for the organization and its instances. Apigee provisioning routinely takes 30-45 minutes."
  default     = {}

  validation {
    condition = alltrue([
      for duration in [var.timeouts.create, var.timeouts.delete] :
      can(regex("^[0-9]+[smh]$", duration))
    ])
    error_message = "timeouts.create and timeouts.delete must be Go durations such as 60m"
  }
}

variable "node_config" {
  type = object({
    min_node_count = optional(number)
    max_node_count = optional(number)
  })
  description = "Gateway node autoscaling bounds for the environment. PAYG and SUBSCRIPTION organizations bill per node-hour, so min_node_count is the cost floor and max_node_count bounds spend during a spike. Leave both null to use Apigee's own defaults."
  default     = {}

  validation {
    condition = alltrue([
      for count in [var.node_config.min_node_count, var.node_config.max_node_count] :
      count == null || try(count >= 1, false)
    ])
    error_message = "node_config counts must be at least 1"
  }

  validation {
    condition     = var.node_config.min_node_count == null || var.node_config.max_node_count == null || try(var.node_config.max_node_count >= var.node_config.min_node_count, false)
    error_message = "node_config.max_node_count must be greater than or equal to min_node_count"
  }
}

variable "retention" {
  type        = string
  description = "Soft-delete retention applied when the organization is deleted. Apigee allows one organization per project, so the default seven-day retention blocks re-creating one in the same project for a week; MINIMUM shortens that to 24 hours for eval and CI stacks."
  default     = null

  validation {
    condition     = var.retention == null || contains(["DELETION_RETENTION_UNSPECIFIED", "MINIMUM"], coalesce(var.retention, "null"))
    error_message = "var.retention must be DELETION_RETENTION_UNSPECIFIED or MINIMUM"
  }
}

variable "deployment_type" {
  type        = string
  description = "Deployment type of the Apigee environment"
  default     = "PROXY"

  validation {
    condition     = contains(["PROXY", "ARCHIVE"], var.deployment_type)
    error_message = "var.deployment_type must be PROXY or ARCHIVE"
  }
}

variable "api_proxy_type" {
  type        = string
  description = "API proxy type of the Apigee environment"
  default     = "PROGRAMMABLE"

  validation {
    condition     = contains(["PROGRAMMABLE", "CONFIGURABLE"], var.api_proxy_type)
    error_message = "var.api_proxy_type must be PROGRAMMABLE or CONFIGURABLE"
  }
}

variable "description" {
  type        = string
  description = "Description applied to the organization, instances and environment"
  default     = "Managed by Terraform"

  validation {
    condition     = length(trimspace(var.description)) > 0
    error_message = "var.description must be a non-empty string"
  }
}
