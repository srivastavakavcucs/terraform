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

#

#--------------------------------------------------------
# Module Optional Inputs
#--------------------------------------------------------

variable "private_endpoints_manage_dns_zone_group" {
  description = "Whether to manage private DNS zone groups with this module. If set to false, you must manage private DNS zone groups externally, e.g. using Azure Policy."
  type        = bool
  default     = true
}

variable "cache_access_policies" {
  description = "(Optional) Map of Redis cache access policies. Default: {}"
  type = map(object({
    name        = string
    permissions = string
  }))
  validation {
    condition     = alltrue([for policy in values(var.cache_access_policies) : policy.name != "" && policy.permissions != ""])
    error_message = "Each access policy must have a non-empty name and permissions."
  }
  default = {}
}

variable "cache_access_policy_assignments" {
  description = "(Optional) Map of Redis Cache access policy assignments. Default: {}"
  type = map(object({
    name               = string
    access_policy_name = string
    object_id          = string
    object_id_alias    = string
  }))
  validation {
    condition     = alltrue([for pa in values(var.cache_access_policy_assignments) : pa.name != "" && pa.access_policy_name != "" && pa.object_id != "" && pa.object_id_alias != ""])
    error_message = "Each access policy assignment must have a non-empty name, access policy name, object ID, and object ID alias."
  }
  default = {}
}

variable "cache_firewall_rules" {
  description = "(Optional) Map of Redis Cache firewall rules. Default: {}"
  type = map(object({
    name     = string
    start_ip = string
    end_ip   = string
  }))

  validation {
    condition = alltrue([
      for rule in values(var.cache_firewall_rules) :
      rule.name != "" &&
      can(regex("^10\\.0\\.([0-9]{1,3})\\.([0-9]{1,3})$", rule.start_ip)) &&
      can(regex("^10\\.0\\.([0-9]{1,3})\\.([0-9]{1,3})$", rule.end_ip)) &&
      tonumber(split(".", rule.start_ip)[2]) >= 0 &&
      tonumber(split(".", rule.start_ip)[2]) <= 255 &&
      tonumber(split(".", rule.start_ip)[3]) >= 0 &&
      tonumber(split(".", rule.start_ip)[3]) <= 255 &&
      tonumber(split(".", rule.end_ip)[2]) >= 0 &&
      tonumber(split(".", rule.end_ip)[2]) <= 255 &&
      tonumber(split(".", rule.end_ip)[3]) >= 0 &&
      tonumber(split(".", rule.end_ip)[3]) <= 255
    ])
    error_message = "Each firewall rule must have a non-empty name, start IP, and end IP, and the IPs must be in the 10.0.0.0/16 range."
  }

  default = {}
}

variable "capacity" {
  description = "(Optional) The size of the Redis Cache to deploy. Valid values for Basic and Standard SKUs are 0-6, and for Premium SKUs are 1-5. Default: 1."
  type        = number
  default     = 1
  validation {
    condition = (
      (
      var.sku_name == "Basic" || var.sku_name == "Standard") && var.capacity >= 0 && var.capacity <= 6
      ) || (
      var.sku_name == "Premium" && var.capacity >= 1 && var.capacity <= 5
    )
    error_message = "For Basic and Standard SKUs, capacity must be between 0-6. For Premium SKU, capacity must be between 1-5."
  }
}

