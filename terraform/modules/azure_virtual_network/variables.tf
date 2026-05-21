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

variable "cidr" {
  description = "The list of address spaces used by the virtual network in CIDR notation."
  type        = list(string)
  validation {
    condition     = alltrue([for cidr_block in var.cidr : can(regex("^10\\.([0-9]{1,3}\\.){2}[0-9]{1,3}/(1[6-9]|2[0-3])$", cidr_block))])
    error_message = "Each address space must be a valid Class B CIDR block within the 10.0.0.0 range (e.g., 10.0.0.0/16 to 10.255.255.255/23)."
  }
}

#--------------------------------------------------------
# Module Optional Inputs
#--------------------------------------------------------

variable "bgp_community" {
  description = "(Optional) The BGP community associated with the virtual network. Format: 12076:<community-value>. Default: null"
  type        = string
  default     = null
  validation {
    condition     = var.bgp_community == null || can(regex("^12076:.+$", var.bgp_community))
    error_message = "The BGP community must be in the format '12076:<community-value>', where <community-value> can be any string."
  }
}

variable "ddos_protection_plan" {
  description = "(Optional) Specifies an Azure Network DDoS Protection Plan. Default: null"
  type = object({
    name                = string
    resource_group_name = string
    enable              = bool
  })
  default = null
}

variable "enable_vm_protection" {
  description = "(Optional) Enable VM Protection for the virtual network. Default: false"
  type        = bool
  default     = false
}

variable "flow_timeout_in_minutes" {
  description = "(Optional) The flow timeout in minutes for the virtual network. Default: 4"
  type        = number
  default     = 4
  validation {
    condition     = (var.flow_timeout_in_minutes >= 4 && var.flow_timeout_in_minutes <= 30)
    error_message = "The flow timeout must be between 4 and 30 minutes."
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

variable "dns_servers" {
  description = <<-EOF
    (Optional) Specifies a list of IP addresses representing DNS servers.
    All addresses must fall within the 10.216.0.0/16 or 10.50.0.0/16 CIDR blocks, and at least one address must be present.
    Defaults to the static IPs of the DNS Servers in the Azure Shared Hub Subscription.
    Default: {
      dns_servers = [
        '10.216.232.4',
        '10.50.232.11'
      ]
    }
  EOF

  type = object({
    dns_servers = set(string)
  })
  default = {
    dns_servers = [
      "10.216.232.4",
      "10.50.232.11"
    ]
  }

  validation {
    condition = length(var.dns_servers.dns_servers) > 0 && alltrue([
      for ip in var.dns_servers.dns_servers :
      can(regex("^10\\.(216|50)\\.(?:[0-9]{1,3})\\.(?:[0-9]{1,3})$", ip)) && (
        tonumber(split(".", ip)[2]) >= 0 && tonumber(split(".", ip)[2]) <= 255 &&
        tonumber(split(".", ip)[3]) >= 0 && tonumber(split(".", ip)[3]) <= 255
      )
    ])
    error_message = "The 'dns_servers' variable must contain at least one valid IP address within the 10.216.0.0/16 or 10.50.0.0/16 CIDR blocks."
  }
}

variable "enable_telemetry" {
  description = "(Optional) Controls whether or not telemetry is enabled for the module. Default: true"
  type        = bool
  default     = true
}

variable "encryption" {
  description = "(Optional) Specifies the encryption settings for the virtual network. Default: null"
  type = object({
    enabled     = bool
    enforcement = string
  })
  default = null
}

variable "extended_location" {
  description = "(Optional) Specifies the extended location of the virtual network. Default: null"
  type = object({
    name = string
    type = string
  })
  default = null
}

variable "lock" {
  description = "(Optional) Controls the Resource Lock configuration for this resource. Default: null"
  type = object({
    kind = string
    name = optional(string, null)
  })
  default = null
}

variable "peerings" {
  description = "(Optional) A map of virtual network peering configurations. Default: {}"
  type = map(object({
    name                               = string
    remote_virtual_network_resource_id = string
    allow_forwarded_traffic            = optional(bool, false)
    allow_gateway_transit              = optional(bool, false)
    allow_virtual_network_access       = optional(bool, true)
    do_not_verify_remote_gateways      = optional(bool, false)
    enable_only_ipv6_peering           = optional(bool, false)
    peer_complete_vnets                = optional(bool, true)
    local_peered_address_spaces = optional(list(object({
      address_prefix = string
    })))
    remote_peered_address_spaces = optional(list(object({
      address_prefix = string
    })))
    local_peered_subnets = optional(list(object({
      subnet_name = string
    })))
    remote_peered_subnets = optional(list(object({
      subnet_name = string
    })))
    use_remote_gateways                   = optional(bool, false)
    create_reverse_peering                = optional(bool, false)
    reverse_name                          = optional(string)
    reverse_allow_forwarded_traffic       = optional(bool, false)
    reverse_allow_gateway_transit         = optional(bool, false)
    reverse_allow_virtual_network_access  = optional(bool, true)
    reverse_do_not_verify_remote_gateways = optional(bool, false)
    reverse_enable_only_ipv6_peering      = optional(bool, false)
    reverse_peer_complete_vnets           = optional(bool, true)
    reverse_local_peered_address_spaces = optional(list(object({
      address_prefix = string
    })))
    reverse_remote_peered_address_spaces = optional(list(object({
      address_prefix = string
    })))
    reverse_local_peered_subnets = optional(list(object({
      subnet_name = string
    })))
    reverse_remote_peered_subnets = optional(list(object({
      subnet_name = string
    })))
    reverse_use_remote_gateways = optional(bool, false)
  }))
  default = {}
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

variable "subnets" {
  description = "(Optional) A map of subnets to create. Default: {}"
  type = map(object({
    address_prefix   = optional(string)
    address_prefixes = optional(list(string))
    name_segment     = string
    nat_gateway = optional(object({
      name                = string
      resource_group_name = string
    }))
    network_security_group = optional(object({
      name                = string
      resource_group_name = string
    }))
    private_endpoint_network_policies             = optional(string, "Enabled")
    private_link_service_network_policies_enabled = optional(bool, true)
    route_table = optional(object({
      name                = string
      resource_group_name = string
    }))
    service_endpoint_policies = optional(map(object({
      name                = string
      resource_group_name = string
    })))
    service_endpoints               = optional(set(string))
    default_outbound_access_enabled = optional(bool, false)
    sharing_scope                   = optional(string, null)
    delegation = optional(list(object({
      name = string
      service_delegation = object({
        name = string
      })
    })))
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
    role_assignments = optional(map(object({
      role_definition_id_or_name             = string
      principal_id                           = string
      description                            = optional(string, null)
      skip_service_principal_aad_check       = optional(bool, false)
      condition                              = optional(string, null)
      condition_version                      = optional(string, null)
      delegated_managed_identity_resource_id = optional(string, null)
      principal_type                         = optional(string, null)
    })))
  }))
  default = {}
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
