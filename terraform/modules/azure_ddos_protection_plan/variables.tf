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

# None

#--------------------------------------------------------
# Module Optional Inputs
#--------------------------------------------------------

variable "enable_telemetry" {
  description = "(Optional) Controls whether telemetry is enabled for the module. Default: true."
  type        = bool
  default     = true
}

variable "lock" {
  description = "(Optional) Controls the Resource Lock configuration for this resource. Defaults: null."
  type = object({
    kind = string
  })
  default = null
}

variable "role_assignments" {
  description = "(Optional) A map of role assignments to create on the . The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time. Default: {}"
  type = map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
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