variable "diagnostic_settings" {
  description = "(Optional) Map of diagnostic settings for the Redis Cache. Default: {}"
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

variable "enable_non_ssl_port" {
  description = "(Optional) Enable the non-SSL port 6379. Default: false."
  type        = bool
  default     = false
}

variable "enable_telemetry" {
  description = "(Optional) Enable telemetry for the Redis Cache module. Default: true."
  type        = bool
  default     = true
}

variable "linked_redis_caches" {
  description = "(Optional) Map of linked Redis Cache instances. Default: {}"
  type = map(object({
    linked_redis_cache_resource_id = string
    linked_redis_cache_location    = string
    server_role                    = string
  }))
  validation {
    condition     = alltrue([for v in values(var.linked_redis_caches) : v.linked_redis_cache_resource_id != "" && v.linked_redis_cache_location != "" && v.server_role != ""])
    error_message = "Each linked Redis cache must have non-empty values for resource ID, location, and server role."
  }
  default = {}
}

variable "lock" {
  description = "(Optional) Controls the Resource Lock configuration for this resource. Default: null"
  type = object({
    kind = string
  })
  default = null
}

variable "managed_identities" {
  description = "(Optional) Managed Identity configuration for this resource. Default: {}"
  type = object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
  default = {}
}

variable "patch_schedule" {
  description = "(Optional) Patch schedule configuration for the Redis Cache. Default: []"
  type = set(object({
    day_of_week        = optional(string, "Saturday")
    maintenance_window = optional(string, "PT5H")
    start_hour_utc     = optional(number, 0)
  }))

  validation {
    condition = alltrue([
      for p in var.patch_schedule :
      contains(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"], p.day_of_week) &&
      (p.start_hour_utc >= 0 && p.start_hour_utc <= 23)
    ])
    error_message = "Patch schedule day_of_week must be one of Monday to Sunday, and start_hour_utc must be between 0 and 23."
  }

  default = []
}

variable "private_endpoints" {
  description = "(Optional) A map of private endpoints to create on the Redis Cache Server. Default: {}"
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
  default = {}
}

variable "private_static_ip_address" {
  description = "(Optional) The static IP Address for the Redis Cache when hosted inside a virtual network, restricted to the 10.x.x.x CIDR block. Default: null"
  type        = string
  default     = null

  validation {
    condition = var.private_static_ip_address == null || (
      can(regex("^10\\.([0-9]{1,3})\\.([0-9]{1,3})\\.([0-9]{1,3})$", var.private_static_ip_address)) &&
      alltrue([
        for octet in slice(split(".", coalesce(var.private_static_ip_address, "10.0.0.0")), 1, 4) :
        tonumber(octet) >= 0 && tonumber(octet) <= 255
      ])
    )
    error_message = "The private_static_ip_address must be null or a valid IPv4 address within the 10.x.x.x CIDR block (e.g., 10.0.0.1)."
  }
}

variable "public_network_access_enabled" {
  description = "(Optional) Enable public network access for the Redis Cache. Default: false."
  type        = bool
  default     = false
}

variable "redis_configuration" {
  description = "(Optional) Redis configuration settings. Default: {}"
  type = object({
    aof_backup_enabled                       = optional(bool)
    aof_storage_connection_string_0          = optional(string)
    aof_storage_connection_string_1          = optional(string)
    enable_authentication                    = optional(bool)
    active_directory_authentication_enabled  = optional(bool)
    maxmemory_reserved                       = optional(number)
    maxmemory_delta                          = optional(number)
    maxfragmentationmemory_reserved          = optional(number)
    maxmemory_policy                         = optional(string)
    data_persistence_authentication_method   = optional(string)
    rdb_backup_enabled                       = optional(bool)
    rdb_backup_frequency                     = optional(number)
    rdb_backup_max_snapshot_count            = optional(number)
    rdb_storage_connection_string            = optional(string)
    storage_account_subscription_resource_id = optional(string)
    notify_keyspace_events                   = optional(string)
  })
  default = {}
}

variable "redis_version" {
  description = "(Optional) Redis version. Only major version needed. Valid values are 4 and 6. Default: 6."
  type        = number
  validation {
    condition     = contains([4, 6], var.redis_version)
    error_message = "Redis version must be either 4 or 6."
  }
  default = 6
}

variable "replicas_per_master" {
  description = "(Optional) Quantity of replicas to create per master for this Redis Cache. Default: null."
  type        = number
  default     = null
}

variable "replicas_per_primary" {
  description = "(Optional) Quantity of replicas to create per primary for this Redis Cache. Default: null."
  type        = number
  default     = null
}

variable "role_assignments" {
  description = "(Optional) Map of role assignments for the Redis Cache. Default: {}."
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

variable "shard_count" {
  description = "(Optional) The number of shards for the Redis Cluster, available when using Premium SKU. Default: null"
  type        = number
  default     = null
}

variable "sku_name" {
  description = "(Optional) The Redis SKU to use. Possible values: Basic, Standard, Premium. Default: Premium."
  type        = string
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku_name)
    error_message = "SKU must be one of 'Basic', 'Standard' or 'Premium'."
  }
  default = "Premium"
}

variable "subnet_resource_id" {
  description = "(Optional) The ID of the Subnet where the Redis Cache is deployed, only available for Premium SKU. Default: null"
  type        = string
  default     = null
}

variable "tenant_settings" {
  description = "(Optional) A mapping of tenant settings for the Redis Cache resource. Default: {}"
  type        = map(string)
  default     = {}
}

variable "zones" {
  description = "(Optional) Availability Zones for the Redis Cache. Must be one or more of '1', '2', or '3'. Can contain null values. Default: [1, null, 2, 3]"
  type        = list(string)
  default     = ["1", null, "2", "3"]
  validation {
    condition = (
      var.zones == null || # Allow null
      (
        can(var.zones) &&                      # Ensure it's not null before evaluating
        length(coalesce(var.zones, [])) > 0 && # Avoids length() on null
        alltrue([
          for zone in coalesce(var.zones, []) :
          can(regex("^(1|2|3)$", zone)) # Ensures values are '1', '2', or '3'
        ]) &&
        length(coalesce(var.zones, [])) <= 3 &&
        length(distinct(coalesce(var.zones, []))) == length(coalesce(var.zones, []))
      )
    )
    error_message = "Zones can be null, ['1'], ['2'], ['3'], ['1', '2'], ['1', '3'], ['2', '3'], or ['1', '2', '3']."
  }
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
  description = "Common Tags for all VyStar Azure resources."
  nullable    = false
}

variable "resource_tags" {
  type        = map(string)
  description = "(Optional) Tags of the Azure Container Registry resource. Default: {}"
  default     = {}
}
