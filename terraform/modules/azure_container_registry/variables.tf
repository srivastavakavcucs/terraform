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

variable "sku" {
  description = "The SKU name of the Container Registry. Possible values are 'Basic', 'Standard', or 'Premium'. Default is 'Premium'."
  type        = string
  default     = "Premium"
  validation {
    condition     = var.sku == "Basic" || var.sku == "Standard" || var.sku == "Premium"
    error_message = "The sku variable must be either 'Basic', 'Standard', or 'Premium'."
  }
}

#--------------------------------------------------------
# Optional Inputs
#--------------------------------------------------------

variable "admin_enabled" {
  description = "(Optional) Specifies whether the admin user is enabled. Defaults to false."
  type        = bool
  default     = false
}

variable "anonymous_pull_enabled" {
  description = "(Optional) Specifies whether anonymous pull access is allowed. Requires Standard or Premium SKU. Defaults to false."
  type        = bool
  default     = false
}

variable "customer_managed_key" {
  description = "(Optional) Controls the Customer managed key configuration on this resource. Defaults to null."
  type = object({
    key_vault_resource_id = string
    key_name              = string
    key_version           = optional(string, null)
    user_assigned_identity = optional(object({
      resource_id = string
    }), null)
  })
  default = null
}

variable "data_endpoint_enabled" {
  description = "(Optional) Specifies whether to enable dedicated data endpoints. Requires Premium SKU. Defaults to false."
  type        = bool
  default     = false
}

variable "diagnostic_settings" {
  description = "(Optional) A map of diagnostic settings to create on the Container Registry. Defaults to an empty map."
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

variable "enable_telemetry" {
  description = "(Optional) Controls whether telemetry is enabled for the module. Defaulted to true."
  type        = bool
  default     = true
}

variable "enable_trust_policy" {
  description = "(Optional) Specifies whether trust policy is enabled for this Container Registry. Defaulted to false."
  type        = bool
  default     = false
}

variable "export_policy_enabled" {
  description = "(Optional) Specifies whether export policy is enabled. Defaults to true. Set to false if public network access is disabled. Defaults to true."
  type        = bool
  default     = true
}

variable "georeplications" {
  description = "(Optional) A list of geo-replication configurations for the Container Registry. Defaults to and empty list."
  type = list(object({
    location                  = string
    regional_endpoint_enabled = optional(bool, true)
    zone_redundancy_enabled   = optional(bool, true)
    tags                      = optional(map(any), null)
  }))
  default = []
}

variable "lock" {
  description = "(Optional) Controls the Resource Lock configuration for this resource."
  type = object({
    kind = string
  })
  default = null
  # TODO: Enable later when code refactor is complete
  # default = {
  #   kind = "CanNotDelete"
  # }
}

variable "managed_identities" {
  description = "(Optional) Controls the Managed Identity configuration on this resource."
  type = object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
  default = {}
}

variable "network_rule_bypass_option" {
  description = "(Optional) Specifies whether to allow trusted Azure services access to a network-restricted Container Registry. Defaults to 'None'."
  type        = string
  default     = "None"
}

variable "network_rule_set" {
  description = "(Optional) The network rule set configuration for the Container Registry. Requires Premium SKU. Defaults to null."
  type = object({
    default_action = optional(string, "Deny")
    ip_rule = optional(list(object({
      action   = optional(string, "Allow")
      ip_range = string
    })), [])
  })
  default = null
}

variable "private_endpoints" {
  description = "(Optional) A map of private endpoints to create on the Container Registry."
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

variable "private_endpoints_manage_dns_zone_group" {
  description = "(Optional) Whether to manage private DNS zone groups with this module. Set to false if managing DNS externally. Default: true."
  type        = bool
  default     = true
}

variable "public_network_access_enabled" {
  description = "(Optional) Specifies whether public access is permitted. Defaults to false."
  type        = bool
  default     = false
}

variable "quarantine_policy_enabled" {
  description = "(Optional) Specifies whether the quarantine policy is enabled. Defaults to false."
  type        = bool
  default     = false
}

variable "retention_policy_in_days" {
  description = "(Optional) If enabled, the retention policy will purge untagged manifests after the specified number of days. Defaults to 90 days."
  type        = number
  default     = 90
}

variable "role_assignments" {
  description = "(Optional) A map of role assignments to create on the Container Registry."
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

variable "zone_redundancy_enabled" {
  description = "(Optional) Specifies whether zone redundancy is enabled. Modifying this forces a new resource to be created. Default: true"
  type        = bool
  default     = true
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
  description = "(Optional) Tags of the Azure Container Registry resource. Defaults to an empty map."
  default     = {}
}
