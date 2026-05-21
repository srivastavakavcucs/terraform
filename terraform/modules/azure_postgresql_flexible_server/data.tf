#----------------------------------------------------------------
# Data source for Private DNS Zones in a different subscription,
# conditional on if the private DNS zone name if provided.
#----------------------------------------------------------------
data "azurerm_private_dns_zone" "this" {
  count = var.private_dns_zone != null ? 1 : 0

  provider            = azurerm.private_dns_zone_subscription_provider
  name                = var.private_dns_zone != null ? var.private_dns_zone.name : ""
  resource_group_name = var.private_dns_zone != null ? var.private_dns_zone.resource_group_name : ""
}

