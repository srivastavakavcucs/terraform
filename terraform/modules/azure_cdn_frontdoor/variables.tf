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
# Required Inputs passing from the base module.
#--------------------------------------------------------
variable "sku" {
  description = "The SKU name of the Azure Front Door. Default is Standard. Possible values are standard and premium.SKU name for CDN can be 'Standard_Akamai', 'Standard_ChinaCdn, 'Standard_Microsoft','Standard_Verizon' or 'Premium_Verizon'"
  type        = string
  default     = "Premium_AzureFrontDoor"
  validation {
    condition     = var.sku == "Standard_AzureFrontDoor" || var.sku == "Premium_AzureFrontDoor"
    error_message = "The sku variable must be either 'Standard_AzureFrontDoor', or 'Premium_AzureFrontDoor'."
  }
}

#--------------------------------------------------------
# Optional Inputs
#--------------------------------------------------------


variable "cdn_endpoint_custom_domains" {
  description = "(Optional) Manages a map of CDN Endpoint Custom Domains. A CDN Endpoint Custom Domain is a custom domain that is associated with a CDN Endpoint."
  type = map(object({
    cdn_endpoint_key = string
    dns_zone = optional(object({
      is_azure_dns_zone                  = bool
      name                               = string
      cname_record_name                  = string
      ttl                                = number
      tags                               = optional(map(string))
      azure_dns_zone_resource_group_name = optional(string, null)
    }))
    name = string
    cdn_managed_https = optional(object({
      certificate_type = string
      protocol_type    = string
      tls_version      = optional(string, "TLS12")
    }))
    user_managed_https = optional(object({
      key_vault_certificate_id = optional(string)
      key_vault_secret_id      = optional(string)
      tls_version              = optional(string)
    }))
  }))
  default = {}
}

