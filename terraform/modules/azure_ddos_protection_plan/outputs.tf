# Outputs for the DDOS Protection Plan Module

output "id" {
  description = "The ID of the created DDOS Protection Plan."
  value       = module.azure_ddos_protection_plan.resource.id
}

output "name" {
  description = "The name of the created DDOS Protection Plan."
  value       = local.ddos_protection_plan_name
}

output "resource_group_name" {
  description = "The resource group name where the DDOS Protection Plan is deployed."
  value       = module.base.resource_group_name
}

output "resource" {
  description = "The DDOS Protection Plan resource that was is deployed."
  value       = module.azure_ddos_protection_plan.resource
}

output "location" {
  description = "The location of the DDOS Protection Plan."
  value       = module.base.location
}
