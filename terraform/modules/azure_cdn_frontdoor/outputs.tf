#-----------------------------------------------------------------------------------------
# Output details about the Azure CDN Front Door that was provisioned.
#-----------------------------------------------------------------------------------------

output "name" {
  description = "The name of the Azure CDN FrontDoor instance that was created."
  value       = try(module.cdn_profile.resource_name, null)
}

output "resource_group_name" {
  description = "The Azure resource group name into which of the Azure CDN FrontDoor was deployed."
  value       = module.base.resource_group_name
}

output "resource_id" {
  description = "The Azure resource id of the the Azure CDN FrontDoor."
  value       = try(module.cdn_profile.resource_id, null)
}

output "cdn_endpoint_custom_domains" {
  description = "CDN endpoint custom domains output object"
  value       = try(module.cdn_profile.cdn_endpoint_custom_domains, {})
}

output "cdn_endpoints" {
  description = "CDN endpoint output object"
  value       = try(module.cdn_profile.cdn_endpoints, {})
}

output "front_door_custom_domains" {
  description = "Azure Front Door custom domains output object"
  value       = try(module.cdn_profile.front_door_custom_domains, {})
}

output "front_door_endpoints" {
  description = "Azure Front Door endpoint output object"
  value       = try(module.cdn_profile.front_door_endpoints, {})
}

output "front_door_firewall_policies" {
  description = "Azure Front Door firewall policies output object"
  value       = try(module.cdn_profile.front_door_firewall_policies, {})
}

output "front_door_origin_groups" {
  description = "Azure Front Door origin groups output object"
  value       = try(module.cdn_profile.front_door_origin_groups, {})
}

output "front_door_origins" {
  description = "Azure Front Door origins output object"
  value       = try(module.cdn_profile.front_door_origins, {})
}

output "front_door_rule_sets" {
  description = "Azure Front Door rule sets output object"
  value       = try(module.cdn_profile.front_door_rule_sets, {})
}

output "front_door_rules" {
  description = "Azure Front Door rules output object"
  value       = try(module.cdn_profile.front_door_rules, {})
}

output "front_door_security_policies" {
  description = "Azure Front Door security policies output object"
  value       = try(module.cdn_profile.front_door_security_policies, {})
}

output "resource" {
  description = "Full resource output object"
  value       = try(module.cdn_profile.resource, {})
}

output "system_assigned_mi_principal_id" {
  description = "The system-assigned managed identity of the Front Door profile"
  value       = try(module.cdn_profile.system_assigned_mi_principal_id, null)
}