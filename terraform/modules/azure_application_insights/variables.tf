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

variable "workspace_id" {
  description = "The ID of the Log Analytics workspace to send data to."
  type        = string
  validation {
    condition     = length(var.workspace_id) > 0
    error_message = "Workspace ID is required and cannot be empty."
  }
}

#--------------------------------------------------------
# Common Optional Inputs
#--------------------------------------------------------

variable "enable_telemetry" {
  description = "Controls whether telemetry is enabled for the module. Defaulted to true."
  type        = bool
  default     = true
}

variable "lock" {
  description = "Controls the Resource Lock configuration for this resource."
  type = object({
    kind = string
  })
  default = null
  # TODO: Enable later when code refactor is complete
  # default = {
  #   kind = "CanNotDelete"
  # }
}

#--------------------------------------------------------
# Optional Inputs
#--------------------------------------------------------

variable "managed_identities" {
  description = "Controls the Managed Identity configuration on this resource."
  type = object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
  default = {}
}

variable "application_type" {
  description = "The type of the application."
  type        = string
  default     = "web"
  validation {
    condition     = contains(["web", "ios", "java", "phone", "MobileCenter", "other", "store"], var.application_type)
    error_message = "Application type must be one of: 'web', 'ios', 'java', 'phone', 'MobileCenter', 'other', 'store'."
  }
}

variable "daily_data_cap_in_gb" {
  description = "The daily data cap in GB. 0 means unlimited."
  type        = number
  default     = 100
}

variable "daily_data_cap_notifications_disabled" {
  description = "Disables the daily data cap notifications."
  type        = bool
  default     = false
}

variable "disable_ip_masking" {
  description = "Disables IP masking."
  type        = bool
  default     = false
}


variable "internet_ingestion_enabled" {
  description = "Enables internet ingestion."
  type        = bool
  default     = true
}

variable "internet_query_enabled" {
  description = "Enables internet query."
  type        = bool
  default     = true
}

variable "local_authentication_disabled" {
  description = "Disables local authentication."
  type        = bool
  default     = false
}


variable "retention_in_days" {
  description = "The retention period in days. 0 means unlimited."
  type        = number
  default     = 90
}

variable "sampling_percentage" {
  description = "The sampling percentage. 100 means all."
  type        = number
  default     = 100
}

variable "custom_resource_group_name" {
  description = "(Optional) Name of an existing resource group to use. If provided, no new resource group will be created."
  type        = string
  default     = null
}
#--------------------------------------------------------
# Tags
#--------------------------------------------------------

variable "common_tags" {
  type        = map(string)
  description = "Common Tags for all VyStar Azure resources."
  nullable    = false
}

variable "resource_tags" {
  type        = map(string)
  description = "This tags which we can define specific to the resources."
  default     = {}
}
