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
# Module Optional Inputs
#--------------------------------------------------------

variable "enable_telemetry" {
  description = "(Optional) Controls whether or not telemetry is enabled for the module. Default: true"
  type        = bool
  default     = true
}

variable "bgp_route_propagation_enabled" {
  description = "(Optional) Boolean flag which controls propagation of routes learned by BGP on that route table. Default: true."
  type        = bool
  default     = true
}

variable "lock" {
  description = "(Optional) Controls the Resource Lock configuration for this resource. Default: null"
  type = object({
    kind = string
    name = optional(string, null)
  })
  default = null
}

variable "role_assignments" {
  description = "(Optional) A map of role assignments to create. Default: {}"
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
}

variable "routes" {
  description = "(Optional) A list of routes to be added to the Route Table. Default: []"
  type = list(object({
    destination_name       = string
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for r in var.routes :
      r.next_hop_type != "VirtualAppliance" ? r.next_hop_in_ip_address == null : true
    ])
    error_message = "If next_hop_type is not VirtualAppliance, next_hop_in_ip_address must be null."
  }
}

variable "subnet_name_segments" {
  type        = list(string)
  description = "(Optional) A list of the name segments of subnets to associate with the route table. Default: []"
  nullable    = false
  default     = []
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
  description = "A map of tags to common resource tags assign to the virtual network."
}

variable "resource_tags" {
  type        = map(string)
  description = "(Optional) A map of tags to assign to the virtual network. These tags are specific to the virtual network. Default: {}"
  default     = {}
}
