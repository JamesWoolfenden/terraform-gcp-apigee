variable "project_id" {
  type        = string
  description = "Project the Apigee organization is created in"

  validation {
    condition     = length(trimspace(var.project_id)) > 0
    error_message = "var.project_id must be a non-empty string"
  }
}

variable "instance_name" {
  type        = string
  description = "Name of the Apigee runtime instance"

  validation {
    condition     = can(regex("^[a-z][-a-z0-9]{0,30}$", var.instance_name))
    error_message = "var.instance_name must be lowercase and start with a letter"
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

variable "location" {
  type        = string
  description = "Region of the Apigee runtime instance"
  default     = "europe-west2"

  validation {
    condition     = length(trimspace(var.location)) > 0
    error_message = "var.location must be a non-empty string"
  }
}

variable "authorized_network" {
  type        = string
  description = "Self-link of the VPC peered with the Apigee runtime"

  validation {
    condition     = length(trimspace(var.authorized_network)) > 0
    error_message = "var.authorized_network must be a non-empty string"
  }
}

variable "ip_range" {
  type        = string
  description = "CIDR range used by the runtime instance, a /22 and a /28 separated by a comma"
  default     = null

  validation {
    condition     = var.ip_range == null || can(regex("^[0-9./,]+$", var.ip_range))
    error_message = "var.ip_range must be a comma-separated list of CIDR ranges"
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

variable "kms_key_name" {
  type        = string
  description = "Resource name of the Cloud KMS key used for the runtime database and instance disks (CMEK)"
  sensitive   = true

  validation {
    condition     = length(trimspace(var.kms_key_name)) > 0
    error_message = "var.kms_key_name must be a non-empty string"
  }
}

variable "description" {
  type        = string
  description = "Description applied to the organization, instance and environment"
  default     = "Managed by Terraform"

  validation {
    condition     = length(trimspace(var.description)) > 0
    error_message = "var.description must be a non-empty string"
  }
}
