#-------------------------------------------------------------------------------------------
# Data block that retrieves the default VNet and Subnet information.
# NOTE: Default provider is used for main resources (VNet, Subnet, DNS Zones, etc.)
#-------------------------------------------------------------------------------------------

# Data source for Virtual Network, conditional if the private endpoints map or
# the subnet name segments list is passed into the module.
data "azurerm_virtual_network" "this" {
  for_each = (length(var.private_endpoints) > 0 || length(var.subnet_name_segments) > 0) ? { "fetch" = true } : {}

  name                = local.vnet_name
  resource_group_name = local.vnet_resource_group_name
}

# Data source for Subnets, conditional on Virtual Network data
data "azurerm_subnet" "subnets" {
  for_each = length(data.azurerm_virtual_network.this) > 0 ? {
    for subnet_name in data.azurerm_virtual_network.this["fetch"].subnets :
    subnet_name => subnet_name
  } : {}

  name                 = each.value
  virtual_network_name = data.azurerm_virtual_network.this["fetch"].name
  resource_group_name  = data.azurerm_virtual_network.this["fetch"].resource_group_name
}

# Data source for Private DNS Zones, conditional on private endpoints variable passed into the module.
data "azurerm_private_dns_zone" "this" {
  for_each = {
    for endpoint_key, endpoint in var.private_endpoints :
    endpoint_key => endpoint.private_dns_zones
  }

  provider            = azurerm.private_dns_zone_subscription_provider
  name                = each.value[0].name
  resource_group_name = each.value[0].resource_group_name
}