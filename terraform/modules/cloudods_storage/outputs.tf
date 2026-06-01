#------------------------------------------------------------------------
# Storage Account Outputs
#------------------------------------------------------------------------

output "storage_account_id" {
  description = "The ID of the CloudODS Storage Account."
  value       = module.storage_account.resource_id
}

output "storage_account_name" {
  description = "The name of the CloudODS Storage Account."
  value       = module.storage_account.name
}

output "storage_account_primary_blob_endpoint" {
  description = "The primary blob endpoint of the Storage Account."
  value       = module.storage_account.primary_blob_endpoint
  sensitive   = false
}

output "storage_account_primary_connection_string" {
  description = "The primary connection string of the Storage Account (sensitive)."
  value       = module.storage_account.storage_account_primary_connection_string
  sensitive   = true
}

output "storage_account_location" {
  description = "The location of the Storage Account."
  value       = module.storage_account.location
}

output "storage_account_resource_group_name" {
  description = "The resource group name of the Storage Account."
  value       = module.storage_account.resource_group_name
}

#------------------------------------------------------------------------
# Blob Container Outputs
#------------------------------------------------------------------------

output "landing_container_id" {
  description = "The ID of the landing blob container for CFM file drops."
  value       = azurerm_storage_container.landing.id
}

output "landing_container_name" {
  description = "The name of the landing blob container."
  value       = azurerm_storage_container.landing.name
}

output "configuration_container_id" {
  description = "The ID of the configuration blob container for pipeline config files."
  value       = azurerm_storage_container.configuration.id
}

output "configuration_container_name" {
  description = "The name of the configuration blob container."
  value       = azurerm_storage_container.configuration.name
}

#------------------------------------------------------------------------
# Key Vault Secrets Outputs
#------------------------------------------------------------------------

output "key_vault_secret_connection_string_id" {
  description = "The ID of the Key Vault secret containing the storage account connection string."
  value       = azurerm_key_vault_secret.storage_account_connection_string.id
}

output "key_vault_secret_storage_account_name_id" {
  description = "The ID of the Key Vault secret containing the storage account name."
  value       = azurerm_key_vault_secret.storage_account_name.id
}

output "key_vault_secret_blob_endpoint_id" {
  description = "The ID of the Key Vault secret containing the primary blob endpoint."
  value       = azurerm_key_vault_secret.blob_endpoint.id
}

#------------------------------------------------------------------------
# Blob Properties Outputs
#------------------------------------------------------------------------

output "blob_versioning_enabled" {
  description = "Whether blob versioning is enabled on the Storage Account."
  value       = azurerm_storage_account_blob_properties.blob_properties.versioning_enabled
}

output "blob_delete_retention_days" {
  description = "Number of days soft-deleted blobs are retained."
  value       = azurerm_storage_account_blob_properties.blob_properties.delete_retention_policy[0].days
}
