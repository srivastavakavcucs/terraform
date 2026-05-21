module "azure_private_endpoint" {
  source  = "Azure/avm-res-network-privateendpoint/azurerm"
  version = "0.1.0"

  location                                   = module.base.location
  name                                       = "pe-${var.app_name}-${var.private_connection_resource.name}"
  resource_group_name                        = module.base.resource_group_name
  subnet_resource_id                         = module.base.subnet_name_segments_to_subnet_id_map[var.subnet_name_segment]
  private_connection_resource_id             = local.private_connection_resource.id
  private_dns_zone_resource_ids              = [for dns_zone in data.azurerm_private_dns_zone.dns_zones : dns_zone.id]
  network_interface_name                     = var.network_interface_name
  application_security_group_association_ids = toset(values(var.application_security_group_associations))
  enable_telemetry                           = module.base.enable_telemetry
  ip_configurations                          = var.ip_configurations
  lock                                       = module.base.lock
  private_dns_zone_group_name                = var.private_dns_zone_group_name
  private_service_connection_name            = var.private_service_connection_name
  role_assignments                           = module.base.role_assignments
  subresource_names                          = var.subresource_names
  tags                                       = module.base.tags

  # Forcing dependencies and deployment order to allow the resource group to be deployed first.
  depends_on = [module.base]
}
