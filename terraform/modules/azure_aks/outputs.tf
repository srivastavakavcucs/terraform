output "resource_group_name" {
  value = azurerm_kubernetes_cluster.this.resource_group_name
}

output "aks_id" {
  value = azurerm_kubernetes_cluster.this.id
}

output "aks_fqdn" {
  value = azurerm_kubernetes_cluster.this.fqdn
}

output "aks_private_fqdn" {
  value = azurerm_kubernetes_cluster.this.private_fqdn
}

output "aks_node_rg" {
  value = azurerm_kubernetes_cluster.this.node_resource_group
}

output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.this.name
}

output "aks_cluster_oidc_issuer_url" {
  value = azurerm_kubernetes_cluster.this.oidc_issuer_url
}

output "aks_identity" {
  value = azurerm_kubernetes_cluster.this.identity
}

output "aks_pod_subnet_id" {
  value = azurerm_kubernetes_cluster.this.default_node_pool[0].pod_subnet_id
}

output "aks_kube_admin_config" {
  value     = azurerm_kubernetes_cluster.this.kube_admin_config_raw
  sensitive = true
}

# output "redis_server_name" {
#   value = data.azurerm_redis_cache.redis.name
# }

# output "redis_resource_group_name" {
#   value = data.azurerm_redis_cache.redis.resource_group_name
# }

output "aks_workload_identity" {
  value = data.azurerm_user_assigned_identity.aks_identity.id
}

output "aks_workload_identity_name" {
  value = data.azurerm_user_assigned_identity.aks_identity.name
}

output "aks_workload_identity_rg_name" {
  value = data.azurerm_user_assigned_identity.aks_identity.resource_group_name
}

output "aks_workload_identity_client_id" {
  value = data.azurerm_user_assigned_identity.aks_identity.client_id
}

output "aks_connected_acr" {
  value = data.azurerm_container_registry.acr.name
}

output "aks_connected_acr_rg" {
  value = data.azurerm_container_registry.acr.resource_group_name
}

# output "aks_connected_pgsql" {
#   value = data.azurerm_postgresql_flexible_server.pgsql.name
# }

# output "aks_connected_pgsql_rg" {
#   value = data.azurerm_postgresql_flexible_server.pgsql.resource_group_name
# }

output "aks_connected_kv" {
  value = data.azurerm_key_vault.kv.name
}

output "aks_connected_kv_rg" {
  value = data.azurerm_key_vault.kv.resource_group_name
}

# output "aks_connected_redis" {
#   value = data.azurerm_redis_cache.redis.name
# }

# output "aks_connected_redis_id" {
#   value = data.azurerm_redis_cache.redis.id
# }

# output "aks_connected_redis_rg" {
#   value = data.azurerm_redis_cache.redis.resource_group_name
# }

output "aks_connected_azfs" {
  value = data.azurerm_storage_account.storage.name
}

output "aks_connected_azfs_rg" {
  value = data.azurerm_storage_account.storage.resource_group_name
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.this.kube_config[0]
}

output "aks_ingress_local" {
  value = data.azurerm_private_dns_zone.aks_ingress_dns_local
}

output "aks_ingress_local_id" {
  value = data.azurerm_private_dns_zone.aks_ingress_dns_local.id
}


