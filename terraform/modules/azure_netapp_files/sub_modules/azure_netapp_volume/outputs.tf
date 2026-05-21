#---------------------------------------------------------------------------------
# Output values that will be needed for other modules
#---------------------------------------------------------------------------------

output "az_netapp_volume_id" {
  value = azurerm_netapp_volume.anf_volume.id
}