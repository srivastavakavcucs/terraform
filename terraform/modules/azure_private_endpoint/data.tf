# Get the current subscription and tenant IDs
# data "azurerm_client_config" "current" {}

# Default provider is used for the main resources (VNet, Subnet, Private Endpoint, etc.)

# Aliased provider for the DNS zone subscription
# The provider is configured in provider.tf

# Data source for the Private Connection Resource
data "azurerm_resources" "private_connection_resource" {
  resource_group_name = var.private_connection_resource.resource_group_name
}

# Data source for Private DNS Zones
data "azurerm_private_dns_zone" "dns_zones" {
  for_each = {
    for dns_zone in var.private_dns_zones :
    dns_zone.name => dns_zone
  }

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  provider            = azurerm.private_dns_zone_subscription_provider
}
