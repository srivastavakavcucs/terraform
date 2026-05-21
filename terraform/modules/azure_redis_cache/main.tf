module "redis_cache" {
  source  = "Azure/avm-res-cache-redis/azurerm"
  version = "0.3.0"

  #-------------------------------------------------------------------------------------------
  # Naming Standards Document: Azure Naming and Tagging Standards v4.0.0.0_20241022
  # Redis : redis-<subscription purpose>-<region>-<###>
  # Example: redis-omb-dev-001
  #          redis-corebnk-prod-001
  #-------------------------------------------------------------------------------------------

  # Required inputs
  location            = module.base.location
  name                = "redis-${module.base.app_name}-${module.base.environment}-${module.base.environment_number_suffix}"
  resource_group_name = module.base.resource_group_name

  # Optional inputs with defaults
  cache_access_policies                   = var.cache_access_policies
  cache_access_policy_assignments         = var.cache_access_policy_assignments
  cache_firewall_rules                    = var.cache_firewall_rules
  capacity                                = var.capacity
  diagnostic_settings                     = module.base.diagnostic_settings
  enable_non_ssl_port                     = var.enable_non_ssl_port
  enable_telemetry                        = module.base.enable_telemetry
  linked_redis_caches                     = var.linked_redis_caches
  lock                                    = module.base.lock
  managed_identities                      = var.managed_identities
  minimum_tls_version                     = "1.2" # Force TLS version 1.2 or higher
  patch_schedule                          = var.patch_schedule
  private_endpoints                       = module.base.private_endpoints
  private_endpoints_manage_dns_zone_group = var.private_endpoints_manage_dns_zone_group
  private_static_ip_address               = var.private_static_ip_address
  public_network_access_enabled           = var.public_network_access_enabled
  redis_configuration                     = var.redis_configuration
  redis_version                           = var.redis_version
  replicas_per_master                     = var.replicas_per_master
  replicas_per_primary                    = var.replicas_per_primary
  role_assignments                        = module.base.role_assignments
  shard_count                             = var.shard_count
  sku_name                                = var.sku_name
  subnet_resource_id                      = var.subnet_resource_id
  tags                                    = module.base.tags
  tenant_settings                         = var.tenant_settings
  zones                                   = var.zones

  # Forcing dependencies and deployment order to allow the resource group to be deployed first.
  depends_on = [module.base]
}
