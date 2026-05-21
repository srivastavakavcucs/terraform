output "storage_account_name" {
  description = "The name of the Storage Account"
  value       = module.storage_account.name
}

output "storage_account_rg" {
  description = "The resource group name of the Storage Account"
  value       = module.base.resource_group_name
}

output "storage_account_location" {
  description = "The location of the Storage Account"
  value       = module.base.location
}

output "resource_id" {
  description = "Resource ID of the Azure Files."
  value       = module.storage_account.resource_id
}

output "private_endpoints" {
  description = "Private Endpoints that were created for the Azure Files."
  value       = module.storage_account.private_endpoints
}