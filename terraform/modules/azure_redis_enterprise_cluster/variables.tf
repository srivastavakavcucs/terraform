#-------------------------------------------------------------------------
# Documentation: https://registry.terraform.io/providers/hashicorp/azurerm/4.3.0/docs/resources/redis_enterprise_cluster
#-------------------------------------------------------------------------

// Define the name of the Redis Enterprise cluster
variable "redis_enterprise_cluster_name" {
  type        = string
  description = "Redis Enterprise cluster name"
  validation {
    // This is a required field, validatate that a value has been provided
    condition     = length(var.redis_enterprise_cluster_name) > 0
    error_message = "The Redis Enterprise cluster name must not be empty."
  }
}

// Define the location or region for the Redis Enterprise cluster
variable "location" {
  type        = string
  description = "Location or region name"
  default     = "eastus"
  validation {
    // Ensure the location is either 'us-east' or 'us-west', these are the only values that we allow currently.
    // No other regions are currently supported.
    condition     = contains(["eastus", "westus"], var.location)
    error_message = "Region name must be one of 'eastus' and 'westus'."
  }
}

// Define the name of the resource group
variable "rg_name" {
  type        = string
  description = "Resource group name"
  validation {
    // Ensure the resource group name is not empty. This is a required field.
    condition     = length(var.rg_name) > 0
    error_message = "The Resource group name must not be empty."
  }
}

// Define the availability zones for the Redis Enterprise cluster
variable "zones" {
  type        = list(string) // Keep it as string for regex validation
  description = "A list of Availability Zones in which the Redis Enterprise Cluster should be located"
  validation {
    condition     = alltrue([for zone in var.zones : can(regex("^(1|2|3)$", zone))])
    error_message = "Each zone must be '1', '2', or '3'."
  }
}

// Define the SKU name for the Redis Enterprise cluster
variable "sku_name" {
  type        = string
  description = "Redis Enterprise SKU name"
  validation {
    // Ensure the SKU name matches the required format. Check documentation for more information
    condition = can(
      regex("^((Enterprise_E(5|10|20|50|100|200|400)-(2|4|6|8|10|12|14|16|18|20))|(EnterpriseFlash_F(300|700|1500)-(3|9|15|21|27|33|39|45|51|57|63|69|75)))$",
      var.sku_name)
    )
    error_message = <<-EOT
      SKU name must be in the format 'Enterprise_E<capacity>-<number>' or 'EnterpriseFlash_F<capacity>-<number>'. 
      Valid SKU names are 'Enterprise_E5', 'Enterprise_E10', 'Enterprise_E20', 'Enterprise_E50', 'Enterprise_E100', 
      'Enterprise_E200', 'Enterprise_E400', 'EnterpriseFlash_F300', 'EnterpriseFlash_F700', 'EnterpriseFlash_F1500'. 
      Valid capacities for Enterprise SKUs are 2, 4, 6, 8, 10, 12, 14, 16, 18, 20. Valid capacities for EnterpriseFlash 
      SKUs are 3, 9, 15, 21, 27, 33, 39, 45, 51, 57, 63, 69, 75. Changing this forces a new Redis Enterprise Cluster to be created.
    EOT
  }
}

// Define the minimum TLS version for the Redis Enterprise cluster

variable "minimum_tls_version" {
  type        = string
  description = "Minimum TLS Version. Possible values are 1.2, other options are invalid. Defaults to 1.2"
  default     = "1.2"
  validation {
    // Ensure the TLS version is 1.2 for security reasons
    condition     = var.minimum_tls_version == "1.2"
    error_message = "The TLS version needs to be 1.2 due to security reasons. 1.0 and 1.1 are not allowed. Changing this forces a new Redis Enterprise Cluster to be created."
  }
}

// Define tags specific to the resources
variable "resource_tags" {
  type        = map(string)
  description = "Tags specific to the resources."
}

// Define common tags for all resources
variable "common_tags" {
  type        = map(string)
  description = "Common tags for all resources."
}