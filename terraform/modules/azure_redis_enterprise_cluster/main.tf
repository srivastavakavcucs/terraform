#-------------------------------------------------------------------------
# Documentation: https://registry.terraform.io/providers/hashicorp/azurerm/4.3.0/docs/resources/redis_enterprise_cluster
#-------------------------------------------------------------------------

// Define local variables
locals {
  // Combine common tags and resource-specific tags into a single map
  combined_vars = merge(var.common_tags, var.resource_tags)
}

// Output the combined tags for verification and debugging purposes
output "combined_vars" {
  value = local.combined_vars
}

locals {
  zones_list = [for zone in var.zones : tonumber(zone)]
}

// Define the Azure Redis Enterprise Cluster resource
resource "azurerm_redis_enterprise_cluster" "redis_enterprise_cluster" {
  // The name of the Redis Enterprise Cluster
  name = var.redis_enterprise_cluster_name

  // The location where the Redis Enterprise Cluster will be deployed
  location = var.location

  // The name of the resource group that will contain the Redis Enterprise Cluster
  resource_group_name = var.rg_name

  // The SKU (pricing tier) for the Redis Enterprise Cluster
  sku_name = var.sku_name

  // The minimum TLS version required for connections to the Redis Enterprise Cluster
  minimum_tls_version = var.minimum_tls_version

  // The availability zones for the Redis Enterprise Cluster
  zones = local.zones_list

  // Tags to assign to the Redis Enterprise Cluster, combining common and resource-specific tags
  tags = local.combined_vars
}
