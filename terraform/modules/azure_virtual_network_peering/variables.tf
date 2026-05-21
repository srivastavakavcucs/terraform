#---------------------------------------------------------------------------------
# Local VNet Variables
#---------------------------------------------------------------------------------

# The name of the local virtual network (Required)
variable "local_virtual_network_name" {
  description = "The name of the local virtual network. Changing this forces a new resource to be created."
  type        = string
  nullable    = false
  validation {
    condition     = length(var.local_virtual_network_name) > 3 && length(var.local_virtual_network_name) <= 64
    error_message = "The virtual network name must be between 3 and 64 characters long."
  }
}

# The name of the resource group where the local VNet is located (Required)
variable "local_resource_group_name" {
  description = "The name of the resource group in which the local virtual network is located."
  type        = string
  nullable    = false
  validation {
    condition     = length(var.local_resource_group_name) > 3 && length(var.local_resource_group_name) <= 90
    error_message = "The `local_resource_group_name` name must be between 3 and 90 characters long."
  }
}

#---------------------------------------------------------------------------------
# Remote VNet Variables
#---------------------------------------------------------------------------------

# The name of the remote virtual network (Required)
variable "remote_virtual_network_name" {
  description = "The name of the remote virtual network."
  type        = string
  nullable    = false
  validation {
    condition     = length(var.remote_virtual_network_name) > 3 && length(var.remote_virtual_network_name) <= 64
    error_message = "The virtual network name must be between 3 and 64 characters long."
  }
}

# # The name of the resource group where the remote VNet is located (Required)
variable "remote_resource_group_name" {
  description = "The name of the resource group in which the remote virtual network is located."
  type        = string
  nullable    = false
  validation {
    condition     = length(var.remote_resource_group_name) > 3 && length(var.remote_resource_group_name) <= 90
    error_message = "The `remote_resource_group_name` name must be between 3 and 90 characters long."
  }
}

#---------------------------------------------------------------------------------
# Variables that apply to Local VNet
#---------------------------------------------------------------------------------

# Controls if traffic from the local virtual network can reach the remote virtual network (Optional)
variable "local_allow_virtual_network_access" {
  description = "Controls if the traffic from the local virtual network can reach the remote virtual network."
  type        = bool
  default     = true
}

# Controls if forwarded traffic from VMs in the remote virtual network is allowed (Optional)
variable "local_allow_forwarded_traffic" {
  description = "Controls if forwarded traffic from VMs in the remote virtual network is allowed."
  type        = bool
  default     = true
}

# Controls if gateway links can be used in the remote virtual network’s link to the local virtual network (Optional)
variable "local_allow_gateway_transit" {
  description = "Controls gateway links that can be used in the remote virtual network’s link to the local virtual network."
  type        = bool
  default     = false
}

# A list of local subnet names that are subnet peered with the remote Virtual Network (Optional)
# variable "local_subnet_names" {
#   description = "A list of local subnet names that are subnet peered with the remote Virtual Network."
#   type        = list(string)
#   default     = []

#   validation {
#     condition     = length(var.local_subnet_names) > 0 ? alltrue([for subnet in var.local_subnet_names : length(subnet) > 0]) : true
#     error_message = "Each local subnet name must be a non-empty string."
#   }
# }

# A list of remote subnet names from the remote Virtual Network that are subnet peered (Optional)
# variable "remote_subnet_names" {
#   description = "A list of remote subnet names from the remote Virtual Network that are subnet peered."
#   type        = list(string)
#   default     = []

#   validation {
#     condition     = length(var.remote_subnet_names) > 0 ? alltrue([for subnet in var.remote_subnet_names : length(subnet) > 0]) : true
#     error_message = "Each remote subnet name must be a non-empty string."
#   }
# }

# Specifies whether complete Virtual Network address space is peered (Optional)
# variable "peer_complete_virtual_networks_enabled" {
#   description = "Specifies whether the complete Virtual Network address space is peered. Defaults to true."
#   type        = bool
#   default     = true
# }

# Controls if remote gateways can be used on the local virtual network (Optional)
variable "local_use_remote_gateways" {
  description = "Controls if remote gateways can be used on the local virtual network. Must be set to false if using Global Virtual Network Peerings."
  type        = bool
  default     = true
}

#---------------------------------------------------------------------------------
# Variables that apply to Remote VNet
#---------------------------------------------------------------------------------

# Controls if traffic from the remote virtual network can reach the local virtual network (Optional)
variable "remote_allow_virtual_network_access" {
  description = "Controls if the traffic from the local virtual network can reach the remote virtual network."
  type        = bool
  default     = true
}

# Controls if forwarded traffic from VMs in the local virtual network is allowed (Optional)
variable "remote_allow_forwarded_traffic" {
  description = "Controls if forwarded traffic from VMs in the remote virtual network is allowed."
  type        = bool
  default     = true
}

# Controls if gateway links can be used in the remote virtual network’s link to the local virtual network (Optional)
variable "remote_allow_gateway_transit" {
  description = "Controls gateway links that can be used in the remote virtual network’s link to the local virtual network."
  type        = bool
  default     = true
}

# Controls if remote gateways can be used on the remote virtual network (Optional)
variable "remote_use_remote_gateways" {
  description = "Controls if remote gateways can be used on the remote virtual network. Must be set to false if using Global Virtual Network Peerings."
  type        = bool
  default     = false
}
