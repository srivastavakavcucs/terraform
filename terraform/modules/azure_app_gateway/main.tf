#-----------------------------------------------------------
#Azure App Gateway Resource Creation
#-----------------------------------------------------------

module "azure-app-gateway" {
  source  = "Azure/avm-res-network-applicationgateway/azurerm"
  version = "0.3.0"

  #Required inputs

  name                  = "apg-${var.app_name}-${var.environment}-${var.region}-${var.environment_number_suffix}"
  resource_group_name   = module.base.resource_group_name
  location              = module.base.location
  backend_address_pools = var.backend_address_pools
  backend_http_settings = var.backend_http_settings
  frontend_ports        = var.frontend_ports
  gateway_ip_configuration = {
    name      = "apgtw-ip-config-${var.app_name}-${var.environment}-${var.region}-${var.environment_number_suffix}"
    subnet_id = module.base.subnet_name_segments_to_subnet_id_map[var.gateway_subnet_name_segment]
  }
  http_listeners        = var.http_listeners
  request_routing_rules = var.request_routing_rules

  #Optional inputs

  app_gateway_waf_policy_resource_id    = var.app_gateway_waf_policy_resource_id
  authentication_certificate            = var.authentication_certificate
  autoscale_configuration               = var.autoscale_configuration
  create_public_ip                      = var.create_public_ip
  custom_error_configuration            = var.custom_error_configuration
  diagnostic_settings                   = module.base.diagnostic_settings
  enable_telemetry                      = module.base.enable_telemetry
  fips_enabled                          = var.fips_enabled
  frontend_ip_configuration_private     = var.frontend_ip_configuration_private
  frontend_ip_configuration_public_name = var.frontend_ip_configuration_public_name
  global                                = var.global
  http2_enable                          = var.http2_enable
  lock                                  = module.base.lock
  managed_identities                    = var.managed_identities
  private_link_configuration            = var.private_link_configuration
  probe_configurations                  = var.probe_configurations
  public_ip_name                        = var.public_ip_name
  public_ip_resource_id                 = var.public_ip_resource_id
  redirect_configuration                = var.redirect_configuration
  rewrite_rule_set                      = var.rewrite_rule_set
  role_assignments                      = module.base.role_assignments
  sku                                   = var.sku
  ssl_certificates                      = var.ssl_certificates
  ssl_policy                            = var.ssl_policy
  ssl_profile                           = var.ssl_profile
  timeouts                              = var.timeouts
  trusted_client_certificate            = var.trusted_client_certificate
  trusted_root_certificate              = var.trusted_root_certificate
  url_path_map_configurations           = var.url_path_map_configurations
  waf_configuration                     = var.waf_configuration
  zones                                 = var.zones
  tags                                  = module.base.tags

  # Forcing dependencies and deployment order to allow the resource group to be deployed first.
  depends_on = [module.base]
}