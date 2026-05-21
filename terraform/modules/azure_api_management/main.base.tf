#------------------------------------------------------------------------
# Use the IaC Common Variables Module for validations and outputs.
#------------------------------------------------------------------------

module "base" {
  source = "../iac_base"

  # Required Variables
  app_name                  = var.app_name
  region                    = var.region
  component_name            = "apim"
  environment               = var.environment
  environment_number_suffix = var.environment_number_suffix
  common_tags               = var.common_tags

  # Optional Variables
  enable_telemetry           = var.enable_telemetry
  lock                       = var.lock
  resource_tags              = var.resource_tags
  custom_resource_group_name = var.custom_resource_group_name

  # Providers
  providers = {
    azurerm                                        = azurerm
    azurerm.private_dns_zone_subscription_provider = azurerm.private_dns_zone_subscription_provider
  }
}
