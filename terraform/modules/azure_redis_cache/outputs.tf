#-----------------------------------------------------------------------------------------
# Output details about the Azure Redis Cache Cluster that was provisioned.
#-----------------------------------------------------------------------------------------

output "name" {
  description = "The name of the Redis Cache resource."
  value       = module.redis_cache.name
}

output "resource_group_name" {
  description = "The name of resource group that the Redis Cache resource is deployed."
  value       = module.base.resource_group_name
}

output "resource_id" {
  description = "The resource ID of the Redis Cache instance."
  value       = module.redis_cache.resource_id
}

output "resource" {
  description = "The complete resource object for the Redis Cache."
  value       = module.redis_cache.resource
}

output "private_endpoints" {
  description = "A map of private endpoints associated with the Redis Cache."
  value       = module.redis_cache.private_endpoints
}
