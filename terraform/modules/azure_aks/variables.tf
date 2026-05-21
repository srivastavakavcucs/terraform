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
# Module Optional Inputs
#--------------------------------------------------------

variable "min_node_count" {
  description = "The number of nodes for the default node pool."
  type        = number
}

variable "max_node_count" {
  description = "The number of nodes for the default node pool."
  type        = number
}

variable "vm_size" {
  description = "The size of the virtual machines in the default node pool."
  type        = string
}

variable "service_cidr" {
  description = "The CIDR range for the Kubernetes service IP addresses."
  type        = string
}

variable "dns_service_ip" {
  description = "The IP address assigned to the Kubernetes DNS service."
  type        = string
}

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

variable "node_subnet_name_segment" {
  description = "Name segment of the subnet for main/master nodes. Example: 'aks-main' for the segment of the subnet name of 'snet-aks-main-001-10.190.1.0_24'."
  type        = string
  nullable    = false
  validation {
    condition     = length(var.node_subnet_name_segment) > 3 && length(var.node_subnet_name_segment) <= 25
    error_message = "The main subnet name segment must be between 3 and 25 characters long."
  }
}

variable "pod_subnet_name_segment" {
  description = "Name segment of the subnet for worker nodes. Example: 'aks-workers' for the segment of the subnet name of 'snet-aks-workers-001-10.190.2.0_24'."
  type        = string
  nullable    = false
  validation {
    condition     = length(var.pod_subnet_name_segment) > 3 && length(var.pod_subnet_name_segment) <= 25
    error_message = "The worker subnet name segment must be between 3 and 25 characters long."
  }
}

variable "aks_identity_name" {
  description = "Name of the managed identity."
  type        = string
}

variable "aks_identity_rg_name" {
  description = "Name of the managed identity resource group."
  type        = string
}

variable "aks_private_dns_name" {
  description = "Name of the AKS private DNS zone in the other subscription."
  type        = string
}

variable "aks_private_dns_shared_rg_name" {
  description = "Resource Group Name of the AKS private DNS zone in the other subscription."
  type        = string
}

variable "aks_ingress_private_dns_name" {
  description = "Name of the AKS ingress private DNS zone in the other subscription."
  type        = string
}

variable "aks_ingress_private_dns_shared_rg_name" {
  description = "Resource Group Name of the AKS ingress private DNS zone in the other subscription."
  type        = string
}

variable "connected_acr_name" {
  description = "Name of the Existing ACR."
  type        = string
}

variable "connected_acr_rg_name" {
  description = "Resource Group Name of the Existing ACR."
  type        = string
}

# variable "connected_redis_name" {
#   description = "Name of the Existing Redis."
#   type        = string
# }

# variable "connected_redis_rg_name" {
#   description = "Resource Group Name of the Existing Redis."
#   type        = string
# }

# variable "connected_pgsql_name" {
#   description = "Name of the Existing postgreSQL to connected with AKS."
#   type        = string
# }

# variable "connected_pgsql_rg_name" {
#   description = "Resource Group Name of the Existing postgreSQL to connected with AKS."
#   type        = string
# }

variable "connected_kv_name" {
  description = "Name of the Existing Key Vault to be connected with AKS."
  type        = string
}

variable "connected_kv_rg_name" {
  description = "Resource Group Name of the Existing Key Valut to be connected with AKS."
  type        = string
}

variable "connected_storage_name" {
  description = "Existing Storage account name to connected with AKS."
  type        = string
}

variable "connected_storage_rg_name" {
  description = "Existing Storage account rg to connected with AKS."
  type        = string
}

variable "custom_resource_group_name" {
  description = "(Optional) Name of an existing resource group to use. If provided, no new resource group will be created."
  type        = string
  default     = null
}

#---------------------------------------------------------------------------------
# Azure support addons
#---------------------------------------------------------------------------------
variable "enable_psa_support" {
  description = "(Optional) Enable/disable pod security admissions support for the cluster."
  type        = bool
  default     = false
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
