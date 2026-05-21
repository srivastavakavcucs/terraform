#-----------------------------------------------------------------------------------------
# Output details about the Azure Virtual Network that was provisioned.
#-----------------------------------------------------------------------------------------

output "id" {
  description = "The ID of the virtual network."
  value       = module.azure_virtual_network.resource_id
}

output "name" {
  description = "The name of the virtual network."
  value       = module.azure_virtual_network.name
}

output "resource_group_name" {
  description = "The resource group name that contains the virtual network."
  value       = module.base.resource_group_name
}

output "address_space" {
  description = "The address space of the virtual network."
  value       = var.cidr
}

output "location" {
  description = "The location of the virtual network."
  value       = module.base.location
}

output "subnets" {
  description = "The name of the subnets in the virtual network."
  value       = module.azure_virtual_network.subnets
}
