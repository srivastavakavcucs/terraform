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
variable "private_dns_zone_vnet_link_name" {
  description = "Existing private_dns_zone_virtual_network_link name."
  type        = string
  default     = null
}

#--------------------------------------------------------
# Module Optional Inputs
#--------------------------------------------------------

variable "administrator_login" {
  description = "(Optional) Administrator login for the PostgreSQL Flexible Server. Required when create_mode is Default and password_auth_enabled is true."
  type        = string
  default     = null
}

variable "administrator_password" {
  description = "(Optional) Administrator password. Required when create_mode is Default and password_auth_enabled is true."
  type        = string
  default     = null
}

variable "authentication" {
  description = "AD Authentication configuration for the PostgreSQL Flexible Server."
  type = object({
    active_directory_auth_enabled = optional(bool, true)
    password_auth_enabled         = optional(bool, true)
    tenant_id                     = optional(string)
  })
  default = null
}

variable "auto_grow_enabled" {
  description = "(Optional) Enable auto-growing storage for PostgreSQL Flexible Server. Defaults to true."
  type        = bool
  default     = true
}

variable "backup_retention_days" {
  description = "(Optional) Backup retention days for PostgreSQL Flexible Server (7-35)."
  type        = number
  default     = 30
  validation {
    condition     = var.backup_retention_days >= 7 && var.backup_retention_days <= 35
    error_message = "Backup retention days must be between 7 and 35."
  }
}

variable "create_mode" {
  description = "(Optional) The creation mode which can be used to restore or replicate existing servers. Possible values are Default, GeoRestore, PointInTimeRestore, Replica, and Update."
  type        = string
  default     = "Default"
  validation {
    condition     = var.create_mode == null || contains(["Default", "GeoRestore", "PointInTimeRestore", "Replica", "Update"], var.create_mode)
    error_message = "create_mode must be one of Default, GeoRestore, PointInTimeRestore, Replica, or Update."
  }
}

variable "customer_managed_key" {
  description = "(Optional) Customer-managed keys for the PostgreSQL Flexible Server."
  type = object({
    key_vault_key_id                     = string
    geo_backup_key_vault_key_id          = optional(string)
    geo_backup_user_assigned_identity_id = optional(string)
    primary_user_assigned_identity_id    = optional(string)
  })
  default = null
}

variable "databases" {
  description = "(Optional) PostgreSQL databases configuration for databases to create on the server."
  type = map(object({
    name      = string
    charset   = optional(string, "UTF8")
    collation = optional(string, "en_US.utf8")
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
    }))
  }))
  default = {}
}

variable "delegated_subnet_name_segment" {
  description = "(Optional) Segment of the virtual network subnet that is delegated for PostgreSQL Flexible Server. Ex: 'pgsql' for snet-pgsql-10.x.x.x_24"
  type        = string
  default     = null
}

variable "diagnostic_settings" {
  description = "(Optional) Diagnostic settings for PostgreSQL Flexible Server."
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
  description = "(Optional) Enable telemetry for the module. Defaulted to true."
  type        = bool
  default     = true
}

variable "geo_redundant_backup_enabled" {
  description = "(Optional) Enable Geo-Redundant backup for PostgreSQL Flexible Server."
  type        = bool
  default     = false
}

variable "high_availability" {
  description = "(Optional) High availability configuration for PostgreSQL Flexible Server."
  type = object({
    mode                      = string
    standby_availability_zone = optional(string)
  })
  default = {
    mode = "ZoneRedundant"
  }
  validation {
    condition     = contains(["SameZone", "ZoneRedundant"], var.high_availability["mode"])
    error_message = "high_availability.mode must be either 'SameZone' or 'ZoneRedundant'."
  }
}

variable "lock" {
  description = "Controls the Resource Lock configuration for this resource."
  type = object({
    kind = string
  })
  default = null
}

