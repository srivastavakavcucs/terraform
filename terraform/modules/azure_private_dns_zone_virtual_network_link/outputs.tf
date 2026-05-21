#-----------------------------------------------------------------------------------------
# Output details about the Private DNS Zone Virtual Network Link that was provisioned.
#-----------------------------------------------------------------------------------------

output "name" {
  description = "The name of the Private DNS Zone Virtual Network Link that was created."
  value       = azurerm_private_dns_zone_virtual_network_link.this.name
}

output "resource_group_name" {
  description = "The Azure resource group name into which of the Private DNS Zone Virtual Network Link was deployed."
  value       = module.base.resource_group_name
}

output "id" {
  description = "The ID of the Private DNS Zone Virtual Network Link."
  value       = azurerm_private_dns_zone_virtual_network_link.this.id
}
