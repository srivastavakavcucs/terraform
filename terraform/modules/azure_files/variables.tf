#--------------------------------------------------------
# Common Required Inputs
#--------------------------------------------------------

variable "region" {
  description = "The Azure region where resources will be deployed."
  type        = string
}
variable "app_name" {
  description = "The application name."
  type        = string
}

variable "environment" {
  description = "The deployment environment (e.g., dev, prod)."
  type        = string
}

variable "environment_number_suffix" {
  description = "The numeric suffix for the environment."
  type        = string
}

#--------------------------------------------------------
# Common Optional Inputs
#--------------------------------------------------------
variable "lock" {
  description = "Enable resource lock."
  type = object({
    kind = string
    name = optional(string, null)
  })
  default = null
}

variable "enable_telemetry" {
  description = "Enable telemetry reporting."
  type        = bool
  default     = false
}

variable "diagnostic_settings" {
  description = "Diagnostic settings configuration."
  type        = any
  default     = {}
}

variable "role_assignments" {
  description = "Role assignments configuration."
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
  description = "(Optional) A map of private endpoints to create on the Azure Files."
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

#--------------------------------------------------------
# Module Required Inputs
#--------------------------------------------------------

variable "account_tier" {
  description = "The storage account tier (Standard or Premium)."
  type        = string
  default     = "Standard"
}

variable "account_replication_type" {
  description = "(Required) Defines the type of replication to use for this storage account. Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS. Defaults to LRS"
  type        = string
  default     = "LRS"
}

#--------------------------------------------------------
# Module Optional Inputs
#--------------------------------------------------------

variable "large_file_share_enabled" {
  description = " (Optional) Is Large File Share Enabled?"
  type        = bool
  default     = false
}

variable "network_rules" {
  description = "Note the default value for this variable will block all public access to the storage account. If you want to disable all network rules, set this value to null."
  type        = any
  default     = {}
}

variable "access_tier" {
  description = " (Optional) Defines the access tier for BlobStorage, FileStorage and StorageV2 accounts. Valid options are Hot and Cool, defaults to Hot."
  type        = string
  default     = "Hot"
}

variable "account_kind" {
  description = " (Optional) Defines the Kind of account. Valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2. Defaults to StorageV2."
  type        = string
  default     = "StorageV2"
}

variable "managed_identities" {
  description = "(Optional) Controls the Managed Identity configuration on this resource."
  type = object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
  default = {}
}

variable "private_endpoints_manage_dns_zone_group" {
  description = "Whether to manage private DNS zone groups with this module. If set to false, you must manage private DNS zone groups externally, e.g. using Azure Policy."
  type        = bool
  default     = true
}

variable "public_network_access_enabled" {
  description = "(Optional) Specifies whether public access is permitted. Defaults to false."
  type        = bool
  default     = false
}

variable "is_hns_enabled" {
  description = "(Optional) Is Hierarchical Namespace enabled? This can be used with Azure Data Lake Storage Gen 2. Changing this forces a new resource to be created. Defaults to false."
  type        = bool
  default     = false
}

variable "azure_files_authentication" {
  description = "(Optional) Configuration block for enabling Azure Files authentication."
  type = object({
    directory_type                 = optional(string, "AADKERB")
    default_share_level_permission = optional(string, null)

    active_directory = optional(object({
      domain_guid         = string
      domain_name         = string
      domain_sid          = string
      forest_name         = string
      netbios_domain_name = string
      storage_sid         = string
    }), null)
  })

  default = null
}

variable "infrastructure_encryption_enabled" {
  description = "(Optional) Is infrastructure encryption enabled? Changing this forces a new resource to be created. Defaults to false."
  type        = bool
  default     = false
}

variable "min_tls_version" {
  description = "(Optional) The minimum supported TLS version for the storage account. Possible values are TLS1_0, TLS1_1, and TLS1_2. Defaults to TLS1_2 for new storage accounts."
  type        = string
  default     = "TLS1_2"
}

variable "shares" {
  description = "Map of Azure File Shares to create."
  type = map(object({
    access_tier      = optional(string)
    enabled_protocol = optional(string)
    metadata         = optional(map(string))
    name             = string
    quota            = number
    root_squash      = optional(string)
    signed_identifiers = optional(list(object({
      id = string
      access_policy = optional(object({
        expiry_time = string
        permission  = string
        start_time  = string
      }))
    })))
    role_assignments = optional(map(object({
      role_definition_id_or_name             = string
      principal_id                           = string
      description                            = optional(string, null)
      skip_service_principal_aad_check       = optional(bool, false)
      condition                              = optional(string, null)
      condition_version                      = optional(string, null)
      delegated_managed_identity_resource_id = optional(string, null)
    })), {})
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
  }))
  default = {}
}

variable "shared_access_key_enabled" {
  description = "(Optional) Allow shared access key based authorization"
  type        = bool
  default     = true
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
  description = "(Optional) Tags of the Azure Container Registry resource. Default: {}"
  default     = {}
}
