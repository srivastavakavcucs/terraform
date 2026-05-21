#---------------------------------------------------------------------------------
# Data blocks to retrieve local and remote virtual network details
#---------------------------------------------------------------------------------

# Data source to retrieve the local VNet details (ID, resource group, etc.)
data "azurerm_virtual_network" "local_vnet" {
  provider            = azurerm.local
  name                = var.local_virtual_network_name
  resource_group_name = var.local_resource_group_name
}

# Data source to retrieve the remote VNet details (ID, resource group, etc.)
data "azurerm_virtual_network" "remote_vnet" {
  provider            = azurerm.remote
  name                = var.remote_virtual_network_name
  resource_group_name = var.remote_resource_group_name
}
