#-----------------------------------------------------------------------------------------
# Output details about the Azure Route Rable that was provisioned.
#-----------------------------------------------------------------------------------------

output "id" {
  description = "The ID of the Route Table."
  value       = module.azure_route_table.resource_id
}

output "name" {
  description = "The name of the Route Table."
  value       = module.azure_route_table.name
}

output "resource_group_name" {
  description = "The resource group name of the Route Table."
  value       = module.base.resource_group_name
}
