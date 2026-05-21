output "api_id" {
  description = "The resource ID of the APIM API."
  value       = azurerm_api_management_api.this.id
}

output "api_name" {
  description = "The name of the APIM API."
  value       = azurerm_api_management_api.this.name
}

output "product_id" {
  description = "The resource ID of the APIM product."
  value       = azurerm_api_management_product.this.id
}

output "product_name" {
  description = "The product_id (name) of the APIM product."
  value       = azurerm_api_management_product.this.product_id
}

output "subscription_id" {
  description = "The resource ID of the APIM subscription."
  value       = azurerm_api_management_subscription.this.id
}

output "subscription_primary_key" {
  description = "The primary key of the APIM subscription."
  value       = azurerm_api_management_subscription.this.primary_key
  sensitive   = true
}

output "subscription_secondary_key" {
  description = "The secondary key of the APIM subscription."
  value       = azurerm_api_management_subscription.this.secondary_key
  sensitive   = true
}
