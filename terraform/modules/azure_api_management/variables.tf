#---------------------------------------------------------------------------------
# Common Required Inputs
#---------------------------------------------------------------------------------

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

#---------------------------------------------------------------------------------
# Module Required Inputs
#---------------------------------------------------------------------------------

variable "publisher_email" {
  description = "The email address for the publisher."
  type        = string
}

#---------------------------------------------------------------------------------
# Module Optional Inputs
#---------------------------------------------------------------------------------

variable "publisher_name" {
  description = "(Optional) The name of the API Management publisher. Default: VyStar Credit Union"
  type        = string
  nullable    = false
  default     = "VyStar Credit Union"
}

variable "sku_name" {
  description = <<EOT
(Optional) The SKU of the API Management service.
Allowed values: "Consumption", "Developer", "Standard", and "Premium".
Default: "Premium".
EOT
  type        = string
  nullable    = false
  default     = "Premium"

  validation {
    condition     = contains(["Consumption", "Developer", "Standard", "Premium"], var.sku_name)
    error_message = "The SKU name must be one of the following: Consumption, Developer, Standard, Premium."
  }
}

variable "sku_capacity" {
  description = <<EOT
(Optional) The capacity of the SKU (number of units).
- Consumption SKU must have a capacity of 0 (automatic scaling).
- Developer, Standard, and Premium SKUs must have a positive integer capacity.
Default: 12 (for Premium SKU).
EOT
  type        = number
  nullable    = false
  default     = 12

  validation {
    condition     = (var.sku_name == "Consumption" && var.sku_capacity == 0) || (var.sku_name != "Consumption" && var.sku_capacity > 0 && var.sku_capacity <= 12)
    error_message = "The SKU capacity must be 0 for 'Consumption' SKU. For 'Developer', 'Standard', or 'Premium' SKUs, the capacity must be a positive integer (up to 12 by default)."
  }
}

variable "additional_locations" {
  description = <<EOT
(Optional) A map of additional locations for expanding the API Management service.
Each additional location block contains:
- `location` (Required): The name of the Azure Region for the additional location.
- `capacity` (Optional): Number of compute units in this region.
- `zones` (Optional): A list of availability zones (supported only in the Premium tier).
- `public_ip_address_id` (Optional): The ID of a Standard SKU IPv4 Public IP (supported only in the Premium tier).
- `virtual_network_configuration` (Optional): A block specifying the subnet ID for the virtual network (required when `virtual_network_type` is "External" or "Internal").
- `gateway_disabled` (Optional): Indicates whether the gateway is disabled in this additional location.
Default: {}
EOT
  type = map(object({
    location             = string
    capacity             = optional(number, null)
    zones                = optional(list(string), [])
    public_ip_address_id = optional(string, null)
    virtual_network_configuration = optional(object({
      subnet_id = string
    }), null)
    gateway_disabled = optional(bool, false)
  }))
  default = {}
  validation {
    condition = alltrue([
      for loc, config in var.additional_locations : (
        (var.sku_name == "Premium") || (length(config.zones) == 0 && config.public_ip_address_id == null)
      )
    ])
    error_message = "Availability zones and custom public IPs are only supported in the Premium tier."
  }
  validation {
    condition = alltrue([
      for loc, config in var.additional_locations : (
        (var.virtual_network_type == "None" && config.virtual_network_configuration == null) ||
        (var.virtual_network_type != "None" && config.virtual_network_configuration != null && length(config.virtual_network_configuration.subnet_id) > 0)
      )
    ])
    error_message = "The 'virtual_network_configuration' block must be provided with a valid 'subnet_id' when 'virtual_network_type' is set to 'External' or 'Internal'."
  }
}

variable "certificate" {
  description = "(Optional) A certificate block containing details for the API Management service. Supports encoded_certificate, store_name, and certificate_password. Default: null"
  type = object({
    encoded_certificate  = string
    store_name           = string
    certificate_password = optional(string, null)
  })
  default = null
}

variable "client_certificate_enabled" {
  description = "(Optional) Enforce a client certificate to be presented on each request to the gateway. Only supported for the Consumption SKU. Default: false."
  type        = bool
  default     = false
  validation {
    condition     = !(var.client_certificate_enabled && !can(regex("^Consumption_0$", var.sku_name)))
    error_message = "Client certificates can only be enabled for the Consumption SKU with capacity 0."
  }
}

variable "delegation" {
  description = "(Optional) A delegation block for handling subscription and user registration delegation requests. Supports subscriptions_enabled, user_registration_enabled, url, and validation_key."
  type = object({
    subscriptions_enabled     = optional(bool, false)
    user_registration_enabled = optional(bool, false)
    url                       = optional(string, null)
    validation_key            = optional(string, null)
  })
  default = null
}

variable "gateway_disabled" {
  description = "(Optional) Disable the gateway in the main region? Only supported when additional_location is set. Default: false."
  type        = bool
  default     = false
  validation {
    condition     = !(var.gateway_disabled && length(var.additional_locations) == 0)
    error_message = "The 'gateway_disabled' can only be set to true when 'additional_locations' are configured."
  }
}

