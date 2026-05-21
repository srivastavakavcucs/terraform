# Use Managed Identity Instead of Service Principal
data "azurerm_user_assigned_identity" "aks_identity" {
  name                = var.aks_identity_name
  resource_group_name = var.aks_identity_rg_name
}

# Look up the AKS private DNS zone in the other subscription
data "azurerm_private_dns_zone" "aks_private_dns" {
  provider            = azurerm.private_dns_zone_subscription_provider
  name                = var.aks_private_dns_name
  resource_group_name = var.aks_private_dns_shared_rg_name
}

# Look up the existing ACR
data "azurerm_container_registry" "acr" {
  name                = var.connected_acr_name
  resource_group_name = var.connected_acr_rg_name
}

# Existing postgreSQL data lookup (from your earlier input)
# data "azurerm_postgresql_flexible_server" "pgsql" {
#   name                = var.connected_pgsql_name
#   resource_group_name = var.connected_pgsql_rg_name
# }

data "azurerm_storage_account" "storage" {
  name                = var.connected_storage_name
  resource_group_name = var.connected_storage_rg_name
}

# Existing Redis data lookup (from your earlier input)
# data "azurerm_redis_cache" "redis" {
#   name                = var.connected_redis_name
#   resource_group_name = var.connected_redis_rg_name
# }

data "azurerm_key_vault" "kv" {
  name                = var.connected_kv_name
  resource_group_name = var.connected_kv_rg_name
}

data "azurerm_resource_group" "shared01" {
  provider = azurerm.private_dns_zone_subscription_provider
  name     = var.aks_ingress_private_dns_shared_rg_name
}

data "azurerm_private_dns_zone" "aks_ingress_dns_local" {
  provider            = azurerm.private_dns_zone_subscription_provider
  name                = var.aks_ingress_private_dns_name
  resource_group_name = data.azurerm_resource_group.shared01.name
}