variable "maintenance_window" {
  description = "(Optional) Maintenance window for PostgreSQL Flexible Server. day_of_week specifies the day of the week (0 for Sunday, 1 for Monday, etc.), start_hour specifies the hour (0-23), and start_minute specifies the minute (0-59)."
  type = object({
    day_of_week  = optional(number, 0)
    start_hour   = optional(number, 0)
    start_minute = optional(number, 0)
  })
  default = {
    day_of_week  = 0
    start_hour   = 0
    start_minute = 0
  }
  validation {
    condition     = var.maintenance_window.day_of_week >= 0 && var.maintenance_window.day_of_week <= 6
    error_message = "maintenance_window.day_of_week must be an integer between 0 (Sunday) and 6 (Saturday)."
  }
  validation {
    condition     = var.maintenance_window.start_hour >= 0 && var.maintenance_window.start_hour <= 23
    error_message = "maintenance_window.start_hour must be an integer between 0 and 23."
  }
  validation {
    condition     = var.maintenance_window.start_minute >= 0 && var.maintenance_window.start_minute <= 59
    error_message = "maintenance_window.start_minute must be an integer between 0 and 59."
  }
}

variable "managed_identities" {
  description = "(Optional) Managed Identity configuration for PostgreSQL Flexible Server."
  type = object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
  default = {}
}

variable "private_endpoints_manage_dns_zone_group" {
  description = "Whether to manage private DNS zone groups with this module. Set to false if managing DNS externally."
  type        = bool
  default     = true
}

