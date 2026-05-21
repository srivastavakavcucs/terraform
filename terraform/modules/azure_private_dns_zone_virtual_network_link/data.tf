
#------------------------------------------------------------------------
# Data source to retrieve the remote VNet details.
#------------------------------------------------------------------------
data "azurerm_virtual_network" "this" {
  name                = module.base.vnet_name
  resource_group_name = module.base.vnet_resource_group_name

  provider = azurerm
}
