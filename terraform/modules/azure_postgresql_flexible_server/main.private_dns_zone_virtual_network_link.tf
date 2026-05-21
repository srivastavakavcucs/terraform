#----------------------------------------------------------------------------------------
# A Private DNS Zone virtual Network Link is required for
# PostgreSQL Flexible Server to work with VNet integration
#----------------------------------------------------------------------------------------
# Action Performed:
#----------------------------------------------------------------------------------------
# Check if the Private DNS Zone virtual Network Link exists
# (The plan and apply will fail if this doesn't already exist)
#----------------------------------------------------------------------------------------
#                               :EXPECTED ERROR:
#----------------------------------------------------------------------------------------
#│ Error: Virtual Network Link (Subscription: "5f5b009f-8558-4997-b0f7-1ee499c768bc"
#│ Resource Group Name: "rg-private-dns-shared01-eu-vy"
#│ Private Dns Zone Name: "privatelink.postgres.database.azure.com"
#│ Virtual Network Link Name: "link-vnet-vystarsampleapp-dev-eastus-002") was not found
#----------------------------------------------------------------------------------------

data "azurerm_private_dns_zone_virtual_network_link" "existing" {
  count = var.private_dns_zone != null ? 1 : 0

  # name                  = "link-${module.base.vnet_name}"
  name                  = var.private_dns_zone_vnet_link_name
  resource_group_name   = var.private_dns_zone.resource_group_name
  private_dns_zone_name = var.private_dns_zone.name

  provider = azurerm.private_dns_zone_subscription_provider
}
