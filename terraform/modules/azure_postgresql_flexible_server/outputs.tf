#---------------------------------------------------------------------------------------------
# Output details about the Azure Database for PostgreSQL Flexible Server that was provisioned.
#---------------------------------------------------------------------------------------------

output "name" {
  description = "The name of the PostgreSQL Flexible Server."
  value       = module.azure_postgresql_flexible_server.name
}

output "fqdn" {
  description = "The fully qualified domain name (FQDN) of the PostgreSQL Flexible Server."
  value       = module.azure_postgresql_flexible_server.fqdn
}

output "resource_group_name" {
  description = "The Azure resource group name into which of the key vault was deployed."
  value       = module.base.resource_group_name
}

output "private_endpoints" {
  description = "A map of the private endpoints created for the PostgreSQL Flexible Server."
  value       = module.azure_postgresql_flexible_server.private_endpoints
}

output "resource_id" {
  description = "The resource ID for the PostgreSQL Flexible Server."
  value       = module.azure_postgresql_flexible_server.resource_id
}

output "database_resource_ids" {
  description = "A map of database keys to resource IDs for the PostgreSQL Flexible Server."
  value       = module.azure_postgresql_flexible_server.database_resource_ids
}