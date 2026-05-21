data "azurerm_key_vault" "existing" {
  name                = var.existing_keyvault_name
  resource_group_name = var.existing_keyvault_resource_group
}
