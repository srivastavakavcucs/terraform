#-----------------------------------------------------------
#Azure CDN-FrontDoor Resource Creation
#-----------------------------------------------------------

module "cdn_profile" {
  source  = "Azure/avm-res-cdn-profile/azurerm"
  version = "0.1.3"

  # Required Inputs
  name                = "cdn-frontdoor-${module.base.app_name}-${module.base.environment}-${module.base.environment_number_suffix}"
  resource_group_name = module.base.resource_group_name
  location            = module.base.location

  # Optional Inputs
  cdn_endpoint_custom_domains  = var.cdn_endpoint_custom_domains
  cdn_endpoints                = var.cdn_endpoints
  diagnostic_settings          = module.base.diagnostic_settings
  enable_telemetry             = module.base.enable_telemetry
  front_door_custom_domains    = var.front_door_custom_domains
  front_door_endpoints         = var.front_door_endpoints
  front_door_firewall_policies = var.front_door_firewall_policies
  front_door_origin_groups     = var.front_door_origin_groups
  front_door_origins           = var.front_door_origins
  front_door_routes            = var.front_door_routes
  front_door_rule_sets         = var.front_door_rule_sets
  front_door_rules             = var.front_door_rules
  front_door_secrets           = var.front_door_secrets
  front_door_security_policies = var.front_door_security_policies
  lock                         = module.base.lock
  managed_identities           = var.managed_identities
  response_timeout_seconds     = var.response_timeout_seconds
  role_assignments             = module.base.role_assignments
  sku                          = var.sku
  tags                         = module.base.tags

  # Forcing dependencies and deployment order to allow the resource group to be deployed first.
  depends_on = [module.base]
}
