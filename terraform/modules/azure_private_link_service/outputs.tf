#-----------------------------------------------------------------------------------------
# Output details about the Azure Private Link Service that was provisioned.
#-----------------------------------------------------------------------------------------

output "name" {
  description = "The name of the Azure Private Link Service that was created."
  value       = azurerm_private_link_service.this.name
}

output "resource_group_name" {
  description = "The Azure resource group name into which of the Private Link Service was deployed."
  value       = module.base.resource_group_name
}

output "id" {
  description = "The ID of the Private Link Service."
  value       = azurerm_private_link_service.this.id
}
