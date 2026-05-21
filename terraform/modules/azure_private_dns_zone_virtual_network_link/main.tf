
#---------------------------------------------------------
# Create a Private DNS Zone virtual Network Link
# if it doesn't exist as each VNet can only have one
# Virtual Network Link to a private DNS zone.
#
# STEP 1:
# Check if the Private DNS Zone virtual Network Link exists
#---------------------------------------------------------

# data "azurerm_private_dns_zone_virtual_network_link" "existing" {
#   name                  = "link-${module.base.vnet_name}-${var.private_dns_zone_name}"
#   resource_group_name   = var.private_dns_zone_resource_group_name
#   private_dns_zone_name = var.private_dns_zone_name
# }

# locals {
#   sanitized_dns_zone_name = replace(var.private_dns_zone_name, ".", "-")
# }

#----------------------------------------------------------
# Step 2:
# Create a Private DNS Zone Virtual Network link if one
# doesn't exist already.
#---------------------------------------------------------

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  # count = length(data.azurerm_private_dns_zone_virtual_network_link.existing) == 0 ? 1 : 0
  name                  = "link-${module.base.vnet_name}"
  private_dns_zone_name = var.private_dns_zone.name
  resource_group_name   = var.private_dns_zone.resource_group_name
  virtual_network_id    = data.azurerm_virtual_network.this.id
  registration_enabled  = var.registration_enabled
  tags                  = module.base.tags

  # Exported attribute
  lifecycle {
    create_before_destroy = true
  }

  # Specify the provider alias for the private DNS zone subscription
  provider = azurerm.private_dns_zone_subscription_provider

  # Forcing dependencies and deployment order to allow the resource group to be deployed first.
  depends_on = [module.base]
}

