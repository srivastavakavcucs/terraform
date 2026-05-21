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
# Tags
#--------------------------------------------------------

variable "common_tags" {
  type        = map(string)
  description = "Common Tags for all VyStar Azure resources."
  nullable    = false
}

#--------------------------------------------------------
# Module Required Inputs
#--------------------------------------------------------

variable "os_type" {
  description = "The operating system type for the Function App. Valid values: 'Linux' or 'Windows'."
  type        = string

  validation {
    condition     = contains(["Linux", "Windows"], var.os_type)
    error_message = "os_type must be either 'Linux' or 'Windows'."
  }
}

variable "service_plan_id" {
  description = "The resource ID of the App Service Plan where this Function App will be deployed."
  type        = string

  validation {
    condition     = can(regex("^/subscriptions/[a-f0-9-]+/resourceGroups/.+/providers/Microsoft.Web/serverfarms/.+$", var.service_plan_id))
    error_message = "service_plan_id must be a valid App Service Plan resource ID."
  }
}

variable "storage_account_name" {
  description = "The name of the Storage Account required by the Function App for internal operations."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "storage_account_name must be 3-24 characters, lowercase letters and numbers only."
  }
}

variable "storage_account_access_key" {
  description = "The access key for the Storage Account. This is required for Function App operation."
  type        = string
  sensitive   = true
}

variable "runtime" {
  description = "The runtime stack for the Function App. Valid values: 'dotnet', 'dotnet-isolated', 'node', 'python', 'java', 'powershell', 'custom'."
  type        = string

  validation {
    condition     = contains(["dotnet", "dotnet-isolated", "node", "python", "java", "powershell", "custom"], var.runtime)
    error_message = "runtime must be one of: dotnet, dotnet-isolated, node, python, java, powershell, custom."
  }
}

variable "runtime_version" {
  description = "The version of the runtime. Examples: '8.0' (dotnet), '20' (node), '3.11' (python), '11' (java), '7.4' (powershell)."
  type        = string
}

#--------------------------------------------------------
# Module Optional Inputs
#--------------------------------------------------------

variable "managed_identities" {
  description = "(Optional) Controls the Managed Identity configuration on this resource."
  type = object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
  default = {}
}

variable "app_settings" {
  description = "(Optional) A map of application settings for the Function App."
  type        = map(string)
  default     = {}
}

variable "enable_telemetry" {
  description = "(Optional) Enable telemetry for the Function App module. Default: true."
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

variable "diagnostic_settings" {
  description = "(Optional) A map of diagnostic settings to create on the resource group managed by this module. Default: {}"
  type = map(object({
    name                                     = optional(string, null)
    log_categories                           = optional(set(string), [])
    log_groups                               = optional(set(string), ["allLogs"])
    metric_categories                        = optional(set(string), ["AllMetrics"])
    log_analytics_destination_type           = optional(string, "Dedicated")
    workspace_resource_id                    = optional(string, null)
    storage_account_resource_id              = optional(string, null)
    event_hub_authorization_rule_resource_id = optional(string, null)
    event_hub_name                           = optional(string, null)
    marketplace_partner_resource_id          = optional(string, null)
  }))
  default = {}
}

variable "role_assignments" {
  description = "(Optional) A map of role assignments to create on the resource group managed by this module. Default: {}"
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

variable "private_endpoints" {
  description = "(Optional) A map of private endpoints to create on the Function App. Default: {}"
  type = map(object({
    role_assignments = optional(map(object({
      role_definition_id_or_name             = string
      principal_id                           = string
      description                            = optional(string, null)
      skip_service_principal_aad_check       = optional(bool, false)
      condition                              = optional(string, null)
      condition_version                      = optional(string, null)
      delegated_managed_identity_resource_id = optional(string, null)
      principal_type                         = optional(string, null)
    })), {})
    lock = optional(object({
      kind = string
      name = optional(string, null)
    }), null)
    tags                                 = optional(map(string), null)
    subresource_name                     = string
    private_endpoint_subnet_name_segment = string
    private_dns_zones = list(object({
      name                = string
      resource_group_name = string
    }))
    application_security_group_associations = optional(map(string), {})
    private_service_connection_name         = optional(string, null)
    network_interface_name                  = optional(string, null)
    ip_configurations = optional(map(object({
      name               = string
      private_ip_address = string
    })), {})
  }))
  default = {}
}

variable "resource_tags" {
  type        = map(string)
  description = "(Optional) Tags to be applied to the Function App resource. Default: {}"
  default     = {}
}

variable "custom_resource_group_name" {
  description = "(Optional) Name of an existing resource group to use. If provided, no new resource group will be created."
  type        = string
  default     = null
}

variable "custom_vnet_name" {
  description = "(Optional) Custom VNet name. If not set, the default naming convention will be used."
  type        = string
  default     = ""
}

variable "custom_vnet_resource_group_name" {
  description = "(Optional) Custom VNet resource group name. If not set, the default naming convention will be used."
  type        = string
  default     = ""
}