variable "cdn_endpoints" {
  description = "(Optional) Manages a map of CDN Endpoints. A CDN Endpoint is the entity within a CDN Profile containing configuration information regarding caching behaviours and origins."
  type = map(object({
    name                      = string
    tags                      = optional(map(any))
    is_http_allowed           = optional(bool, false)
    is_https_allowed          = optional(bool, true)
    content_types_to_compress = optional(list(string), [])

    geo_filters = optional(map(object({
      relative_path = string       # must be "/" for Standard_Microsoft. Must be unique across all filters. Only one allowed for Standard_Microsoft
      action        = string       # create a validation: allowed values: Allow or Block
      country_codes = list(string) # Create a validation. Two letter country codes allows e.g. ["US", "CA"]
    })), {})

    is_compression_enabled        = optional(bool)
    querystring_caching_behaviour = optional(string, "IgnoreQueryString") # create a validation: allowed values: IgnoreQueryString,BypassCaching ,UseQueryString,NotSet for premium verizon.
    optimization_type             = optional(string)                      # create a validation: allowed values: DynamicSiteAcceleration,GeneralMediaStreaming,GeneralWebDelivery,LargeFileDownload ,VideoOnDemandMediaStreaming

    origins = map(object({
      name       = string
      host_name  = string
      http_port  = optional(number, 80)
      https_port = optional(number, 443)
    }))

    origin_host_header = optional(string)
    origin_path        = optional(string) # must start with '/' e.g. "/media"
    probe_path         = optional(string) # must start with '/' e.g. "/foo.bar"

    global_delivery_rule = optional(object({
      cache_expiration_action = optional(list(object({
        behavior = string           # Allowed Values: BypassCache, Override and SetIfMissing
        duration = optional(string) # Only allowed when behavior is Override or SetIfMissing. Format: [d.]hh:mm:ss e.g "1.10:30:00"
      })), [])
      cache_key_query_string_action = optional(list(object({
        behavior   = string           # Allowed Values: Exclude, ExcludeAll, Include and IncludeAll
        parameters = optional(string) # Documentation says it is a list but string e.g "*"
      })), [])
      modify_request_header_action = optional(list(object({
        action = string # Allowed Values: Append, Delete and Overwrite
        name   = string
        value  = optional(string) # Only needed if action = Append or Overwrite
      })), [])
      modify_response_header_action = optional(list(object({
        action = string # Allowed Values: Append, Delete and Overwrite
        name   = string
        value  = optional(string) # Only needed if action = Append or Overwrite
      })), [])
      url_redirect_action = optional(list(object({
        redirect_type = string                    # Allowed Values: Found, Moved, PermanentRedirect and TemporaryRedirect
        protocol      = optional(string, "Https") # Allowed Values: MatchRequest, Http and Https
        hostname      = optional(string)
        path          = optional(string) # Should begin with '/'
        fragment      = optional(string) # Specifies the fragment part of the URL. This value must not start with a '#'
        query_string  = optional(string) # Specifies the query string part of the URL. This value must not start with a '?' or '&' and must be in <key>=<value> format separated by '&'.
      })), [])
      url_rewrite_action = optional(list(object({
        source_pattern          = string # (Required) This value must start with a '/' and can't be longer than 260 characters.
        destination             = string # This value must start with a '/' and can't be longer than 260 characters.
        preserve_unmatched_path = optional(bool, true)
      })), [])
    }), {})

    delivery_rules = optional(list(object({
      name  = string
      order = number
      cache_expiration_action = optional(object({
        behavior = string
        duration = optional(string)
      }))
      cache_key_query_string_action = optional(object({
        behavior   = string
        parameters = optional(string)
      }))
      cookies_condition = optional(object({
        selector         = string
        operator         = string
        negate_condition = optional(bool, false)
        match_values     = optional(list(string))
        transforms       = optional(list(string))
      }))
      device_condition = optional(object({
        operator         = optional(string, "Equal")
        negate_condition = optional(bool, false)
        match_values     = list(string)
      }))
      http_version_condition = optional(object({
        operator         = optional(string, "Equal")
        negate_condition = optional(bool, false)
        match_values     = list(string)
      }))
      modify_request_header_action = optional(object({
        action = string
        name   = string
        value  = optional(string)
      }))
      modify_response_header_action = optional(object({
        action = string
        name   = string
        value  = optional(string)
      }))
      post_arg_condition = optional(object({
        selector         = string
        operator         = string
        negate_condition = optional(bool, false)
        match_values     = optional(list(string))
        transforms       = optional(list(string))
      }))
      query_string_condition = optional(object({
        operator         = string
        negate_condition = optional(bool, false)
        match_values     = optional(list(string))
        transforms       = optional(list(string))
      }))
      remote_address_condition = optional(object({
        operator         = string
        negate_condition = optional(bool, false)
        match_values     = optional(list(string))
      }))

      request_body_condition = optional(object({
        operator         = string
        negate_condition = optional(bool, false)
        match_values     = optional(list(string))
        transforms       = optional(list(string))
      }))
      request_header_condition = optional(object({
        selector         = string
        operator         = string
        negate_condition = optional(bool, false)
        match_values     = optional(list(string))
        transforms       = optional(list(string))
      }))
      request_method_condition = optional(object({
        operator         = optional(string, "Equal")
        negate_condition = optional(bool, false)
        match_values     = list(string)
      }))
      request_scheme_condition = optional(object({
        operator         = optional(string, "Equal")
        negate_condition = optional(bool, false)
        match_values     = list(string)
      }))
      request_uri_condition = optional(object({
        operator         = string
        negate_condition = optional(bool, false)
        match_values     = optional(list(string))
        transforms       = optional(list(string))
      }))
      url_file_extension_condition = optional(object({
        operator         = string
        negate_condition = optional(bool, false)
        match_values     = optional(list(string))
        transforms       = optional(list(string))
      }))
      url_file_name_condition = optional(object({
        operator         = string
        negate_condition = optional(bool, false)
        match_values     = optional(list(string))
        transforms       = optional(list(string))
      }))
      url_path_condition = optional(object({
        operator         = string
        negate_condition = optional(bool, false)
        match_values     = optional(list(string))
        transforms       = optional(list(string))
      }))
      url_redirect_action = optional(object({
        redirect_type = string
        protocol      = optional(string, "MatchRequest")
        hostname      = optional(string)
        path          = optional(string)
        fragment      = optional(string)
        query_string  = optional(string)
      }))
      url_rewrite_action = optional(object({
        source_pattern          = string
        destination             = string
        preserve_unmatched_path = optional(bool, true)
      }))
    })))
    diagnostic_setting = optional(object({
      name                                     = optional(string, null)
      log_categories                           = optional(set(string), [])
      log_groups                               = optional(set(string), [])
      metric_categories                        = optional(set(string), [])
      log_analytics_destination_type           = optional(string, "Dedicated")
      workspace_resource_id                    = optional(string, null)
      storage_account_resource_id              = optional(string, null)
      event_hub_authorization_rule_resource_id = optional(string, null)
      event_hub_name                           = optional(string, null)
      marketplace_partner_resource_id          = optional(string, null)
    }), {})
  }))
  default = {}

}

