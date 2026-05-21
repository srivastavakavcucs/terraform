module "netapp_volume" {
  source = "./sub_modules/azure_netapp_volume"

  name                = "anf-volume-${var.app_name}-${var.environment}-${var.region}-${var.environment_number_suffix}"
  location            = module.base.location
  resource_group_name = module.base.resource_group_name
  tags                = module.base.tags

  zone                       = var.zone
  account_name               = module.netapp_account.az_netapp_account_name
  pool_name                  = module.netapp_pool.az_netapp_pool_name
  volume_path                = var.volume_path
  service_level              = var.volume_service_level
  subnet_id                  = module.base.subnet_name_segments_to_subnet_id_map[var.delegated_subnet_name_segment]
  network_features           = var.network_features
  protocols                  = var.protocols
  security_style             = var.security_style
  storage_quota_in_gb        = var.storage_quota_in_gb
  snapshot_directory_visible = var.snapshot_directory_visible

  rule_index        = var.rule_index
  allowed_clients   = var.allowed_clients
  protocols_enabled = var.protocols_enabled
  unix_read_write   = var.unix_read_write

  depends_on = [module.base, module.netapp_account, module.netapp_pool]

}
