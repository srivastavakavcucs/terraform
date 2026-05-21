# Ensure AKS identity has access to Redis
# resource "azurerm_role_assignment" "aks_redis" {
#   scope                = data.azurerm_redis_cache.redis.id
#   role_definition_name = "Redis Cache Contributor"
#   principal_id         = data.azurerm_user_assigned_identity.aks_identity.principal_id
#   depends_on           = [azurerm_kubernetes_cluster.this]
# }

# Assign 'AcrPull' role to the AKS Managed Identity
resource "azurerm_role_assignment" "aks_acr" {
  scope                = data.azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = data.azurerm_user_assigned_identity.aks_identity.principal_id # 👈 Dynamically assigns AKS Managed Identity
  depends_on           = [azurerm_kubernetes_cluster.this]
}

# Assign 'Key Vault Secrets User' role to the AKS Managed Identity
resource "azurerm_role_assignment" "aks_kv" {
  scope                = data.azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = data.azurerm_user_assigned_identity.aks_identity.principal_id # 👈 Dynamically assigns AKS Managed Identity
  depends_on           = [azurerm_kubernetes_cluster.this]
}

# Assign 'azfs read write' role to the AKS Managed Identity
resource "azurerm_role_assignment" "aks_azfs" {
  scope                = data.azurerm_storage_account.storage.id
  role_definition_name = "Storage File Data SMB Share Contributor"
  principal_id         = data.azurerm_user_assigned_identity.aks_identity.principal_id # 👈 Dynamically assigns AKS Managed Identity
  depends_on           = [azurerm_kubernetes_cluster.this]
}


# resource "azurerm_role_assignment" "aks_pgsql" {
#   scope                = data.azurerm_postgresql_flexible_server.pgsql.id
#   role_definition_name = "Contributor"
#   principal_id         = data.azurerm_user_assigned_identity.aks_identity.principal_id
#   depends_on           = [azurerm_kubernetes_cluster.this]
# }
