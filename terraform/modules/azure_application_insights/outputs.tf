#-----------------------------------------------------------------------------------------
# Output details about the Azure Application Insights that was provisioned.
#-----------------------------------------------------------------------------------------

output "name" {
  description = "Name of the Application Insights"
  value       = module.app_insights.name
}

output "resource_group_name" {
  description = "The Azure resource group name into which of the App Gateway was deployed."
  value       = module.base.resource_group_name
}

output "resource_id" {
  description = "The ID of the Application Insights"
  value       = module.app_insights.resource_id
}

output "resource" {
  description = "This is the full output for the resource."
  value       = module.app_insights.resource
}

output "app_id" {
  description = "App ID of the Application Insights"
  value       = module.app_insights.app_id
}

output "connection_string" {
  description = "Connection String of the Application Insights"
  value       = module.app_insights.connection_string
}

output "instrumentation_key" {
  description = "Instrumentation Key of the Application Insights"
  value       = module.app_insights.instrumentation_key
}
