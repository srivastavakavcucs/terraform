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

# variable "frontend_ip_configurations" {
#   description = "A map of objects that builds frontend ip configurations for the load balancer. You need at least one frontend ip configuration to deploy a load balancer."
#   type = map(object({
#     name                                               = optional(string)
#     frontend_private_ip_address                        = optional(string)
#     frontend_private_ip_address_version                = optional(string)
#     frontend_private_ip_address_allocation             = optional(string, "Dynamic")
#     frontend_private_ip_subnet_resource_id             = optional(string)
#     gateway_load_balancer_frontend_ip_configuration_id = optional(string)
#     public_ip_address_resource_name                    = optional(string)
#     public_ip_address_resource_id                      = optional(string)
#     public_ip_prefix_resource_id                       = optional(string)
#     # frontend_private_ip_zones                                  = optional(set(string), [1, 2, 3])
#     tags                              = optional(map(any), {})
#     create_public_ip_address          = optional(bool, false)
#     new_public_ip_resource_group_name = optional(string)
#     new_public_ip_location            = optional(string)
#     inherit_lock                      = optional(bool, true)
#     lock_type_if_not_inherited        = optional(string, null)
#     inherit_tags                      = optional(bool, true)
#     edge_zone                         = optional(string)
#     zones                             = optional(list(string), ["1", "2", "3"])

#     role_assignments = optional(map(object({
#       role_definition_id_or_name             = string
#       principal_id                           = string
#       description                            = optional(string, null)
#       skip_service_principal_aad_check       = optional(bool, false) # only set to true IF using service principal
#       condition                              = optional(string, null)
#       condition_version                      = optional(string, null) # Valid values are 2.0
#       delegated_managed_identity_resource_id = optional(string, null)
#     })), {})

#     diagnostic_settings = optional(map(object({
#       name                                     = optional(string, null)
#       log_categories                           = optional(set(string), [])
#       log_groups                               = optional(set(string), ["allLogs"])
#       metric_categories                        = optional(set(string), ["AllMetrics"])
#       log_analytics_destination_type           = optional(string, "Dedicated")
#       workspace_resource_id                    = optional(string, null)
#       storage_account_resource_id              = optional(string, null)
#       event_hub_authorization_rule_resource_id = optional(string, null)
#       event_hub_name                           = optional(string, null)
#       marketplace_partner_resource_id          = optional(string, null)
#     })), {})
#   }))
# }

# #--------------------------------------------------------
# # Module Optional Inputs
# #--------------------------------------------------------

# variable "backend_address_pool_addresses" {
#   description = "A map of backend address pool addresses to associate with the backend address pool"
#   type = map(object({
#     name                             = optional(string)
#     backend_address_pool_object_name = optional(string)
#     ip_address                       = optional(string)
#     virtual_network_resource_id      = optional(string)
#   }))
# }

# variable "backend_address_pool_configuration" {
#   description = "String variable that determines the target virtual network for potential backend pools, at the load balancer level. You can specify the virutal_network_resource_id at the pool level or backend address level. If using network interfaces, leave this variable empty."
#   type        = string
#   default     = "null"
# }

# variable "backend_address_pool_network_interfaces" {
#   description = "A map of objects that associates one or more backend address pool network interfaces"
#   type = map(object({
#     backend_address_pool_object_name = optional(string)
#     ip_configuration_name            = optional(string)
#     network_interface_resource_id    = optional(string)
#   }))
# }

# variable "backend_address_pools" {
#   description = " A map of objects that creates one or more backend pools"
#   type = map(object({
#     name                        = optional(string, "bepool-1")
#     virtual_network_resource_id = optional(string)
#     tunnel_interfaces = optional(map(object({
#       identifier = optional(number)
#       type       = optional(string)
#       protocol   = optional(string)
#       port       = optional(number)
#     })), {})
#   }))
# }

# variable "diagnostic_settings" {
#   description = "(Optional) A map of objects that manage a Diagnostic Setting."
#   type = map(object({
#     name                                     = optional(string, null)
#     log_categories                           = optional(set(string), [])
#     log_groups                               = optional(set(string), ["allLogs"])
#     metric_categories                        = optional(set(string), ["AllMetrics"])
#     log_analytics_destination_type           = optional(string, "Dedicated")
#     workspace_resource_id                    = optional(string, null)
#     storage_account_resource_id              = optional(string, null)
#     event_hub_authorization_rule_resource_id = optional(string, null)
#     event_hub_name                           = optional(string, null)
#     marketplace_partner_resource_id          = optional(string, null)
#   }))
#   default = {}
# }

# variable "edge_zone" {
#   description = "Specifies the Edge Zone within the Azure Region where this Public IP and Load Balancer should exist. Changing this forces new resources to be created."
#   type        = string
# }




variable "lock" {
  description = "(Optional) Controls the Resource Lock configuration for this resource."
  type = object({
    kind = string
  })
  default = null
}

variable "enable_telemetry" {
  description = "(Optional) Enable telemetry for the module. Defaulted to true."
  type        = bool
  default     = true
}

# # variable "frontend_subnet_resource_id" {
# #   description = "The frontend subnet ID to use when in private mode. Can be used for all IP configurations that will use the same subnet."
# #   type        = string
# #   default     = null
# # }

