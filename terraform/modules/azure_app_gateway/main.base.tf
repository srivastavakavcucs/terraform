#-----------------------------------------------------------------------
# Use the IaC Common Variables Module for validations and outputs.
#------------------------------------------------------------------------

module "base" {
  source = "../iac_base"

  # Required Variables
  app_name                  = var.app_name
  region                    = var.region
  component_name            = "app-gateway"
  environment               = var.environment
  environment_number_suffix = var.environment_number_suffix
  common_tags               = var.common_tags

  # Optional Variables
  diagnostic_settings        = var.diagnostic_settings
  enable_telemetry           = var.enable_telemetry
  lock                       = var.lock
  role_assignments           = var.role_assignments
  resource_tags              = var.resource_tags
  subnet_name_segments       = [var.gateway_subnet_name_segment]
  custom_resource_group_name = var.custom_resource_group_name

  # Providers
  providers = {
    azurerm                                        = azurerm
    azurerm.private_dns_zone_subscription_provider = azurerm.private_dns_zone_subscription_provider
  }
}
