#-------------------------------------------------------------------------
# Create the Azure NetApp Account Configuration
#-------------------------------------------------------------------------
module "netapp_account" {
  source = "./sub_modules/azure_netapp_account"

  name                = "anf-account-${var.app_name}-${var.environment}-${var.region}-${var.environment_number_suffix}"
  location            = module.base.location
  resource_group_name = module.base.resource_group_name
  tags                = module.base.tags

  depends_on = [module.base]
}