#---------------------------------------------------------------------------------
# Output values from the sub modules
#---------------------------------------------------------------------------------

output "az_netapp_account_id" {
  value = module.netapp_account.az_netapp_account_id
}

output "az_netapp_account_name" {
  value = module.netapp_account.az_netapp_account_name
}

output "az_netapp_pool_id" {
  value = module.netapp_pool.az_netapp_pool_id
}

output "az_netapp_pool_name" {
  value = module.netapp_pool.az_netapp_pool_name
}

output "az_netapp_volume_id" {
  value = module.netapp_volume.az_netapp_volume_id
}