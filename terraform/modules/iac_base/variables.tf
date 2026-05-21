#--------------------------------------------------------
# Required Inputs for all modules
#--------------------------------------------------------

variable "region" {
  description = "Azure region where the resource should be deployed. Allowed values are 'eastus' or 'westus'."
  type        = string
  default     = "eastus"
  validation {
    condition     = var.region == "eastus" || var.region == "westus"
    error_message = "The location variable must be either 'eastus' or 'westus'."
  }
}

variable "app_name" {
  type        = string
  description = "Name of the VyStar application that will be deployed."
  nullable    = false
  validation {
    condition     = length(var.app_name) > 0
    error_message = "The 'app_name' cannot be an empty string. Example: 'omb'"
  }
}

variable "component_name" {
  type        = string
  description = "Name of the Azure Component that is being deployed."
  nullable    = false

  validation {
    condition     = length(var.component_name) > 0
    error_message = "The 'component_name' cannot be an empty string. Example: 'vnet', 'redis', 'keyvault', etc."
  }

  validation {
    condition     = !startswith(var.component_name, "-") && !endswith(var.component_name, "-")
    error_message = "The 'component_name' must not start or end with the character '-'."
  }
}

variable "environment" {
  type        = string
  description = "Target environment abbreviation for naming."
  nullable    = false
  default     = "dev"
  validation {
    condition     = contains(["dev", "qa", "test", "uat", "stage", "staging", "prod", "nonprod", "sandbox", "perf"], var.environment)
    error_message = "Environment must be one of 'dev', 'qa', 'test', 'uat', 'stage', 'staging', 'prod', 'nonprod', 'sandbox', or 'perf'."
  }
}

variable "environment_number_suffix" {
  type        = string
  description = "Environment number suffix for naming."
  nullable    = false

  validation {
    condition     = can(regex("^\\d{3}$", var.environment_number_suffix))
    error_message = "The 'environment_number_suffix' must be a three-digit numeric string, like '001', '002', etc."
  }
}

#-------------------------------------------------------------------------------------------
# VyStar Naming Standards: Azure Naming and Tagging Standards v4.0.0.0_20241022.docx
# Refer to 'Azure Tagging Standards' for more information on required common tags.
#-------------------------------------------------------------------------------------------
variable "common_tags" {
  type        = map(string)
  description = "These are the common tags that will be applied to all resources. Please refer to 'Azure Tagging Standards' document for more information."

  # Validate that all required tags are provided
  validation {
    condition = can(
      contains(keys(var.common_tags), "Business_Unit") &&
      contains(keys(var.common_tags), "Workload") &&
      contains(keys(var.common_tags), "Business_Criticality") &&
      contains(keys(var.common_tags), "Owner") &&
      contains(keys(var.common_tags), "Operations_Team") &&
      contains(keys(var.common_tags), "Cost_Center")
    )
    error_message = "All required 'tags' were not provided. Please provide the following tags: Business_Unit, Workload, Business_Criticality, Owner, Operations_Team, Cost_Center."
  }

  # Validate individual tag values for each required tag
  validation {
    condition = can(
      contains(["Marketing", "Sales", "Operations", "Account Management", "Risk Management", "Human Resources", "Finance", "Information Services"], var.common_tags["Business_Unit"])
    )
    error_message = "The 'Business Unit' tag must be one of the following: Marketing, Sales, Operations, Account Management, Risk Management, Human Resources, Finance, Information Services."
  }

  validation {
    condition = can(
      contains(["Security", "Application", "Information", "Quality Assurance", "Technology"], var.common_tags["Workload"])
    )
    error_message = "The 'Workload' tag must be one of the following: Security, Application, Information, Quality Assurance, Technology."
  }

  validation {
    condition = can(
      contains(["Platinum", "Gold", "Silver", "Bronze"], var.common_tags["Business_Criticality"])
    )
    error_message = "The 'Business Criticality' tag must be one of the following: Platinum, Gold, Silver, Bronze."
  }

  validation {
    condition     = length(var.common_tags["Owner"]) > 0
    error_message = "The 'Owner' tag must be provided with the active business or IT owner's name or title. Example: 'Finance Director'."
  }

  validation {
    condition     = length(var.common_tags["Operations_Team"]) > 0
    error_message = "The 'Operations Team' tag must be provided with the accountable team name (e.g., Cloud Engineering, Infosec Data Security, etc.)."
  }

  validation {
    condition     = can(regex("^\\d{3}$", var.common_tags["Cost_Center"]))
    error_message = "The 'Cost Center' tag must be a valid three-digit financial cost number (e.g., '701')."
  }
}

#--------------------------------------------------------
# Optional Inputs for all modules
#--------------------------------------------------------

variable "deploy_resource_group" {
  description = "(Optional) Deploys a resource group for the Azure Resource if set to true. Default: true."
  type        = bool
  default     = true
  nullable    = false
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
  description = "(Optional) Enable telemetry for the infrastructure module. Default: true."
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

  # TODO: This validation needs to be fixed as null values are causing Terraform errors.
  # validation {
  #   condition     = var.lock == null || (var.lock != null && contains(["CanNotDelete", "ReadOnly"], var.lock.kind))
  #   error_message = "The lock kind must be either 'CanNotDelete' or 'ReadOnly' if it is not null."
  # }
}

variable "role_assignments" {
  description = "(Optional) A map of role assignments to create on the Azure Resource. Default: {}"
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

variable "private_endpoints" {
  description = "(Optional) A map of private endpoints to create on the Azure Resource. Default: {}"
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
  nullable = false
  default  = {}

  # # Validation for lock kind values within each private endpoint
  # validation {
  #   condition = alltrue([
  #     for endpoint in var.private_endpoints : (
  #       endpoint.lock == null || (endpoint.lock.kind == "CanNotDelete" || endpoint.lock.kind == "ReadOnly")
  #     )
  #   ])
  #   error_message = "Each private endpoint lock kind must be either 'CanNotDelete' or 'ReadOnly' if specified."
  # }
  validation {
    condition = alltrue([
      for endpoint in var.private_endpoints : try(endpoint.lock == null || (endpoint.lock.kind == "CanNotDelete" || endpoint.lock.kind == "ReadOnly"), true)
    ])
    error_message = "Each private endpoint must have a valid lock kind of 'CanNotDelete' or 'ReadOnly', or the lock can be null."
  }
}

variable "subnet_name_segments" {
  description = "(Optional) A list of strings containing the subnet name segments whose subnets and subnet IDs are needed. Default: []"
  type        = list(string)
  nullable    = false
  default     = []
}

variable "resource_tags" {
  type        = map(string)
  description = "(Optional) Tags to be applied the Azure resource. Default: {}"
  default     = {}
}

variable "custom_resource_group_name" {
  description = "(Optional) Name of an existing resource group to use. If provided, no new resource group will be created."
  type        = string
  default     = null
}

variable "custom_vnet_name" {
  description = "(Optional) Custom VNet name. If not set, the default naming convention will be used."
  type        = string
  default     = ""
}

variable "custom_vnet_resource_group_name" {
  description = "(Optional) Custom VNet resource group name. If not set, the default naming convention will be used."
  type        = string
  default     = ""
}