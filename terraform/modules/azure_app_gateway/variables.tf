#--------------------------------------------------------
# Common Required Inputs
#--------------------------------------------------------

variable "region" {
  description = "Azure region where the resource should be deployed. Allowed values are 'eastus' or 'westus'."
  type        = string
}

variable "app_name" {
  description = "Name of the VyStar application that will be deployed."
  type        = string
}

variable "environment" {
  description = "Target environment abbreviation for naming."
  type        = string
}

variable "environment_number_suffix" {
  description = "Environment number suffix for naming."
  type        = string
}

#--------------------------------------------------------
# Required Inputs for App Gateway
#--------------------------------------------------------

variable "backend_address_pools" {
  description = "(Required) The name of the Backend Address Pool."
  type = map(object({
    name         = string
    fqdns        = optional(set(string))
    ip_addresses = optional(set(string))
  }))
  validation {
    condition     = length(var.backend_address_pools) > 0
    error_message = "At least one backend address pool must be provided."
  }
}

variable "backend_http_settings" {
  description = "(Required) A map of backend HTTP settings for the application gateway."
  type = map(object({
    cookie_based_affinity               = optional(string, "Disabled")
    name                                = string
    port                                = number
    protocol                            = string
    affinity_cookie_name                = optional(string)
    host_name                           = optional(string)
    path                                = optional(string)
    pick_host_name_from_backend_address = optional(bool)
    probe_name                          = optional(string)
    request_timeout                     = optional(number)
    trusted_root_certificate_names      = optional(list(string))
    authentication_certificate = optional(list(object({
      name = string
    })))
    connection_draining = optional(object({
      drain_timeout_sec          = number
      enable_connection_draining = bool
    }))
  }))
  validation {
    condition     = length(var.backend_http_settings) > 0
    error_message = "At least one backend HTTP setting must be provided."
  }
}

variable "frontend_ports" {
  description = "(Required) The name of the Frontend Port."
  type = map(object({
    name = string
    port = number
  }))
  validation {
    condition     = length(var.frontend_ports) > 0
    error_message = "At least one frontend port must be provided."
  }
}

variable "http_listeners" {
  description = "(Required) A map of HTTP listener configurations for the web application gateway."
  type = map(object({
    name                           = string
    frontend_port_name             = string
    frontend_ip_configuration_name = optional(string)
    firewall_policy_id             = optional(string)
    require_sni                    = optional(bool)
    host_name                      = optional(string)
    host_names                     = optional(list(string))
    ssl_certificate_name           = optional(string)
    ssl_profile_name               = optional(string)
    custom_error_configuration = optional(list(object({
      status_code           = string
      custom_error_page_url = string
    })))
  }))
}

variable "request_routing_rules" {
  description = "(Required) A map of request routing rules that define how incoming requests are routed to backend address pools or other configurations."
  type = map(object({
    name                        = string
    rule_type                   = string
    http_listener_name          = string
    backend_address_pool_name   = optional(string)
    priority                    = optional(number)
    url_path_map_name           = optional(string)
    backend_http_settings_name  = optional(string)
    redirect_configuration_name = optional(string)
    rewrite_rule_set_name       = optional(string)
  }))
}

#--------------------------------------------------------
# Module Optional Inputs for App Gateway
#--------------------------------------------------------

variable "gateway_subnet_name_segment" {
  description = "(Optional)The subnet id of the App gateway frontend Ip Configuration"
  type        = string
}

variable "app_gateway_waf_policy_resource_id" {
  description = "(Optional) The ID of the Web Application Firewall Policy. Default: null"
  type        = string
  default     = null

  validation {
    condition     = var.app_gateway_waf_policy_resource_id == null || length(coalesce(var.app_gateway_waf_policy_resource_id, " ")) > 0
    error_message = "app_gateway_waf_policy_resource_id must be a non-empty string."
  }
}

variable "authentication_certificate" {
  description = "(Optional) The contents of the Authentication Certificate which should be used. Default: null"
  type = map(object({
    data = string
    name = string
  }))
  default = null

  validation {
    condition     = var.authentication_certificate == null || length(coalesce(var.authentication_certificate, {})) >= 0
    error_message = "authentication_certificate must be a non-empty string."
  }
}

variable "autoscale_configuration" {
  description = "(Optional) Maximum capacity for autoscaling. Accepted values are in the range 2 to 125. Default: null"
  type = object({
    min_capacity = optional(number, 1)
    max_capacity = optional(number, 2)
  })
  default = null

  validation {
    condition     = var.autoscale_configuration == null || (var.autoscale_configuration.min_capacity >= 0 && var.autoscale_configuration.max_capacity >= 2 && var.autoscale_configuration.max_capacity <= 125)
    error_message = "The autoscale_configuration min_capacity must be >= 0 and max_capacity must be between 2 and 125."
  }
}

