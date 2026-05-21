resource "azurerm_redis_enterprise_database" "redis_enterprise_database" {
  name                           = var.redis_enterprise_database_name
  cluster_id                     = var.cluster_id
  client_protocol                = var.client_protocol
  clustering_policy              = var.clustering_policy
  eviction_policy                = var.eviction_policy
  linked_database_id             = var.linked_database_id
  linked_database_group_nickname = var.linked_database_group_nickname
  port                           = var.port

  dynamic "module" {

    for_each = var.module_db

    content {
      name = module.value.name
    }
  }
}
