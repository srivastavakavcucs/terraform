#---------------------------------------------------------------------------------
# Output values that are needed for other modules
#---------------------------------------------------------------------------------

output "az_netapp_pool_id" {
  value = azurerm_netapp_pool.anf_pool.id
}

output "az_netapp_pool_name" {
  value = azurerm_netapp_pool.anf_pool.name
}
