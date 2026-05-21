#####################################
## Azure Redis Enterprise Cluster
#####################################
module "redis_enterprise_cluster" {
  source                        = "./../modules/azure_redis_enterprise_cluster"
  redis_enterprise_cluster_name = "vys-redis-enterprise-cluster-12345"
  location                      = module.resource_group.az_location
  rg_name                       = module.resource_group.az_resource_group_name
  sku_name                      = "Enterprise_E5-2"
  resource_tags                 = var.resource_tags
  common_tags                   = var.common_tags
  depends_on                    = [module.resource_group]
}

#####################################
## Azure Redis Enterprise Database
#####################################
module "redis_enterprise_database" {
  source                        = "./../modules/azure_redis_enterprise_database"
  redis_enterprise_database_name = "default"
  rg_name                       = module.resource_group.az_resource_group_name
  cluster_id                    = module.redis_enterprise_cluster.az_redis_enterprise_id
  client_protocol               = "Encrypted"
  clustering_policy             = "OSSCluster"
  eviction_policy               = "VolatileLRU"
  port                          = 10000
  linked_database_id            = []
  linked_database_group_nickname = ""
  resource_tags                 = var.resource_tags
  common_tags                   = var.common_tags
  module = {
    name = "RediSearch"
    args = "ERROR_RATE 0.00 INITIAL_SIZE 400"
  }
  depends_on                    = [module.redis_enterprise_cluster]
}

#####################################
## Azure Redis Enterprise Private Endpoint
#####################################
module "redis_enterprise_private_endpoint" {
  source                    = "./../modules/azure_private_endpoint"
  endpoint_name             = "redis-enterprise-pe-12345"
  location                  = module.resource_group.az_location
  rg_name                   = module.resource_group.az_resource_group_name
  subnet_id                 = module.pe_subnet.az_snet_id
  ps_connection_name        = "redis-enterprise-private-service-connection"
  ps_connection_resource_id = module.redis_enterprise_cluster.az_redis_enterprise_id
  sub_resource_names        = ["redisEnterprise"]
  is_manual_connection      = false
  resource_tags             = var.resource_tags
  common_tags               = var.common_tags
  depends_on                = [module.redis_enterprise_cluster]
}
