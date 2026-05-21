#---------------------------------------------------------------------------------
# Output important values required for other modules
#---------------------------------------------------------------------------------

output "az_netapp_account_id" {
  value = azurerm_netapp_account.anf_account.id
}

output "az_netapp_account_name" {
  value = azurerm_netapp_account.anf_account.name
}