module "netapp_pool" {
  source = "./sub_modules/azure_netapp_pool"

  name                = "anf-pool-${var.app_name}-${var.environment}-${var.region}-${var.environment_number_suffix}"
  location            = module.base.location
  resource_group_name = module.base.resource_group_name
  tags                = module.base.tags

  account_name  = module.netapp_account.az_netapp_account_name
  service_level = var.pool_service_level
  pool_size     = var.pool_size

  depends_on = [module.base, module.netapp_account]
}