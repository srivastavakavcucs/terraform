#-----------------------------------------------------------------------------------------
# Output details about the Azure App Configuration that was provisioned.
#-----------------------------------------------------------------------------------------

output "name" {
  description = "App Configuration name"
  value       = azurerm_app_configuration.this.name
}

output "resource_group_name" {
  description = "The Azure resource group name into which of the API Management instance was deployed."
  value       = module.base.resource_group_name
}

output "id" {
  description = "The ID of this App Configuration store."
  value       = azurerm_app_configuration.this.id
}

output "endpoint" {
  description = "The endpoint of this App Configuration store."
  value       = azurerm_app_configuration.this.endpoint
}

output "primary_read_key" {
  description = "The primary read key of this App Configuration store."
  value       = azurerm_app_configuration.this.primary_read_key
  sensitive   = true
}

output "primary_write_key" {
  description = "The primary write key of this App Configuration store."
  value       = azurerm_app_configuration.this.primary_write_key
  sensitive   = true
}

output "secondary_read_key" {
  description = "The secondary read key of this App Configuration store."
  value       = azurerm_app_configuration.this.secondary_read_key
  sensitive   = true
}

output "secondary_write_key" {
  description = "The secondary write key of this App Configuration store."
  value       = azurerm_app_configuration.this.secondary_write_key
  sensitive   = true
}

