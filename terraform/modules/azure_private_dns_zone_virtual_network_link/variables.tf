#--------------------------------------------------------
# Common Required Inputs
#--------------------------------------------------------

variable "region" {
  description = "Azure region where the resource should be deployed. Allowed values are 'eastus' or 'westus'."
  type        = string
}

variable "app_name" {
  type        = string
  description = "Name of the VyStar application that will be deployed."
}

variable "environment" {
  type        = string
  description = "Target environment abbreviation for naming."
}

variable "environment_number_suffix" {
  type        = string
  description = "Environment number suffix for naming."
}

#--------------------------------------------------------
# Module Required Inputs
#--------------------------------------------------------

variable "private_dns_zone" {
  description = "The details of the Private DNS zone. The name of the Private DNS zone should be provided without a terminating dot."
  type = object({
    name                = string
    resource_group_name = string
  })
  nullable = false

  validation {
    condition     = var.private_dns_zone.name != null && length(var.private_dns_zone.name) > 3 && !endswith(var.private_dns_zone.name, ".")
    error_message = "The name must not be null, must be longer than 3 characters, and must not end with a dot."
  }

  validation {
    condition     = var.private_dns_zone.resource_group_name != null && length(var.private_dns_zone.resource_group_name) > 3
    error_message = "The resource_group_name must not be null and must be longer than 3 characters."
  }
}

#--------------------------------------------------------
# Module Optional Inputs
#--------------------------------------------------------

variable "registration_enabled" {
  description = "(Optional) Is auto-registration of virtual machine records in the virtual network in the Private DNS zone enabled?"
  type        = bool
  default     = true
}

variable "lock" {
  description = "(Optional) Controls the Resource Lock configuration for this resource."
  type = object({
    kind = string
  })
  default = null
}

variable "enable_telemetry" {
  description = "(Optional) Enable telemetry for the module. Defaulted to true."
  type        = bool
  default     = true
}

variable "custom_resource_group_name" {
  description = "(Optional) Name of an existing resource group to use. If provided, no new resource group will be created."
  type        = string
  default     = null
}
#---------------------------------------------------------------------------------
# Tags variables
#---------------------------------------------------------------------------------

variable "common_tags" {
  type        = map(string)
  description = "This is the default common tags for the entire resources."
}

variable "resource_tags" {
  type        = map(string)
  description = "This tags which we can define specific to the resources."
  default     = {}
}
