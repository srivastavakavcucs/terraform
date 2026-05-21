#-----------------------------------------------------------------------------------------
# Output details about the Azure API Management that was provisioned.
#-----------------------------------------------------------------------------------------

output "name" {
  description = "The name of the created API Management service."
  value       = azurerm_api_management.this.name
}

output "resource_group_name" {
  description = "The Azure resource group name into which of the API Management instance was deployed."
  value       = module.base.resource_group_name
}

output "id" {
  description = "The ID of the created API Management service."
  value       = azurerm_api_management.this.id
}

output "gateway_url" {
  description = "The gateway URL of the API Management service."
  value       = azurerm_api_management.this.gateway_url
}
