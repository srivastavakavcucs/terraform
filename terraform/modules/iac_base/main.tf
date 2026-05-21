#-------------------------------------------------------------------------------------------
# Output all validated variable values to be consumed in the various components modules.
#-------------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------------------
# Required variables
#-------------------------------------------------------------------------------------------

output "location" {
  description = "The Azure Region where the infrastructure Resource will be located."
  value       = local.region
}

output "region" {
  description = "The Azure Region where the infrastructure Resource will be located."
  value       = local.region
}

output "app_name" {
  description = "The abbreviated name of the VyStar application to use in Azure infrastructure naming."
  value       = local.app_name
}

output "component_name" {
  description = "Name of the Azure Component that is being deployed."
  value       = var.component_name
}

output "environment" {
  description = "The shortened environment moniker to use in Azure infrastructure naming. Example: 'dev',test' and 'prod'"
  value       = local.environment
}

output "environment_number_suffix" {
  description = "The environment number suffix to use in Azure infrastructure naming. Example: '001','002', etc."
  value       = local.environment_number_suffix
}

output "resource_group_name" {
  description = "The name of the resource group where the Azure Infrastructure component will be deployed, adhering to the VyStar naming conventions."
  value       = var.custom_resource_group_name != null && length(data.azurerm_resource_group.existing) > 0 ? data.azurerm_resource_group.existing[0].name : local.resource_group_name
}

output "vnet_name" {
  description = "The name of the Azure Virtual Network where the Azure Infrastructure component will be deployed, adhering to the VyStar naming conventions."
  value       = local.vnet_name
}

output "vnet_resource_group_name" {
  description = "The name of the Azure Virtual Network resource group where the Azure Infrastructure component will be deployed, adhering to the VyStar naming conventions."
  value       = local.vnet_resource_group_name
}

#-------------------------------------------------------------------------------------------
# Optional variables
#-------------------------------------------------------------------------------------------

output "diagnostic_settings" {
  description = "The diagnostic settings to apply to the Azure Infrastructure component during deployments."
  value       = local.diagnostic_settings
}

output "lock" {
  description = "The resource lock to apply to the Azure Infrastructure component that will be deployed."
  value       = local.lock
}

output "enable_telemetry" {
  description = "The variable that dictates whether the Azure Infrastructure component will enable telemetry."
  value       = local.enable_telemetry
}

output "role_assignments" {
  value = local.role_assignments
}

output "private_endpoints" {
  description = "The details of the private endpoint to create and attach to the Azure Infrastructure component will be deployed, adhering to the VyStar naming conventions."
  value       = local.private_endpoints
}

output "tags" {
  description = "The Azure tags to apply to the Azure Infrastructure component will be deployed, adhering to the VyStar standards."
  value       = local.enhanced_tags
}

output "subnet_name_segments_to_subnet_id_map" {
  description = "A map of the subnet name segment (key) and the actual infrastructure resource ID of the subnet in the VNet (value)."
  value       = local.subnet_name_segments_to_subnet_id_map
}

output "subnet_name_segments_to_subnet_name_map" {
  description = "A map of the subnet name segment (key) and the complete subnet name of the subnet in the VNet (value)."
  value       = local.subnet_name_segments_to_subnet_name_map
}

output "subnet_name_segments_to_subnet_info" {
  description = "A map of the subnet name segment (key) and the subnet information object containing the subnet name, ID and aroute table for the subnet in the VNet (value)."
  value       = local.subnet_name_segments_to_subnet_info
}

output "vnet_resource_id" {
  description = "The resource ID of the Azure Virtual Network resource group where the Azure Infrastructure component will be deployed, adhering to the VyStar naming conventions."
  value       = local.vnet_resource_id
}

#-------------------------------------------------------------------------------------------
# Version Number
#-------------------------------------------------------------------------------------------

output "version_number" {
  description = "The version number of the VyStar IaC Common Registry."
  value       = local.version_number
}
