#-------------------------------------------------------------------------------------------
# Azure Database for PostgreSQL Flexible Server Resource Creation
#-------------------------------------------------------------------------------------------

module "azure_postgresql_flexible_server" {
  source  = "Azure/avm-res-dbforpostgresql-flexibleserver/azurerm"
  version = "0.1.4"

  #-------------------------------------------------------------------------------------------
  # Naming Standards Document: Azure Naming and Tagging Standards v4.0.0.0_20241022
  # VyStar ACR Naming Standard: 	pgsql-<project, app or service>-<environment>-<###>
  # Example: pgsql-omb-dev-001
  #-------------------------------------------------------------------------------------------

  # Required Inputs
  location                          = module.base.location
  name                              = "pgsql-${var.app_name}-${var.environment}-${var.environment_number_suffix}"
  resource_group_name               = module.base.resource_group_name
  administrator_login               = var.administrator_login
  administrator_password            = var.administrator_password
  authentication                    = var.authentication
  auto_grow_enabled                 = var.auto_grow_enabled
  backup_retention_days             = var.backup_retention_days
  create_mode                       = var.create_mode
  customer_managed_key              = var.customer_managed_key
  databases                         = var.databases
  diagnostic_settings               = module.base.diagnostic_settings
  enable_telemetry                  = module.base.enable_telemetry
  geo_redundant_backup_enabled      = var.geo_redundant_backup_enabled
  high_availability                 = var.high_availability
  lock                              = module.base.lock
  maintenance_window                = var.maintenance_window
  managed_identities                = var.managed_identities
  point_in_time_restore_time_in_utc = var.point_in_time_restore_time_in_utc
  public_network_access_enabled     = var.public_network_access_enabled
  replication_role                  = var.replication_role
  role_assignments                  = module.base.role_assignments
  server_version                    = var.server_version
  sku_name                          = var.sku_name
  source_server_id                  = var.source_server_id
  storage_mb                        = var.storage_mb
  storage_tier                      = var.storage_tier
  tags                              = module.base.tags
  timeouts                          = var.timeouts
  zone                              = var.zone

  # There should only be one key value pair in the module.base.subnet_name_segments_to_subnet_id_map, retrieve the value.
  delegated_subnet_id                     = module.base.subnet_name_segments_to_subnet_id_map[var.delegated_subnet_name_segment]
  private_dns_zone_id                     = length(data.azurerm_private_dns_zone.this) > 0 ? data.azurerm_private_dns_zone.this[0].id : null
  private_endpoints                       = module.base.private_endpoints
  private_endpoints_manage_dns_zone_group = var.private_endpoints_manage_dns_zone_group

  # Forcing dependencies and deployment order to allow the resource group to be deployed first.
  depends_on = [
    module.base,
    data.azurerm_private_dns_zone_virtual_network_link.existing
  ]
}
