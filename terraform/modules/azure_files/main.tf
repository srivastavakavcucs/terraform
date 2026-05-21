module "storage_account" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "0.5.0"

  #------------------------------------------------------------------------
  # Naming Standards Document: Azure Naming and Tagging Standards
  # Files : files<subscription purpose><region><###>
  # Example: filesombdev001
  #          filescorebnkprod001
  #------------------------------------------------------------------------

  # Required inputs
  location            = module.base.location
  name                = "sa${module.base.app_name}${module.base.environment}${module.base.environment_number_suffix}"
  resource_group_name = module.base.resource_group_name

  # Optional inputs with defaults
  access_tier                             = var.access_tier
  account_kind                            = var.account_kind
  account_replication_type                = var.account_replication_type
  account_tier                            = var.account_tier
  enable_telemetry                        = module.base.enable_telemetry
  lock                                    = module.base.lock
  network_rules                           = var.network_rules
  role_assignments                        = module.base.role_assignments
  managed_identities                      = var.managed_identities
  public_network_access_enabled           = var.public_network_access_enabled
  tags                                    = module.base.tags
  is_hns_enabled                          = var.is_hns_enabled
  large_file_share_enabled                = var.large_file_share_enabled
  private_endpoints                       = module.base.private_endpoints
  private_endpoints_manage_dns_zone_group = var.private_endpoints_manage_dns_zone_group
  azure_files_authentication              = var.azure_files_authentication
  infrastructure_encryption_enabled       = var.infrastructure_encryption_enabled
  min_tls_version                         = var.min_tls_version
  shares                                  = var.shares
  shared_access_key_enabled               = var.shared_access_key_enabled

  depends_on = [module.base]
}