#------------------------------------------------------------------------
# CloudODS Storage Component
# 
# Provisions an Azure Storage Account with blob containers for:
# - landing: CFM file drops with hierarchical folder structure
# - configuration: Pipeline config files with versioning (per ADR-014)
#
# Connection string stored in Key Vault for Function App consumption
#------------------------------------------------------------------------

module "storage_account" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "0.5.0"

  #------------------------------------------------------------------------
  # Naming Standards: cloudods<region><purpose><###>
  # Example: cloudodseusblob001
  #------------------------------------------------------------------------

  # Required inputs
  location            = module.base.location
  name                = "cloudods${module.base.environment}${var.storage_account_suffix}"
  resource_group_name = module.base.resource_group_name

  # Storage Account configuration for blob operations
  account_kind                     = "StorageV2"
  account_tier                     = var.account_tier
  account_replication_type         = var.account_replication_type
  access_tier                      = var.access_tier
  enable_telemetry                 = module.base.enable_telemetry
  lock                             = module.base.lock
  network_rules                    = var.network_rules
  role_assignments                 = module.base.role_assignments
  managed_identities               = var.managed_identities
  public_network_access_enabled    = var.public_network_access_enabled
  tags                             = module.base.tags
  shared_access_key_enabled        = var.shared_access_key_enabled
  infrastructure_encryption_enabled = var.infrastructure_encryption_enabled
  min_tls_version                  = var.min_tls_version

  # Private endpoints for blob storage
  private_endpoints                       = module.base.private_endpoints
  private_endpoints_manage_dns_zone_group = var.private_endpoints_manage_dns_zone_group

  depends_on = [module.base]
}

#------------------------------------------------------------------------
# Blob Containers
#------------------------------------------------------------------------

# Landing container for CFM file drops
resource "azurerm_storage_container" "landing" {
  name                  = var.landing_container_name
  storage_account_name  = module.storage_account.name
  container_access_type = var.landing_container_access_type

  depends_on = [module.storage_account]
}

# Configuration container for pipeline config files
resource "azurerm_storage_container" "configuration" {
  name                  = var.configuration_container_name
  storage_account_name  = module.storage_account.name
  container_access_type = var.configuration_container_access_type

  depends_on = [module.storage_account]
}

#------------------------------------------------------------------------
# Enable Blob Versioning on Configuration Container (ADR-014)
#------------------------------------------------------------------------

resource "azurerm_storage_account_blob_properties" "blob_properties" {
  storage_account_id = module.storage_account.resource_id

  versioning_enabled = true

  # Enable soft delete for additional protection
  delete_retention_policy {
    days = var.delete_retention_days
  }

  # Enable container soft delete
  container_delete_retention_policy {
    days = var.container_delete_retention_days
  }

  depends_on = [module.storage_account]
}

#------------------------------------------------------------------------
# Store Connection String in Key Vault (AzureWebJobsStorage)
#------------------------------------------------------------------------

resource "azurerm_key_vault_secret" "storage_account_connection_string" {
  name         = var.key_vault_secret_name
  value        = module.storage_account.storage_account_primary_connection_string
  key_vault_id = var.key_vault_id

  depends_on = [module.storage_account]
}

#------------------------------------------------------------------------
# Store Storage Account Name in Key Vault
#------------------------------------------------------------------------

resource "azurerm_key_vault_secret" "storage_account_name" {
  name         = "${var.key_vault_secret_name}-name"
  value        = module.storage_account.name
  key_vault_id = var.key_vault_id

  depends_on = [module.storage_account]
}

#------------------------------------------------------------------------
# Store Primary Blob Endpoint in Key Vault (for Function App reference)
#------------------------------------------------------------------------

resource "azurerm_key_vault_secret" "blob_endpoint" {
  name         = "${var.key_vault_secret_name}-blob-endpoint"
  value        = module.storage_account.primary_blob_endpoint
  key_vault_id = var.key_vault_id

  depends_on = [module.storage_account]
}
