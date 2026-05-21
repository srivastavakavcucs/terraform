#-----------------------------------------------------------
# DDOS Protection Plan Resource Creation
#-----------------------------------------------------------

locals {
  ddos_protection_plan_name = "ddos-pplan-${var.app_name}-${var.environment}-${var.region}-${var.environment_number_suffix}"
}

module "azure_ddos_protection_plan" {
  source  = "Azure/avm-res-network-ddosprotectionplan/azurerm"
  version = "0.2.0"

  #Required inputs
  name                = local.ddos_protection_plan_name
  location            = module.base.location
  resource_group_name = module.base.resource_group_name

  #Optional inputs
  enable_telemetry = module.base.enable_telemetry
  lock             = module.base.lock
  role_assignments = module.base.role_assignments
  tags             = module.base.tags

  # Forcing dependencies and deployment order to allow the resource group to be deployed first.
  depends_on = [module.base]
}
