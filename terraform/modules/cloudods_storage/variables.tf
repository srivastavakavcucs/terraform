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
  description = "(Optional) A map of private endpoints to create on the blob storage."
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
# Storage Account Configuration
#--------------------------------------------------------

variable "account_tier" {
  description = "The storage account tier (Standard or Premium)."
  type        = string
  default     = "Standard"
}

variable "account_replication_type" {
  description = "Defines the type of replication to use for this storage account. Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS."
  type        = string
  default     = "GRS"
}

variable "access_tier" {
  description = "Defines the access tier for blob storage. Valid options are Hot and Cool."
  type        = string
  default     = "Hot"
}

variable "storage_account_suffix" {
  description = "Suffix for storage account naming (e.g., blb001, blb002)."
  type        = string
  default     = "blb001"
}

variable "network_rules" {
  description = "Network rules for the storage account. Default blocks all public access."
  type        = any
  default     = {}
}

variable "managed_identities" {
  description = "(Optional) Controls the Managed Identity configuration on this resource."
  type = object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
  default = {}
}

variable "public_network_access_enabled" {
  description = "(Optional) Specifies whether public access is permitted. Defaults to false."
  type        = bool
  default     = false
}

variable "shared_access_key_enabled" {
  description = "(Optional) Allow shared access key based authorization."
  type        = bool
  default     = true
}

variable "infrastructure_encryption_enabled" {
  description = "(Optional) Is infrastructure encryption enabled?"
  type        = bool
  default     = false
}

variable "min_tls_version" {
  description = "(Optional) The minimum supported TLS version. Valid options: TLS1_0, TLS1_1, TLS1_2."
  type        = string
  default     = "TLS1_2"
}

variable "private_endpoints_manage_dns_zone_group" {
  description = "Whether to manage private DNS zone groups with this module."
  type        = bool
  default     = true
}

#--------------------------------------------------------
# Blob Container Configuration
#--------------------------------------------------------

variable "landing_container_name" {
  description = "Name of the landing blob container for CFM file drops."
  type        = string
  default     = "landing"

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9-]*[a-z0-9])?$", var.landing_container_name))
    error_message = "Container name must be lowercase, alphanumeric with hyphens, 3-63 characters."
  }
}

variable "landing_container_access_type" {
  description = "Access type for landing container. Valid values: Private, Blob, Container."
  type        = string
  default     = "Private"

  validation {
    condition     = contains(["Private", "Blob", "Container"], var.landing_container_access_type)
    error_message = "Access type must be Private, Blob, or Container."
  }
}

variable "configuration_container_name" {
  description = "Name of the configuration blob container for pipeline config files."
  type        = string
  default     = "configuration"

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9-]*[a-z0-9])?$", var.configuration_container_name))
    error_message = "Container name must be lowercase, alphanumeric with hyphens, 3-63 characters."
  }
}

variable "configuration_container_access_type" {
  description = "Access type for configuration container. Valid values: Private, Blob, Container."
  type        = string
  default     = "Private"

  validation {
    condition     = contains(["Private", "Blob", "Container"], var.configuration_container_access_type)
    error_message = "Access type must be Private, Blob, or Container."
  }
}

#--------------------------------------------------------
# Blob Versioning & Soft Delete (ADR-014)
#--------------------------------------------------------

variable "delete_retention_days" {
  description = "Number of days to retain soft-deleted blobs (0-365). Set to 0 to disable."
  type        = number
  default     = 7

  validation {
    condition     = var.delete_retention_days >= 0 && var.delete_retention_days <= 365
    error_message = "Delete retention days must be between 0 and 365."
  }
}

variable "container_delete_retention_days" {
  description = "Number of days to retain soft-deleted containers (0-365). Set to 0 to disable."
  type        = number
  default     = 7

  validation {
    condition     = var.container_delete_retention_days >= 0 && var.container_delete_retention_days <= 365
    error_message = "Container delete retention days must be between 0 and 365."
  }
}

#--------------------------------------------------------
# Key Vault Configuration
#--------------------------------------------------------

variable "key_vault_id" {
  description = "Resource ID of the Key Vault where secrets will be stored."
  type        = string

  validation {
    condition     = can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft.KeyVault/vaults/[^/]+$", var.key_vault_id))
    error_message = "Key Vault ID must be a valid resource ID."
  }
}

variable "key_vault_secret_name" {
  description = "Name of the Key Vault secret for storage account connection string (AzureWebJobsStorage)."
  type        = string
  default     = "AzureWebJobsStorage"

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{1,127}$", var.key_vault_secret_name))
    error_message = "Secret name must be 1-127 characters, alphanumeric and hyphens only."
  }
}

#--------------------------------------------------------
# Tags
#--------------------------------------------------------

variable "common_tags" {
  type        = map(string)
  description = "Common Tags for all Azure resources."
  nullable    = false
}

variable "resource_tags" {
  type        = map(string)
  description = "(Optional) Tags specific to the CloudODS Storage resource."
  default     = {}
}
