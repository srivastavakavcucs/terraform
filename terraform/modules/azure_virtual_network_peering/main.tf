#---------------------------------------------------------------------------------
# Main VNet Peering Resource - Handles both local-to-remote and reverse peering
#---------------------------------------------------------------------------------

resource "azurerm_virtual_network_peering" "internal_local_to_remote_vnet_peering" {
  #---------------------------------------------------------------------------------
  # Local to remote Peering
  #---------------------------------------------------------------------------------

  provider                  = azurerm.local
  name                      = "vp-${data.azurerm_virtual_network.local_vnet.name}-${data.azurerm_virtual_network.remote_vnet.name}"
  resource_group_name       = data.azurerm_virtual_network.local_vnet.resource_group_name
  virtual_network_name      = data.azurerm_virtual_network.local_vnet.name
  remote_virtual_network_id = data.azurerm_virtual_network.remote_vnet.id

  allow_virtual_network_access = var.local_allow_virtual_network_access
  allow_forwarded_traffic      = var.local_allow_forwarded_traffic
  use_remote_gateways          = var.local_use_remote_gateways
  allow_gateway_transit        = var.local_allow_gateway_transit

  # Conditionally pass in local subnet names only if the length is greater than 0
  # dynamic "local_subnet_names" {
  #   for_each = length(var.local_subnet_names) > 0 ? [true] : []
  #   content {
  #     value = var.local_subnet_names
  #   }
  # }

  # Conditionally pass in remote subnet names only if the length is greater than 0
  # dynamic "remote_subnet_names" {
  #   for_each = length(var.remote_subnet_names) > 0 ? [true] : []
  #   content {
  #     value = var.remote_subnet_names
  #   }
  # }
}

resource "azurerm_virtual_network_peering" "internal_remote_to_local_vnet_peering" {
  #---------------------------------------------------------------------------------
  # Reverse Peering (Remote to Local)
  #---------------------------------------------------------------------------------
  provider                  = azurerm.remote
  name                      = "vp-${data.azurerm_virtual_network.remote_vnet.name}-${data.azurerm_virtual_network.local_vnet.name}"
  resource_group_name       = data.azurerm_virtual_network.remote_vnet.resource_group_name
  virtual_network_name      = data.azurerm_virtual_network.remote_vnet.name
  remote_virtual_network_id = data.azurerm_virtual_network.local_vnet.id

  allow_virtual_network_access = var.remote_allow_virtual_network_access
  allow_forwarded_traffic      = var.remote_allow_forwarded_traffic
  use_remote_gateways          = var.remote_use_remote_gateways
  allow_gateway_transit        = var.remote_allow_gateway_transit

  # Conditionally pass in local subnet names only if the length is greater than 0
  # dynamic "local_subnet_names" {
  #   for_each = length(var.remote_subnet_names) > 0 ? [true] : []
  #   content {
  #     value = var.remote_subnet_names
  #   }
  # }

  # Conditionally pass in remote subnet names only if the length is greater than 0
  # dynamic "remote_subnet_names" {
  #   for_each = length(var.local_subnet_names) > 0 ? [true] : []
  #   content {
  #     value = var.local_subnet_names
  #   }
  # }

  depends_on = [azurerm_virtual_network_peering.internal_local_to_remote_vnet_peering]
}

resource "null_resource" "vnet_peering" {
  # This resource does nothing but ensures both peering and reverse peering are completed.
  # First Remote then local should be completed.
  depends_on = [
    azurerm_virtual_network_peering.internal_remote_to_local_vnet_peering,
    azurerm_virtual_network_peering.internal_local_to_remote_vnet_peering
  ]
}
