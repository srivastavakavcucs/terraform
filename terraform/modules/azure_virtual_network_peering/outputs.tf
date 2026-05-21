#-----------------------------------------------------------------------------------------
# Output details about the Azure Virtual Network Peering that was provisioned.
#-----------------------------------------------------------------------------------------

output "local_vnet_peering_name" {
  description = "The name of the local-to-remote VNet peering."
  value       = azurerm_virtual_network_peering.internal_local_to_remote_vnet_peering.name
}

output "local_vnet_peering_resource_group_name" {
  description = "The name of resource group of the local-to-remote VNet peering."
  value       = data.azurerm_virtual_network.local_vnet.resource_group_name
}

output "local_vnet_peering_id" {
  description = "The ID of the local-to-remote VNet peering."
  value       = azurerm_virtual_network_peering.internal_local_to_remote_vnet_peering.id
}

output "remote_vnet_peering_name" {
  description = "The name of the remote-to-local VNet peering."
  value       = azurerm_virtual_network_peering.internal_remote_to_local_vnet_peering.name
}

output "remote_vnet_peering_resource_group_name" {
  description = "The name of resource group of the remote-to-local peering."
  value       = data.azurerm_virtual_network.remote_vnet.resource_group_name
}

output "remote_vnet_peering_id" {
  description = "The ID of the remote-to-local VNet peering."
  value       = azurerm_virtual_network_peering.internal_remote_to_local_vnet_peering.id
}
