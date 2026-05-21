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
# Required Inputs
#--------------------------------------------------------

variable "tenant_id" {
  description = "The Azure tenant ID used for authenticating requests to Key Vault. You can use the azurerm_client_config data source to retrieve it."
  type        = string
}

variable "soft_delete_retention_days" {
  description = "The number of days that items should be retained for once soft-deleted"
  type        = number
}

#--------------------------------------------------------
# Module Optional Inputs
#--------------------------------------------------------

variable "sku_name" {
  description = "(Optional) The SKU name of the Key Vault. Possible values are standard and premium. Default: premium"
  type        = string
  default     = "premium"

  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "The SKU name must be either 'standard' or 'premium'."
  }
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

variable "diagnostic_settings" {
  description = "(Optional) A map of diagnostic settings to create on the Key Vault. Default: {}"
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
  description = "(Optional) This variable controls whether or not telemetry is enabled for the module. Default: true."
  type        = bool
  default     = true
}

variable "private_endpoints" {
  description = "(Optional) A map of private endpoints to create on the KeyVault. Default: {}"
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

variable "public_network_access_enabled" {
  description = "(Optional) Specifies whether public access is permitted. Default: false."
  type        = bool
  default     = false
}


variable "contacts" {
  description = "(Optional) A map of contacts for the Key Vault. Default: {}"
  type = map(object({
    email = string
    name  = optional(string, null)
    phone = optional(string, null)
  }))
  default = {}
}

variable "enabled_for_deployment" {
  description = "(Optional) Specifies whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the vault. Default: false"
  type        = bool
  default     = false
}

variable "enabled_for_disk_encryption" {
  description = "(Optional) Specifies whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys. Default: true"
  type        = bool
  default     = true
}

variable "enabled_for_template_deployment" {
  description = "(Optional) Specifies whether Azure Resource Manager is permitted to retrieve secrets from the vault. Default: false"
  type        = bool
  default     = false
}

variable "keys" {
  description = "(Optional) A map of keys to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time. Default: false"
  type = map(object({
    name     = string
    key_type = string
    key_opts = optional(list(string), ["sign", "verify"])

    key_size        = optional(number, null)
    curve           = optional(string, null)
    not_before_date = optional(string, null)
    expiration_date = optional(string, null)
    tags            = optional(map(any), null)

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

    rotation_policy = optional(object({
      automatic = optional(object({
        time_after_creation = optional(string, null)
        time_before_expiry  = optional(string, null)
      }), null)
      expire_after         = optional(string, null)
      notify_before_expiry = optional(string, null)
    }), null)
  }))
  default = {}
}

variable "legacy_access_policies" {
  description = "(Optional) A map of legacy access policies to create on the Key Vault. Default: {}"
  type = map(object({
    object_id               = string
    application_id          = optional(string, null)
    certificate_permissions = optional(set(string), [])
    key_permissions         = optional(set(string), [])
    secret_permissions      = optional(set(string), [])
    storage_permissions     = optional(set(string), [])
  }))
  default = {}
}

variable "legacy_access_policies_enabled" {
  description = "(Optional) Specifies whether legacy access policies are enabled for this Key Vault. Default: false"
  type        = bool
  default     = false
}

variable "network_acls" {
  description = "(Optional) The network ACL configuration for the Key Vault. Default: {}"
  type = object({
    bypass                     = optional(string, "None")
    default_action             = optional(string, "Deny")
    ip_rules                   = optional(list(string), [])
    virtual_network_subnet_ids = optional(list(string), [])
  })
  default = {
    bypass                     = "AzureServices"
    default_action             = "Deny"
    ip_rules                   = []
    virtual_network_subnet_ids = []
  }
}

variable "private_endpoints_manage_dns_zone_group" {
  description = "(Optional) Whether to manage private DNS zone groups with this module. If set to false, you must manage private DNS zone groups externally, e.g. using Azure Policy. Default: true."
  type        = bool
  default     = true
}

variable "purge_protection_enabled" {
  description = "(Optional) Specifies whether protection against purge is enabled for this Key Vault. Note once enabled this cannot be disabled. Default: true"
  type        = bool
  default     = true
}

variable "secrets" {
  description = "(Optional) A map of secrets to create on the Key Vault."
  type = map(object({
    name            = string
    content_type    = optional(string, null)
    tags            = optional(map(any), null)
    not_before_date = optional(string, null)
    expiration_date = optional(string, null)

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
  }))
  default = {}
}

variable "secrets_value" {
  description = "(Optional) A map of secret keys to values. Default: null."
  type        = map(string)
  default     = null
}

variable "wait_for_rbac_before_contact_operations" {
  description = "(Optional) This variable controls the amount of time to wait before performing contact operations. Default: {}"
  type = object({
    create  = optional(string, "30s")
    destroy = optional(string, "0s")
  })
  default = {}
}

variable "wait_for_rbac_before_key_operations" {
  description = "(Optional) This variable controls the amount of time to wait before performing key operations. Default: {}"
  type = object({
    create  = optional(string, "30s")
    destroy = optional(string, "0s")
  })
  default = {}
}

variable "wait_for_rbac_before_secret_operations" {
  description = "(Optional) This variable controls the amount of time to wait before performing secret operations. Default: {}"
  type = object({
    create  = optional(string, "30s")
    destroy = optional(string, "0s")
  })
  default = {}
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
  description = "This is the default common tags for the entire resources."
}

variable "resource_tags" {
  type        = map(string)
  description = "(Optional) This tags which we can define specific to the resources. Default: {}"
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