variable "create_public_ip" {
  description = "(Optional) public IP to auto create public id. Default: true"
  type        = bool
  default     = true
}

variable "custom_error_configuration" {
  description = "(Optional) Error page URL of the application gateway customer error. Default: null"
  type = map(object({
    custom_error_page_url = string
    status_code           = string
  }))
  default = null
  validation {
    condition     = var.custom_error_configuration == null || length(coalesce(var.custom_error_configuration, {})) >= 0
    error_message = "custom_error_configuration must contain valid configuration details."
  }
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
  description = "(Optional) This variable controls whether or not telemetry is enabled for the module. Default: true"
  type        = bool
  default     = true
}

variable "fips_enabled" {
  description = "(Optional) Is FIPS enabled on the Application Gateway?. Default: null"
  type        = bool
  default     = null
}

variable "frontend_ip_configuration_private" {
  description = "(Optional) The name of the private Frontend IP Configuration. Default: {}"
  type = object({
    name                            = optional(string)
    private_ip_address              = optional(string)
    private_ip_address_allocation   = optional(string)
    private_link_configuration_name = optional(string)
  })
  default = {}

  validation {
    condition     = var.frontend_ip_configuration_private == {} || length(var.frontend_ip_configuration_private) > 0
    error_message = "If provided, frontend_ip_configuration_private must have valid entries for private_ip_address, allocation, and name."
  }
}

variable "frontend_ip_configuration_public_name" {
  description = "(Optional) The name of the public Frontend IP Configuration. If not supplied will be inferred from the resource name. Default: null"
  type        = string
  default     = null
}

variable "global" {
  description = "(Optional) Whether Application Gateway's Request buffer is enabled. Default: null"
  type = object({
    request_buffering_enabled  = bool
    response_buffering_enabled = bool
  })
  default = null

  validation {
    condition     = var.global != null
    error_message = "The global variable is required and must contain request and response buffering configuration."
  }
}

