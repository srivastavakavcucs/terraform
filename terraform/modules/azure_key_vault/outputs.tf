#-----------------------------------------------------------------------------------------
# Output details about the Azure Key Vault that was provisioned.
#-----------------------------------------------------------------------------------------

output "name" {
  description = "The name of the Azure Key Vault that was created."
  value       = local.key_vault_name
}

output "resource_group_name" {
  description = "The Azure resource group name into which of the key vault was deployed."
  value       = module.base.resource_group_name
}

output "resource_id" {
  description = "The Azure resource id of the key vault."
  value       = module.azure-keyvault.resource_id
}

output "private_endpoints" {
  description = "A map of private endpoints"
  value       = module.azure-keyvault.private_endpoints
}

output "uri" {
  description = "The URI of the vault for performing operations on keys and secrets"
  value       = module.azure-keyvault.uri
}

output "keys_resource_ids" {
  description = "A map of key keys to resource ids."
  value       = module.azure-keyvault.keys_resource_ids
}

output "secrets_resource_ids" {
  description = "A map of secret keys to resource ids."
  value       = module.azure-keyvault.secrets_resource_ids
}