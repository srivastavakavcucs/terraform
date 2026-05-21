#-------------------------------------------------------------------------
# Create the Azure NetApp Account Configuration
#-------------------------------------------------------------------------
resource "azurerm_netapp_account" "anf_account" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}