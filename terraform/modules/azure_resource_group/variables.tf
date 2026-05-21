#--------------------------------------------------------
# Common Required Inputs
#--------------------------------------------------------

variable "region" {
  description = "Azure region where the resource should be deployed. Allowed values are 'eastus' or 'westus'."
  type        = string
  nullable    = false
}

variable "app_name" {
  type        = string
  description = "Name of the VyStar application that will be deployed."
  nullable    = false
}

variable "component_name" {
  type        = string
  description = "Name of the Azure Component that is being deployed."
  nullable    = false
}

variable "environment" {
  type        = string
  description = "Target environment abbreviation for naming."
  nullable    = false
}

variable "environment_number_suffix" {
  type        = string
  description = "Environment number suffix for naming."
  nullable    = false
}

#--------------------------------------------------------
# Module Optional Inputs
#--------------------------------------------------------

variable "enable_telemetry" {
  description = "(Optional) Controls whether or not telemetry is enabled for the module. Default: true"
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

variable "role_assignments" {
  description = "(Optional) A map of role assignments to create on the Azure Resource."
  type = map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
    principal_type                         = optional(string, null)
  }))
  default = {}
  validation {
    condition     = alltrue([for ra in var.role_assignments : ra.role_definition_id_or_name != "" && ra.principal_id != ""])
    error_message = "Each role assignment must have a role_definition_id_or_name and a principal_id."
  }
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
  description = "This is the default common tags for the entire resources."
}

variable "resource_tags" {
  type        = map(string)
  description = "(Optional) This tags which we can define specific to the resources."
  default     = {}
}

variable "custom_resource_group_name" {
  description = "(Optional) Name of an existing resource group to use. If provided, no new resource group will be created."
  type        = string
  default     = null
}
