/*
--------------------------------------------------------------------------------
  MODULE OUTPUTS
--------------------------------------------------------------------------------
*/

output "application_id" {
  description = "The ID of the Service Fabric application"
  value       = azapi_resource.sfmc_application.id
}

output "application_name" {
  description = "The name of the Service Fabric application"
  value       = azapi_resource.sfmc_application.name
}

output "application_type_id" {
  description = "The ID of the Service Fabric application type"
  value       = azapi_resource.sfmc_app_type.id
}

output "application_type_version_id" {
  description = "The ID of the Service Fabric application type version"
  value       = azapi_resource.sfmc_app_type_version.id
}

output "service_ids" {
  description = "Map of service names to their resource IDs"
  value       = { for k, v in azapi_resource.sfmc_services : k => v.id }
}