# variable "lb_nat_pools" {
#   description = "A map of objects that define the inbound NAT rules for a Load Balancer."
#   type = map(object({
#     name                           = optional(string)
#     frontend_ip_configuration_name = optional(string)
#     protocol                       = optional(string, "Tcp")
#     frontend_port_start            = optional(number, 3000)
#     frontend_port_end              = optional(number, 3389)
#     backend_port                   = optional(number, 3389)
#     idle_timeout_in_minutes        = optional(number, 4)
#     enable_floating_ip             = optional(bool, false)
#     enable_tcp_reset               = optional(bool, false)
#   }))
#   default = {}
# }

# variable "lb_nat_rules" {
#   description = "A map of objects specifying the creation of NAT rules."
#   type = map(object({
#     name                             = optional(string)
#     frontend_ip_configuration_name   = optional(string)
#     protocol                         = optional(string)
#     frontend_port                    = optional(number)
#     backend_port                     = optional(number)
#     frontend_port_start              = optional(number)
#     frontend_port_end                = optional(number)
#     backend_address_pool_resource_id = optional(string)
#     backend_address_pool_object_name = optional(string)
#     idle_timeout_in_minutes          = optional(number, 4)
#     enable_floating_ip               = optional(bool, false)
#     enable_tcp_reset                 = optional(bool, false)
#   }))
#   default = {}
# }

# variable "lb_outbound_rules" {
#   description = "A map of objects defining the outbound rules for a Load Balancer."
#   type = map(object({
#     name                               = optional(string)
#     frontend_ip_configurations         = optional(list(object({ name = optional(string) })))
#     backend_address_pool_resource_id   = optional(string)
#     backend_address_pool_object_name   = optional(string)
#     protocol                           = optional(string, "Tcp")
#     enable_tcp_reset                   = optional(bool, false)
#     number_of_allocated_outbound_ports = optional(number, 1024)
#     idle_timeout_in_minutes            = optional(number, 4)
#   }))
#   default = {}
# }

# variable "lb_probes" {
#   description = "A list of objects specifying the Load Balancer probes to be created."
#   type = map(object({
#     name                            = optional(string)
#     protocol                        = optional(string, "Tcp")
#     port                            = optional(number, 80)
#     interval_in_seconds             = optional(number, 15)
#     probe_threshold                 = optional(number, 1)
#     request_path                    = optional(string)
#     number_of_probes_before_removal = optional(number, 2)
#   }))
#   default = {}
# }

# variable "lb_rules" {
#   description = "A list of objects specifying the Load Balancer rules."
#   type = map(object({
#     name                              = optional(string)
#     frontend_ip_configuration_name    = optional(string)
#     protocol                          = optional(string, "Tcp")
#     frontend_port                     = optional(number, 3389)
#     backend_port                      = optional(number, 3389)
#     backend_address_pool_resource_ids = optional(list(string))
#     backend_address_pool_object_names = optional(list(string))
#     probe_resource_id                 = optional(string)
#     probe_object_name                 = optional(string)
#     enable_floating_ip                = optional(bool, false)
#     idle_timeout_in_minutes           = optional(number, 4)
#     load_distribution                 = optional(string, "Default")
#     disable_outbound_snat             = optional(bool, false)
#     enable_tcp_reset                  = optional(bool, false)
#   }))
#   default = {}
# }

# variable "public_ip_address_configuration" {
#   description = "An object variable that configures settings for all public IPs for the Load Balancer."
#   type = object({
#     resource_group_name              = optional(string)
#     allocation_method                = optional(string, "Static")
#     ddos_protection_mode             = optional(string, "VirtualNetworkInherited")
#     ddos_protection_plan_resource_id = optional(string)
#     domain_name_label                = optional(string)
#     idle_timeout_in_minutes          = optional(number, 4)
#     ip_tags                          = optional(map(string))
#     ip_version                       = optional(string, "IPv4")
#     public_ip_prefix_resource_id     = optional(string)
#     reverse_fqdn                     = optional(string)
#     sku                              = optional(string, "Standard")
#     sku_tier                         = optional(string, "Regional")
#     tags                             = optional(map(string))
#   })
#   default = null
# }


#----------------------------------------------------------------
# lb variables
#----------------------------------------------------------------

# variable "subnet_name_segments" {
#   description = "(Optional) A map of strings containing the subnet name segments whose subnets and subnet IDs are needed. Default: {}"
#   type        = map(string)
#   default     = {}
# }

variable "lb_frontend_ip_name" {
  description = "Name of the load balancer frontend IP configuration."
  type        = string
}

variable "lb_private_ip_address" {
  description = "Private IP address of the load balancer."
  type        = string
}

# variable "zones" {
#   description = "Availability zones for the load balancer."
#   type        = list(string)
#   default     = ["1", "2", "3"]
# }

variable "lb_subnet_name_segment" {
  description = "The subnet id of the private link service"
  type        = string
}
# variable "use_existing_lb" {
#   description = "Flag to indicate whether to use an existing load balancer."
#   type        = bool
#   default     = false
# }

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
