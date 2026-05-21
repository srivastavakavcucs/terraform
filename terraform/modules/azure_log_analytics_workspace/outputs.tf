#-----------------------------------------------------------------------------------------
# Output details about the Azure Log Analytics Workspace that was provisioned.
#-----------------------------------------------------------------------------------------

output "name" {
  description = "The name of the Azure Log Analytics Workspace that was created."
  value       = local.log_analytics_workspace_name
}

output "resource_group_name" {
  description = "The Azure resource group name into which of the Azure Log Analytics Workspace that was deployed."
  value       = module.base.resource_group_name
}

output "resource_id" {
  description = "The ID of the Azure Log Analytics Workspace."
  value       = module.azure-log-Analytics-workspace.resource_id
}

output "resource" {
  description = "The Azure resource of the Azure Log Analytics Workspace that was deployed."
  value       = module.azure-log-Analytics-workspace.resource
}

output "private_endpoints" {
  description = "The Private Endpoints of the Azure Log Analytics Workspace that was deployed."
  value       = module.azure-log-Analytics-workspace.private_endpoints
}

