#-------------------------------------------------------------------------
# Create the Azure NetApp Volume Configuration
#-------------------------------------------------------------------------

resource "azurerm_netapp_volume" "anf_volume" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  zone                       = var.zone
  account_name               = var.account_name
  pool_name                  = var.pool_name
  volume_path                = var.volume_path
  service_level              = var.service_level
  subnet_id                  = var.subnet_id
  network_features           = var.network_features
  protocols                  = var.protocols
  security_style             = var.security_style
  storage_quota_in_gb        = var.storage_quota_in_gb
  snapshot_directory_visible = var.snapshot_directory_visible

  export_policy_rule {
    rule_index        = var.rule_index
    allowed_clients   = var.allowed_clients
    protocols_enabled = var.protocols_enabled
    unix_read_write   = var.unix_read_write
  }

  # prevent the possibility of accidental data loss
  # Before release set this to true
  lifecycle {
    prevent_destroy = false
  }
}