variable "diagnostic_settings" {
  description = "(Optional) Manages a map of diagnostic settings on the CDN/front door profile. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time."
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

variable "front_door_custom_domains" {
  description = "(Optional) Manages a map of Front Door (standard/premium) Custom Domains."
  type = map(object({
    name        = string
    dns_zone_id = optional(string, null)
    host_name   = string
    tls = object({
      certificate_type         = optional(string, "ManagedCertificate")
      minimum_tls_version      = optional(string, "TLS12") # TLS1.3 is not yet supported in Terraform azurerm_cdn_frontdoor_custom_domain
      cdn_frontdoor_secret_key = optional(string, null)
    })
  }))
  default = {}

}

variable "front_door_endpoints" {
  description = "(Optional) Manages a map of Front Door (standard/premium) Endpoints."
  type = map(object({
    name    = string
    enabled = optional(bool, true)
    tags    = optional(map(any))
  }))
  default = {}

}

variable "front_door_firewall_policies" {
  description = "(Optional) Manages a map of Front Door (standard/premium) Firewall Policies."
  type = map(object({
    name                              = string
    resource_group_name               = string
    sku_name                          = string
    enabled                           = optional(bool, true)
    mode                              = string
    request_body_check_enabled        = optional(bool, true)
    redirect_url                      = optional(string)
    custom_block_response_status_code = optional(number)
    custom_block_response_body        = optional(string)
    custom_rules = optional(map(object({
      name                           = string
      enabled                        = optional(bool, true)
      priority                       = optional(number, 1)
      rate_limit_duration_in_minutes = optional(number, 1)
      rate_limit_threshold           = optional(number, 10)
      type                           = string
      action                         = string
      match_conditions = map(object({
        match_variable     = string
        operator           = string
        negation_condition = optional(bool)
        match_values       = list(string)
        selector           = optional(string)
        transforms         = optional(list(string))
      }))
    })), {})
    managed_rules = optional(map(object({
      type    = string
      version = string
      action  = string
      exclusions = optional(map(object({
        match_variable = string
        operator       = string
        selector       = optional(string)
      })), {})
      overrides = optional(map(object({
        rule_group_name = string
        exclusions = optional(map(object({
          match_variable = string
          operator       = string
          selector       = optional(string)
        })), {})
        rules = optional(map(object({
          rule_id = string
          action  = string
          enabled = optional(bool, false)
          exclusions = optional(map(object({
            match_variable = string
            operator       = string
            selector       = optional(string)
          })), {})
        })), {})
      })), {})
    })), {})
    tags = optional(map(any))
  }))
  default = {}

}

variable "front_door_origin_groups" {
  description = "(Optional) Manages a map of Front Door (standard/premium) Origin groups."
  type = map(object({
    name = string
    health_probe = optional(map(object({
      interval_in_seconds = number
      path                = optional(string, "/")
      protocol            = string
      request_type        = optional(string, "HEAD")
    })), {})
    load_balancing = map(object({
      additional_latency_in_milliseconds = optional(number, 50)
      sample_size                        = optional(number, 4)
      successful_samples_required        = optional(number, 3)
    }))
  }))
  default = {}
}

variable "front_door_origins" {
  description = "(Optional) Manages a map of Front Door (standard/premium) Origins"
  type = map(object({
    name                           = string
    origin_group_key               = string
    host_name                      = string
    certificate_name_check_enabled = string
    enabled                        = optional(bool, true)
    http_port                      = optional(number, 80)
    https_port                     = optional(number, 443)
    host_header                    = optional(string, null)
    priority                       = optional(number, 1)
    weight                         = optional(number, 500)
    private_link = optional(map(object({
      request_message        = string
      target_type            = optional(string, null)
      location               = string
      private_link_target_id = string
    })), null)
  }))
  default = {}
}

variable "front_door_routes" {
  description = "(Optional) Manages a map of Front Door (standard/premium) Routes."
  type = map(object({
    name                      = string
    origin_group_key          = string
    origin_keys               = list(string)
    endpoint_key              = string
    forwarding_protocol       = optional(string, "HttpsOnly")
    supported_protocols       = list(string)
    patterns_to_match         = list(string)
    link_to_default_domain    = optional(bool, true)
    https_redirect_enabled    = optional(bool, true)
    custom_domain_keys        = optional(list(string), [])
    enabled                   = optional(bool, true)
    rule_set_names            = optional(list(string))
    cdn_frontdoor_origin_path = optional(string, null)
    cache = optional(map(object({
      query_string_caching_behavior = optional(string, "IgnoreQueryString")
      query_strings                 = optional(list(string))
      compression_enabled           = optional(bool, false)
      content_types_to_compress     = optional(list(string))
    })), {})
  }))
  default = {}
}

variable "front_door_rule_sets" {
  description = "(Optional) Manages Front Door (standard/premium) Rule Sets. The following properties can be specified: name of the rule set."
  type        = set(string)
  default     = []
}

variable "front_door_rules" {
  description = "(Optional) Manages a map of Front Door (standard/premium) Rules."
  type = map(object({
    name              = string
    order             = number
    origin_group_key  = string
    rule_set_name     = string
    behavior_on_match = optional(string, "Continue")

    actions = object({
      url_rewrite_actions = optional(list(object({
        source_pattern          = string
        destination             = string
        preserve_unmatched_path = optional(bool, false)
      })), [])
      url_redirect_actions = optional(list(object({
        redirect_type        = string
        destination_hostname = string
        redirect_protocol    = optional(string, "Https")
        destination_path     = optional(string, "")
        query_string         = optional(string, "")
        destination_fragment = optional(string, "")
      })), [])
      route_configuration_override_actions = optional(list(object({
        set_origin_groupid            = bool
        cache_duration                = optional(string) # d.HH:MM:SS (365.23:59:59)
        forwarding_protocol           = optional(string, "HttpsOnly")
        query_string_caching_behavior = optional(string)
        query_string_parameters       = optional(list(string))
        compression_enabled           = optional(bool, false)
        cache_behavior                = optional(string)
      })), [])
      request_header_actions = optional(list(object({
        header_action = string
        header_name   = string
        value         = optional(string)
      })), [])
      response_header_actions = optional(list(object({
        header_action = string
        header_name   = string
        value         = optional(string)
      })), [])
    })
    conditions = optional(object({
      remote_address_conditions = optional(list(object({
        operator         = optional(string, "IPMatch")
        negate_condition = optional(bool, false)
        match_values     = optional(list(string))
      })), [])
      request_method_conditions = optional(list(object({
        match_values     = list(string)
        operator         = optional(string, "Equal")
        negate_condition = optional(bool, false)
      })), [])
      query_string_conditions = optional(list(object({
        operator         = string
        negate_condition = optional(bool, false)
        match_values     = optional(list(string))
        transforms       = optional(list(string))
      })), [])
      post_args_conditions = optional(list(object({
        post_args_name   = string
        operator         = string
        negate_condition = optional(bool, false)
        match_values     = optional(list(string))
        transforms       = optional(list(string))
      })), [])
      request_uri_conditions = optional(list(object({
        operator         = string
        negate_condition = optional(bool)
        match_values     = optional(list(string))
        transforms       = optional(list(string))
      })), [])
      request_header_conditions = optional(list(object({
        header_name      = string
        operator         = string
        negate_condition = optional(bool, false)
        match_values     = optional(list(string))
        transforms       = optional(list(string))
      })), [])
      request_body_conditions = optional(list(object({
        operator         = string
        match_values     = list(string)
        negate_condition = optional(bool, false)
        transforms       = optional(list(string))
      })), [])
      request_scheme_conditions = optional(list(object({
        operator         = optional(string, "Equal")
        negate_condition = optional(bool, false)
        match_values     = optional(list(string))
      })), [])
      url_path_conditions = optional(list(object({
        operator         = string
        negate_condition = optional(bool, false)
        match_values     = optional(list(string))
        transforms       = optional(list(string))
      })), [])
      url_file_extension_conditions = optional(list(object({
        operator         = string
        negate_condition = optional(bool, false)
        match_values     = list(string)
        transforms       = optional(list(string))
      })), [])
      url_filename_conditions = optional(list(object({
        operator         = string
        match_values     = optional(list(string))
        negate_condition = optional(bool, false)
        transforms       = optional(list(string))
      })), [])
      http_version_conditions = optional(list(object({
        operator         = optional(string, "Equal")
        match_values     = list(string)
        negate_condition = optional(bool, false)
      })), [])
      cookies_conditions = optional(list(object({
        cookie_name      = string
        operator         = string
        negate_condition = optional(bool, false)
        match_values     = optional(list(string))
        transforms       = optional(list(string))
      })), [])
      is_device_conditions = optional(list(object({
        operator         = optional(string)
        negate_condition = optional(bool, false)
        match_values     = optional(list(string))
      })), [])
      socket_address_conditions = optional(list(object({
        operator         = optional(string, "IPMatch")
        negate_condition = optional(bool, false)
        match_values     = optional(list(string))
      })), [])
      client_port_conditions = optional(list(object({
        operator         = string
        negate_condition = optional(bool, false)
        match_values     = optional(list(number))
      })), [])
      server_port_conditions = optional(list(object({
        operator         = string
        negate_condition = optional(bool, false)
        match_values     = list(number)
      })), [])
      host_name_conditions = optional(list(object({
        operator         = string
        match_values     = optional(list(string))
        transforms       = optional(list(string))
        negate_condition = optional(bool, false)
      })), [])
      ssl_protocol_conditions = optional(list(object({
        match_values     = list(string)
        operator         = optional(string, "Equal")
        negate_condition = optional(bool, false)
      })), [])
    }))
  }))
  default = {}
}

variable "front_door_secrets" {
  description = "(Optional) Manages a map of Front Door (standard/premium) Secrets."
  type = map(object({
    name                     = string
    key_vault_certificate_id = string
  }))
  default = {}
}

variable "front_door_security_policies" {
  description = "(Optional) Manages a map of Front Door (standard/premium) Security Policies."
  type = map(object({
    name = string
    firewall = object({
      front_door_firewall_policy_key = string
      association = object({
        domain_keys       = optional(list(string), [])
        endpoint_keys     = optional(list(string), [])
        patterns_to_match = list(string)
      })
    })
  }))
  default = {}
}

variable "lock" {
  description = "(Optional) Controls the Resource Lock configuration for this resource."
  type = object({
    kind = string
    name = optional(string, null)
  })
  default = null
}

variable "managed_identities" {
  description = "(Optional) Managed Identity configuration for this resource."
  type = object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
  default = {}
}


variable "response_timeout_seconds" {
  description = "(Optional) Specifies the maximum response timeout in seconds. Possible values are between 16 and 240 seconds (inclusive). Defaults to 120 seconds."
  type        = number
  default     = 120
}

variable "role_assignments" {
  description = "(Optional) A map of role assignments to create on the cdn/Front door profile. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time."
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
#---------------------------------------------------------------------
# Tags
#---------------------------------------------------------------------

variable "common_tags" {
  type        = map(string)
  description = "This is the default common tags for the entire resources."
}

variable "resource_tags" {
  type        = map(string)
  description = "This tags which we can define specific to the resources."
  default     = {}
}