variable "http2_enable" {
  description = "(Optional) The Azure application gateway HTTP/2 protocol support. Default: true"
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

variable "managed_identities" {
  description = "(Optional) Controls the Managed Identity configuration on this resource. Default: {}"
  type = object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
  default = {}
}

variable "private_link_configuration" {
  description = "(Optional) The name of the private link configuration. Default: null"
  type = set(object({
    name = string
    ip_configuration = list(object({
      name                          = string
      primary                       = bool
      private_ip_address            = optional(string)
      private_ip_address_allocation = string
      subnet_id                     = string
    }))
  }))
  default = null

  validation {
    condition     = var.private_link_configuration == null || length(coalesce(var.private_link_configuration, [])) >= 0
    error_message = "private_link_configuration must contain valid configuration details for private links."
  }
}

variable "probe_configurations" {
  description = "(Optional) The Hostname used for this Probe. Default: null"
  type = map(object({
    name                                      = string
    host                                      = optional(string)
    interval                                  = number
    timeout                                   = number
    unhealthy_threshold                       = number
    protocol                                  = string
    port                                      = optional(number)
    path                                      = string
    pick_host_name_from_backend_http_settings = optional(bool)
    minimum_servers                           = optional(number)
    match = optional(object({
      body        = optional(string)
      status_code = optional(list(string))
    }))
  }))
  default = null

  validation {
    condition     = alltrue([for probe in coalesce(var.probe_configurations, {}) : probe.interval > 0 && probe.timeout > 0 && probe.protocol != ""])
    error_message = "probe_configurations must be properly defined."
  }
}

variable "public_ip_name" {
  description = "(Optional) The name of the application gateway. Default: null"
  type        = string
  default     = null
}

variable "public_ip_resource_id" {
  description = "(Optional) public IP resource ID. If provided, the module will not create a public IP. Default: null"
  type        = string
  default     = null
}

variable "redirect_configuration" {
  description = "(Optional) Whether to include the path in the redirected URL. Default: null"
  type = map(object({
    include_path         = optional(bool)
    include_query_string = optional(bool)
    name                 = string
    redirect_type        = string
    target_listener_name = optional(string)
    target_url           = optional(string)
  }))
  default = null
  validation {
    condition     = var.redirect_configuration == null || length(coalesce(var.redirect_configuration, {})) >= 0
    error_message = "redirect_configuration must contain valid configurations."
  }
}

variable "rewrite_rule_set" {
  description = "(Optional) Unique name of the rewrite rule set block. Default: null"
  type = map(object({
    name = string
    rewrite_rules = optional(map(object({
      name          = string
      rule_sequence = number
      conditions = optional(map(object({
        ignore_case = optional(bool)
        negate      = optional(bool)
        pattern     = string
        variable    = string
      })))
      request_header_configurations = optional(map(object({
        header_name  = string
        header_value = string
      })))
      response_header_configurations = optional(map(object({
        header_name  = string
        header_value = string
      })))
      url = optional(object({
        components   = optional(string)
        path         = optional(string)
        query_string = optional(string)
        reroute      = optional(bool)
      }))
    })))
  }))
  default = null

  validation {
    condition     = var.rewrite_rule_set == null || length(coalesce(var.rewrite_rule_set, {})) >= 0
    error_message = "Rewrite rule set must be provided with at least one valid rule."
  }
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

variable "sku" {
  description = "(Optional) The Name of the SKU to use for this Application Gateway. Possible values are Standard_Small, Standard_Medium, Standard_Large, Standard_v2, WAF_Medium, WAF_Large, and WAF_v2. Default: {}"
  type = object({
    name     = string              # Standard_Small, Standard_Medium, Standard_Large, Standard_v2, WAF_Medium, WAF_Large, and WAF_v2
    tier     = string              # Standard, Standard_v2, WAF and WAF_v2
    capacity = optional(number, 2) # V1 SKU this value must be between 1 and 32, and 1 to 125 for a V2 SKU
  })
  default = {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }
  validation {
    condition     = contains(["Standard_Small", "Standard_Medium", "Standard_Large", "Standard_v2", "WAF_Medium", "WAF_Large", "WAF_v2"], var.sku.name)
    error_message = "The 'sku.name' must be one of the following values: Standard_Small, Standard_Medium, Standard_Large, Standard_v2, WAF_Medium, WAF_Large, WAF_v2."
  }

  validation {
    condition     = var.sku.tier == "Standard" || var.sku.tier == "Standard_v2" || var.sku.tier == "WAF" || var.sku.tier == "WAF_v2"
    error_message = "The 'sku.tier' must be one of the following values: Standard, Standard_v2, WAF, WAF_v2."
  }

  validation {
    condition = (
      (var.sku.tier == "Standard" || var.sku.tier == "Standard_v2") && (var.sku.capacity >= 1 && var.sku.capacity <= 32) ||
      (var.sku.tier == "WAF" || var.sku.tier == "WAF_v2") && (var.sku.capacity >= 1 && var.sku.capacity <= 125)
    )
    error_message = "The 'sku.capacity' must be between 1 and 32 for Standard SKU or 1 and 125 for WAF SKU."
  }
}

variable "ssl_certificates" {
  description = "(Optional) The base64-encoded PFX certificate data. Required if key_vault_secret_id is not set. Default: null"
  type = map(object({
    name                = string
    data                = optional(string)
    password            = optional(string)
    key_vault_secret_id = optional(string)
  }))
  validation {
    condition = alltrue([
      for cert in coalesce(var.ssl_certificates, {}) :
      cert.data != null || cert.key_vault_secret_id != null
    ])
    error_message = "Each certificate must have either data or a key_vault_secret_id."
  }
  default = null
}

variable "ssl_policy" {
  description = "(Optional) A List of accepted cipher suites. Possible values are: TLS_DHE_DSS_WITH_3DES_EDE_CBC_SHA, TLS_DHE_DSS_WITH_AES_128_CBC_SHA, TLS_DHE_DSS_WITH_AES_128_CBC_SHA256, TLS_DHE_DSS_WITH_AES_256_CBC_SHA, TLS_DHE_DSS_WITH_AES_256_CBC_SHA256, TLS_DHE_RSA_WITH_AES_128_CBC_SHA, TLS_DHE_RSA_WITH_AES_128_GCM_SHA256, TLS_DHE_RSA_WITH_AES_256_CBC_SHA, TLS_DHE_RSA_WITH_AES_256_GCM_SHA384, TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA, TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256, TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256, TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA, TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384, TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384, TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA, TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256, TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256, TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA, TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384, TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384, TLS_RSA_WITH_3DES_EDE_CBC_SHA, TLS_RSA_WITH_AES_128_CBC_SHA, TLS_RSA_WITH_AES_128_CBC_SHA256, TLS_RSA_WITH_AES_128_GCM_SHA256, TLS_RSA_WITH_AES_256_CBC_SHA, TLS_RSA_WITH_AES_256_CBC_SHA256 and TLS_RSA_WITH_AES_256_GCM_SHA384. Default: null"
  type = object({
    cipher_suites        = optional(list(string))
    disabled_protocols   = optional(list(string))
    min_protocol_version = optional(string)
    policy_name          = optional(string)
    policy_type          = optional(string)
  })
  validation {
    condition = try(var.ssl_policy == null, true) || (
      try(var.ssl_policy.cipher_suites == null, true) || length(coalesce(try(var.ssl_policy.cipher_suites, []), [])) > 0
    )
    error_message = "ssl_policy must contain valid configurations."
  }
  default = null
}

variable "ssl_profile" {
  description = "(Optional) The name of the SSL Profile that is unique within this Application Gateway. Default: null"
  type = map(object({
    name = string
    ssl_policy = optional(object({
      cipher_suites        = optional(list(string))
      disabled_protocols   = optional(list(string))
      min_protocol_version = optional(string)
      policy_name          = optional(string)
      policy_type          = optional(string)
    }))
  }))
  validation {
    condition     = var.ssl_profile == null || alltrue([for profile in coalesce(var.ssl_profile, {}) : profile.name != null && profile.name != ""])
    error_message = "ssl_profile must contain valid profile configurations."
  }
  default = null
}

variable "timeouts" {
  description = "(Optional) Used when creating the Application Gateway. Default: null"
  type = object({
    create = optional(string)
    delete = optional(string)
    read   = optional(string)
    update = optional(string)
  })
  default = null
}

variable "trusted_client_certificate" {
  description = "(Optional) The base-64 encoded certificate. Default: null"
  type = map(object({
    data = string
    name = string
  }))
  validation {
    condition = alltrue([
      for cert in coalesce(var.trusted_client_certificate, {}) :
      cert.data != null && length(cert.data) > 0 &&
      cert.name != null && length(cert.name) > 0
    ])
    error_message = "Each certificate must have a valid 'data' and 'name' that are non-empty."
  }
  default = null
}

variable "trusted_root_certificate" {
  description = "(Optional) The contents of the Trusted Root Certificate which should be used. Required if key_vault_secret_id is not set. Default: null"
  type = map(object({
    data                = optional(string)
    key_vault_secret_id = optional(string)
    name                = string
  }))
  validation {
    condition     = var.trusted_root_certificate == null || length(coalesce(var.trusted_root_certificate, {})) >= 0
    error_message = "The trusted_root_certificate cannot be empty."
  }

  validation {
    condition = alltrue([
      for cert in coalesce(var.trusted_root_certificate, {}) :
      cert.name != null
    ])
    error_message = "Each trusted root certificate must have both 'data' and 'name' specified."
  }
  default = null
}

variable "url_path_map_configurations" {
  description = "(Optional) The Name of the Default Backend Address Pool which should be used for this URL Path Map. Cannot be set if default_redirect_configuration_name is set. Default: null"
  type = map(object({
    name                                = string
    default_redirect_configuration_name = optional(string)
    default_rewrite_rule_set_name       = optional(string)
    default_backend_http_settings_name  = optional(string)
    default_backend_address_pool_name   = optional(string)
    path_rules = map(object({
      name                        = string
      paths                       = list(string)
      backend_address_pool_name   = optional(string)
      backend_http_settings_name  = optional(string)
      redirect_configuration_name = optional(string)
      rewrite_rule_set_name       = optional(string)
      firewall_policy_id          = optional(string)
    }))
  }))

  default = null
  validation {
    condition     = var.url_path_map_configurations == null || length(coalesce(var.url_path_map_configurations, {})) >= 0
    error_message = "url_path_map_configurations must contain valid configurations."
  }
}

variable "waf_configuration" {
  description = "(Optional) Is the Web Application Firewall enabled?. Default: null"
  type = object({
    enabled                  = bool
    file_upload_limit_mb     = optional(number)
    firewall_mode            = string
    max_request_body_size_kb = optional(number)
    request_body_check       = optional(bool)
    rule_set_type            = optional(string)
    rule_set_version         = string
    disabled_rule_group = optional(list(object({
      rule_group_name = string
      rules           = optional(list(number))
    })))
    exclusion = optional(list(object({
      match_variable          = string
      selector                = optional(string)
      selector_match_operator = optional(string)
    })))
  })
  validation {
    condition     = var.waf_configuration != null
    error_message = "The 'waf_configuration' must be provided."
  }

  validation {
    condition     = contains(["Detection", "Prevention"], var.waf_configuration.firewall_mode)
    error_message = "The 'waf_configuration.firewall_mode' must be one of: Detection, Prevention."
  }

  validation {
    condition     = var.waf_configuration.enabled != null
    error_message = "The 'waf_configuration.enabled' must be specified as a boolean value."
  }
  default = null
}

variable "zones" {
  description = "(Optional) Specifies a list of Availability Zones in which this Application Gateway should be located. Changing this forces a new Application Gateway to be created. Default: []"
  type        = set(string)
  validation {
    condition     = length(var.zones) == 0 || alltrue([for zone in var.zones : zone == "zone1" || zone == "zone2" || zone == "zone3"])
    error_message = "The 'zones' must be a list containing valid availability zones: zone1, zone2, zone3."
  }
  default = []
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
  description = "(Optional) This tags which we can define specific to the resources. Default: {}"
  default     = {}
}
