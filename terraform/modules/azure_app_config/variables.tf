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

variable "tenant_id" {
  description = "The Azure tenant ID used for authenticating requests to Key Vault. You can use the azurerm_client_config data source to retrieve it."
  type        = string
}

#--------------------------------------------------------
# Module Optional Inputs
#--------------------------------------------------------

variable "key_type" {
  description = "(Required) Specifies the Key Type to use for this Key Vault Key.Possible values are EC (Elliptic Curve), EC-HSM, RSA and RSA-HSM"
  type        = string
}

variable "key_size" {
  description = "(Optional) Specifies the Size of the RSA key to create in bytes. For example, 1024 or 2048. Note: This field is required if key_type is RSA or RSA-HSM"
  type        = number

}

variable "key_opts" {
  description = "(Required) A list of JSON web key operations. Possible values include: decrypt, encrypt, sign, unwrapKey, verify and wrapKey. Please note these values are case sensitive."
  type        = list(string)
}

variable "lock" {
  description = "(Optional) Controls the Resource Lock configuration for this resource. Defaults: null."
  type = object({
    kind = string
  })
  default = null
}

variable "enable_telemetry" {
  description = "(Optional) Enable telemetry for the module. Defaults: true."
  type        = bool
  default     = true
}

variable "sku_name" {
  description = "(Optional) The SKU Name for the App config. Possible values are free, standard, and premium. Defaults: standard."
  type        = string
  default     = "standard"
  validation {
    condition     = contains(["free", "standard", "premium"], var.sku_name)
    error_message = "SKU name must be 'free', 'standard', or 'premium'."
  }
}

variable "local_auth_enabled" {
  description = "(Optional) Is local authentication using access keys enabled for this App Configuration store? Defaults: false."
  type        = bool
  default     = false
}

variable "soft_delete_retention_days" {
  description = "(Optional) The number of days that items should be retained for once soft-deleted.This field only works for standard sku.Value must be between 1 and 7.Defaults: 7"
  type        = number
  default     = 7

  validation {
    condition     = var.soft_delete_retention_days >= 1 && var.soft_delete_retention_days <= 7
    error_message = "The soft delete retention days must be between 1 and 7."
  }
}

variable "purge_protection_enabled" {
  description = "(Optional) Is purge protection enabled for this App Configuration store? This field only works for standard sku. Defaults: false."
  type        = bool
  default     = false
}

variable "public_network_access" {
  description = "(Optional) The public network access setting for this App Configuration store. Value must be \"Enabled\" or \"Disabled\".Defaults: Disabled"
  type        = string
  default     = "Disabled"

  validation {
    condition     = contains(["Enabled", "Disabled"], var.public_network_access)
    error_message = "Public network access must be \"Enabled\" or \"Disabled\"."
  }
}

variable "existing_keyvault_resource_group" {
  description = "The existing_keyvault_resource_group for the private link service"
  type        = string
}

variable "existing_keyvault_name" {
  description = "The existing_keyvault_name for the private link service"
  type        = string
}

variable "private_endpoints" {
  description = "(Optional) A map of private endpoints to create on the Azure App Configuration. Default: {}"
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

variable "replica" {
  description = "(Optional) The replica configuration with region. Defaults: null"
  type = object({
    region = string
  })
  default = null
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