variable "private_endpoints" {
  description = "(Optional) A map of private endpoints to create on the PostgreSQL Flexible Server."
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

variable "point_in_time_restore_time_in_utc" {
  description = "(Optional) Point-in-time restore time in UTC."
  type        = string
  default     = null
}

variable "private_dns_zone" {
  description = "(Optional) Details the private DNS zone for the PostgreSQL Flexible Server."
  type = object({
    name                = string
    resource_group_name = string
  })
  default = null
}

variable "public_network_access_enabled" {
  description = "(Optional) Enable public network access for PostgreSQL Flexible Server. Default value is false. Will require a delegated subnet."
  type        = bool
  default     = false
}

variable "replication_role" {
  description = "(Optional) Replication role for PostgreSQL Flexible Server."
  type        = string
  default     = null
}

variable "role_assignments" {
  description = "(Optional) Role assignments for PostgreSQL Flexible Server."
  type = map(object({
    role_definition_id_or_name = string
    principal_id               = string
  }))
  default = {}
}

variable "server_version" {
  description = "(Optional) The version of PostgreSQL Flexible Server to use. Defaults to PostgreSQL SQL Server 16. Required when create_mode is Default."
  type        = string
  default     = "16"
  validation {
    condition     = var.server_version == null || contains(["11", "12", "13", "14", "15", "16"], var.server_version)
    error_message = "server_version must be one of 11, 12, 13, 14, 15, or 16."
  }
}

variable "sku_name" {
  description = "(Optional) The SKU Name for the PostgreSQL Flexible Server. Must follow the pattern tier + name (e.g., B_Standard_B1ms, GP_Standard_D2s_v3, MO_Standard_E4s_v3)."
  type        = string
  default     = "GP_Standard_D2ds_v5"
  validation {
    condition = var.sku_name == null || contains([
      "B_Standard_B1ms", "B_Standard_B2s", "B_Standard_B2ms", "B_Standard_B4ms", "B_Standard_B8ms", "B_Standard_B12ms", "B_Standard_B16ms", "B_Standard_B20ms",
      "GP_Standard_D2s_v3", "GP_Standard_D2ds_v4", "GP_Standard_D2ds_v5", "GP_Standard_D2ads_v5",
      "GP_Standard_D4s_v3", "GP_Standard_D4ds_v4", "GP_Standard_D4ds_v5", "GP_Standard_D4ads_v5",
      "GP_Standard_D8s_v3", "GP_Standard_D8ds_v4", "GP_Standard_D8ds_v5", "GP_Standard_D8ads_v5",
      "GP_Standard_D16s_v3", "GP_Standard_D16ds_v4", "GP_Standard_D16ds_v5", "GP_Standard_D16ads_v5",
      "GP_Standard_D32s_v3", "GP_Standard_D32ds_v4", "GP_Standard_D32ds_v5", "GP_Standard_D32ads_v5",
      "GP_Standard_D48s_v3", "GP_Standard_D48ds_v4", "GP_Standard_D48ds_v5", "GP_Standard_D48ads_v5",
      "GP_Standard_D64s_v3", "GP_Standard_D64ds_v4", "GP_Standard_D64ds_v5", "GP_Standard_D64ads_v5",
      "GP_Standard_D96ds_v5", "GP_Standard_D96ads_v5",
      "MO_Standard_E2s_v3", "MO_Standard_E2ds_v4", "MO_Standard_E2ds_v5", "MO_Standard_E2ads_v5",
      "MO_Standard_E4s_v3", "MO_Standard_E4ds_v4", "MO_Standard_E4ds_v5", "MO_Standard_E4ads_v5",
      "MO_Standard_E8s_v3", "MO_Standard_E8ds_v4", "MO_Standard_E8ds_v5", "MO_Standard_E8ads_v5",
      "MO_Standard_E16s_v3", "MO_Standard_E16ds_v4", "MO_Standard_E16ds_v5", "MO_Standard_E16ads_v5",
      "MO_Standard_E20ds_v4", "MO_Standard_E20ds_v5", "MO_Standard_E20ads_v5",
      "MO_Standard_E32s_v3", "MO_Standard_E32ds_v4", "MO_Standard_E32ds_v5", "MO_Standard_E32ads_v5",
      "MO_Standard_E48s_v3", "MO_Standard_E48ds_v4", "MO_Standard_E48ds_v5", "MO_Standard_E48ads_v5",
      "MO_Standard_E64s_v3", "MO_Standard_E64ds_v4", "MO_Standard_E64ds_v5", "MO_Standard_E64ads_v5",
      "MO_Standard_E96ds_v5", "MO_Standard_E96ads_v5"
    ], var.sku_name)
    error_message = "sku_name must be one of the approved SKUs: B_Standard_B1ms, B_Standard_B2s, ..., GP_Standard_D2s_v3, ..., MO_Standard_E96ds_v5, etc."
  }
}

variable "source_server_id" {
  description = "(Optional) The resource ID of the source PostgreSQL Flexible Server to be restored. Required when create_mode is GeoRestore, PointInTimeRestore, or Replica."
  type        = string
  default     = null
  validation {
    condition     = var.source_server_id == null || can(regex("^/subscriptions/[0-9a-fA-F-]+/resourceGroups/.+/providers/Microsoft.DBforPostgreSQL/flexibleServers/.+$", var.source_server_id))
    error_message = "source_server_id must be a valid Azure resource ID for a PostgreSQL Flexible Server."
  }
}

variable "storage_mb" {
  description = "(Optional) The max storage allowed for the PostgreSQL Flexible Server."
  type        = number
  default     = 32768
  validation {
    condition     = var.storage_mb == null || contains([32768, 65536, 131072, 262144, 524288, 1048576, 2097152, 4193280, 4194304, 8388608, 16777216, 33553408], var.storage_mb)
    error_message = "storage_mb must be one of 32768, 65536, 131072, 262144, 524288, 1048576, 2097152, 4193280, 4194304, 8388608, 16777216, or 33553408."
  }
}

variable "storage_tier" {
  description = "(Optional) The storage tier for the PostgreSQL Flexible Server. Must be one of P4, P6, P10, P15, P20, P30, P40, P50, P60, P70, or P80."
  type        = string
  default     = "P4"
  validation {
    condition     = var.storage_tier == null || contains(["P4", "P6", "P10", "P15", "P20", "P30", "P40", "P50", "P60", "P70", "P80"], var.storage_tier)
    error_message = "storage_tier must be one of P4, P6, P10, P15, P20, P30, P40, P50, P60, P70, or P80."
  }
}

variable "timeouts" {
  description = "(Optional) Timeout settings for PostgreSQL Flexible Server."
  type = object({
    create = optional(string)
    delete = optional(string)
    read   = optional(string)
    update = optional(string)
  })
  default = null
}

variable "zone" {
  description = "(Optional) Availability zone for PostgreSQL Flexible Server. Allowed values are '1', '2', or '3'."
  type        = string
  nullable    = false
  default     = "1"
  validation {
    condition     = contains(["1", "2", "3"], var.zone)
    error_message = "The zone variable must be one of '1', '2', or '3'."
  }
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
}

variable "resource_tags" {
  type        = map(string)
  description = "This tags which we can define specific to the resources."
  default     = {}
}