variable "min_api_version" {
  description = "(Optional) Minimum control plane API version for the API Management service. Default: null."
  type        = string
  default     = null
}

variable "zones" {
  description = "(Optional) A list of availability zones. Supported only for the Premium tier. Default: []"
  type        = list(string)
  default     = []
  validation {
    condition     = length(var.zones) == 0 || can(regex("^Premium_[0-9]+$", var.sku_name))
    error_message = "Availability zones are only supported for the Premium SKU."
  }
}

variable "identity" {
  description = <<EOT
    (Optional) An identity block specifying the Managed Service Identity configuration for the API Management service.
    - `type` (Required): Specifies the type of Managed Service Identity. Valid values: "SystemAssigned", "UserAssigned", or "SystemAssigned, UserAssigned" (to enable both).
    - `identity_ids` (Optional): A list of User Assigned Managed Identity IDs to be assigned when `type` is "UserAssigned" or "SystemAssigned, UserAssigned".

    Default: { type = "SystemAssigned", identity_ids = [] }
    EOT
  type = object({
    type         = string
    identity_ids = optional(list(string), [])
  })
  default = {
    type         = "SystemAssigned"
    identity_ids = []
  }
  validation {
    condition     = var.identity.type == "SystemAssigned" || var.identity.type == "UserAssigned" || var.identity.type == "SystemAssigned, UserAssigned"
    error_message = "The 'type' must be one of 'SystemAssigned', 'UserAssigned', or 'SystemAssigned, UserAssigned'."
  }
  validation {
    condition     = !(contains(["UserAssigned", "SystemAssigned, UserAssigned"], var.identity.type) && length(var.identity.identity_ids) == 0)
    error_message = "When 'type' is 'UserAssigned' or 'SystemAssigned, UserAssigned', the 'identity_ids' list must contain at least one Managed Identity ID."
  }
}

variable "hostname_configuration" {
  description = "(Optional) A hostname configuration block for configuring custom domains for the API Management service. Supports management, portal, developer_portal, proxy, and scm. Default: null"
  type = object({
    management = optional(list(object({
      host_name                       = string
      key_vault_id                    = optional(string, null)
      certificate                     = optional(string, null)
      certificate_password            = optional(string, null)
      negotiate_client_certificate    = optional(bool, false)
      ssl_keyvault_identity_client_id = optional(string, null)
    })), [])

    portal = optional(list(object({
      host_name                       = string
      key_vault_id                    = optional(string, null)
      certificate                     = optional(string, null)
      certificate_password            = optional(string, null)
      negotiate_client_certificate    = optional(bool, false)
      ssl_keyvault_identity_client_id = optional(string, null)
    })), [])

    developer_portal = optional(list(object({
      host_name                       = string
      key_vault_id                    = optional(string, null)
      certificate                     = optional(string, null)
      certificate_password            = optional(string, null)
      negotiate_client_certificate    = optional(bool, false)
      ssl_keyvault_identity_client_id = optional(string, null)
    })), [])

    scm = optional(list(object({
      host_name                       = string
      key_vault_id                    = optional(string, null)
      certificate                     = optional(string, null)
      certificate_password            = optional(string, null)
      negotiate_client_certificate    = optional(bool, false)
      ssl_keyvault_identity_client_id = optional(string, null)
    })), [])

    proxy = optional(list(object({
      host_name                       = string
      key_vault_id                    = optional(string, null)
      certificate                     = optional(string, null)
      certificate_password            = optional(string, null)
      negotiate_client_certificate    = optional(bool, false)
      ssl_keyvault_identity_client_id = optional(string, null)
      default_ssl_binding             = optional(bool, false)
    })), [])
  })
  default = null
}

variable "notification_sender_email" {
  description = "(Optional) The email address from which notifications are sent. Default: null."
  type        = string
  default     = null
  validation {
    condition     = var.notification_sender_email == null || can(regex("[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}", var.notification_sender_email))
    error_message = "The notification sender email must be a valid email address or null."
  }
}

variable "protocols" {
  description = <<EOT
(Optional) A protocols block specifying supported communication protocols for the API Management service.
- `enable_http2` (Optional): Indicates whether HTTP/2 is supported by the API Management service. Default: false.
EOT
  type = object({
    enable_http2 = optional(bool, false)
  })
  default = null
}

