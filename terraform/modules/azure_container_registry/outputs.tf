#-----------------------------------------------------------------------------------------
# Output details about the Azure Container Registry that was provisioned.
#-----------------------------------------------------------------------------------------

output "name" {
  description = "Name of the Azure Container Registry."
  value       = module.azure_container_registry.name
}

output "resource_group_name" {
  description = "Resource Group of the Azure Container Registry."
  value       = module.base.resource_group_name
}

output "resource_id" {
  description = "Resource ID of the Azure Container Registry."
  value       = module.azure_container_registry.resource_id
}

output "private_endpoints" {
  description = "Private Endpoints that were created for the Azure Container Registry."
  value       = module.azure_container_registry.private_endpoints
}

output "system_assigned_mi_principal_id" {
  description = "System Assigned MI Principal ID of the Azure Container Registry."
  value       = module.azure_container_registry.system_assigned_mi_principal_id
}
