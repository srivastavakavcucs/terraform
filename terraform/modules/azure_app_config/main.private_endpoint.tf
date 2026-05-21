module "private_endpoints" {
  source  = "Azure/avm-res-network-privateendpoint/azurerm"
  version = "0.1.0"

  # Iterate over each private endpoint configuration
  for_each = module.base.private_endpoints

  location                                   = module.base.location
  name                                       = "pe-${var.app_name}-${module.base.resource_group_name}"
  resource_group_name                        = module.base.resource_group_name
  subnet_resource_id                         = each.value.subnet_resource_id
  private_connection_resource_id             = resource.azurerm_app_configuration.this.id
  network_interface_name                     = each.value.network_interface_name
  application_security_group_association_ids = toset(values(each.value.application_security_group_associations))
  enable_telemetry                           = module.base.enable_telemetry
  lock                                       = each.value.lock
  private_dns_zone_group_name                = each.value.private_dns_zone_group_name
  private_dns_zone_resource_ids              = tolist(each.value.private_dns_zone_resource_ids)
  private_service_connection_name            = each.value.private_service_connection_name
  role_assignments                           = each.value.role_assignments
  subresource_names                          = ["configurationStores"]

  ip_configurations = {
    for ip_key, ip_config in each.value.ip_configurations : ip_key => merge(ip_config, {
      subresource_name = "configurationStores"
    })
  }

  tags = module.base.tags

  # Providers - Ensure correct provider configuration is passed
  providers = {
    azurerm                                        = azurerm
    azurerm.private_dns_zone_subscription_provider = azurerm.private_dns_zone_subscription_provider
  }

  depends_on = [module.base, azurerm_app_configuration.this]
}