variable "security" {
  description = <<EOT
(Optional) A security block specifying the security protocol and cipher configurations for the API Management service.
- `enable_backend_ssl30` (Optional): Should SSL 3.0 be enabled on the backend of the gateway? Default: false.
- `enable_backend_tls10` (Optional): Should TLS 1.0 be enabled on the backend of the gateway? Default: false.
- `enable_backend_tls11` (Optional): Should TLS 1.1 be enabled on the backend of the gateway? Default: false.
- `enable_frontend_ssl30` (Optional): Should SSL 3.0 be enabled on the frontend of the gateway? Default: false.
- `enable_frontend_tls10` (Optional): Should TLS 1.0 be enabled on the frontend of the gateway? Default: false.
- `enable_frontend_tls11` (Optional): Should TLS 1.1 be enabled on the frontend of the gateway? Default: false.
- Cipher toggles: Options for enabling/disabling various cipher configurations (Default: false for all).
Default: null
EOT
  type = object({
    enable_backend_ssl30                                = optional(bool, false)
    enable_backend_tls10                                = optional(bool, false)
    enable_backend_tls11                                = optional(bool, false)
    enable_frontend_ssl30                               = optional(bool, false)
    enable_frontend_tls10                               = optional(bool, false)
    enable_frontend_tls11                               = optional(bool, false)
    tls_ecdhe_ecdsa_with_aes128_cbc_sha_ciphers_enabled = optional(bool, false)
    tls_ecdhe_ecdsa_with_aes256_cbc_sha_ciphers_enabled = optional(bool, false)
    tls_ecdhe_rsa_with_aes128_cbc_sha_ciphers_enabled   = optional(bool, false)
    tls_ecdhe_rsa_with_aes256_cbc_sha_ciphers_enabled   = optional(bool, false)
    tls_rsa_with_aes128_cbc_sha256_ciphers_enabled      = optional(bool, false)
    tls_rsa_with_aes128_cbc_sha_ciphers_enabled         = optional(bool, false)
    tls_rsa_with_aes128_gcm_sha256_ciphers_enabled      = optional(bool, false)
    tls_rsa_with_aes256_gcm_sha384_ciphers_enabled      = optional(bool, false)
    tls_rsa_with_aes256_cbc_sha256_ciphers_enabled      = optional(bool, false)
    tls_rsa_with_aes256_cbc_sha_ciphers_enabled         = optional(bool, false)
    triple_des_ciphers_enabled                          = optional(bool, false)
  })
  default = null
}

variable "sign_in" {
  description = <<EOT
(Optional) A sign_in block that defines whether anonymous users are redirected to the sign-in page.
- `enabled` (Required): Specifies if anonymous users should be redirected to the sign-in page.
Default: {
  enabled = true
}
EOT
  type = object({
    enabled = bool
  })
  default = {
    enabled = true
  }
}

variable "sign_up" {
  description = <<EOT
(Optional) A sign-up block defining whether users can sign up on the development portal and the terms of service they must accept.
- `enabled` (Required): Can users sign up on the development portal?
- `terms_of_service` (Required): A terms_of_service block containing details of the terms that users must agree to during sign-up.
Default: null
EOT
  type = object({
    enabled = bool
    terms_of_service = object({
      consent_required = bool   # Should the user be asked for consent during sign up?
      enabled          = bool   # Should the Terms of Service be displayed during sign-up?
      text             = string # The Terms of Service that users must agree to.
    })
  })
  default = null
}

variable "tenant_access" {
  description = <<EOT
(Optional) A tenant_access block that specifies whether access to the management API is enabled.
- `enabled` (Required): Should access to the management API be enabled?
Default: null
EOT
  type = object({
    enabled = bool
  })
  default = null
}

variable "public_ip_address_id" {
  description = "(Optional) ID of a Standard SKU IPv4 Public IP address. Supported for Premium and Developer SKUs when deployed in a virtual network. Default: null."
  type        = string
  default     = null
  validation {
    condition     = var.public_ip_address_id == null || can(regex("^(Premium|Developer)_[0-9]+$", var.sku_name))
    error_message = "Public IP addresses are only supported for Premium and Developer SKUs when deployed in a virtual network."
  }
}

variable "public_network_access_enabled" {
  description = <<EOT
(Optional) Specifies whether public access to the API Management service is allowed. This applies to the management plane only, not the API gateway or Developer portal.
Default: true
EOT
  type        = bool
  default     = true
  nullable    = false
}

variable "virtual_network_type" {
  description = <<EOT
(Optional) The type of virtual network to use for the API Management service.
Valid values: "None", "External", "Internal".
Default: "None"
EOT
  type        = string
  default     = "None"
  validation {
    condition     = var.virtual_network_type == "None" || var.virtual_network_type == "External" || var.virtual_network_type == "Internal"
    error_message = "The 'virtual_network_type' must be one of 'None', 'External', or 'Internal'."
  }
}

variable "virtual_network_configuration" {
  description = <<EOT
(Optional) A virtual_network_configuration block specifying the subnet for the API Management service.
Required when `virtual_network_type` is "External" or "Internal".
- `subnet_id` (Required): The ID of the subnet that will be used for the API Management service.
EOT
  type = object({
    subnet_id = string
  })
  default = null
}

variable "lock" {
  description = "(Optional) Controls the Resource Lock configuration for this resource. Default: null"
  type = object({
    kind = string
  })
  default = null
}

variable "enable_telemetry" {
  description = "(Optional) Enable telemetry for the module. Default: true."
  type        = bool
  default     = true
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
  nullable    = false
}

variable "resource_tags" {
  type        = map(string)
  description = "This tags which we can define specific to the resources. Default: {}"
  default     = {}
}
