#----------------------------------------------------------------
# Retrieve the VNet and all the subnets in the VNet to find the
# Delegated Subnet to be used for the PostgreSQL Server.
#----------------------------------------------------------------

# Retrieve the VNet and all the subnets in the VNet
data "azurerm_virtual_network" "this" {
  name                = module.base.vnet_name
  resource_group_name = module.base.vnet_resource_group_name
}

# # Data source for Subnets, conditional on Virtual Network data
# data "azurerm_subnet" "subnets" {
#   count = length(data.azurerm_virtual_network.this.subnets)

#   name                 = data.azurerm_virtual_network.this.subnets[count.index]
#   virtual_network_name = module.base.vnet_name
#   resource_group_name  = module.base.vnet_resource_group_name
# }