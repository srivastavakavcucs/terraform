#-------------------------------------------------------------------------
# Create the Azure NetApp Pool Configuration
#-------------------------------------------------------------------------
resource "azurerm_netapp_pool" "anf_pool" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  account_name  = var.account_name
  service_level = var.service_level
  size_in_tb    = var.pool_size
}