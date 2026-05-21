#-----------------------------------------------------------------------------------------
# Output details about the Azure Private Endpoint that was provisioned.
#-----------------------------------------------------------------------------------------

output "id" {
  description = "The ID of the private endpoint."
  value       = module.azure_private_endpoint.resource_id
}

output "name" {
  description = "The name of the private endpoint."
  value       = module.azure_private_endpoint.name
}

output "resource_group_name" {
  description = "The Azure resource group name into which of the Private Endpoint was deployed."
  value       = module.base.resource_group_name
}

output "resource" {
  description = "The private endpoint resource."
  value       = module.azure_private_endpoint.resource
}

