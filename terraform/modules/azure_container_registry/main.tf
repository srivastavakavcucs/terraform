#---------------------------------------------------------
# Azure Container Registry Resource Creation
#----------------------------------------------------------

module "azure_container_registry" {
  source  = "Azure/avm-res-containerregistry-registry/azurerm"
  version = "0.4.0"

  #-------------------------------------------------------------------------------------------
  # Naming Standards Document: Azure Naming and Tagging Standards v4.0.0.0_20241022
  # VyStar ACR Naming Standard: 	cr<project, app or service><environment><###>
  # Example: crnavigatorprod001
  #-------------------------------------------------------------------------------------------

  # Required Inputs
  location            = module.base.location
  name                = "cr${module.base.app_name}${module.base.environment}${module.base.environment_number_suffix}"
  resource_group_name = module.base.resource_group_name
  sku                 = var.sku

  # Optional Inputs
  admin_enabled                           = var.admin_enabled
  anonymous_pull_enabled                  = var.anonymous_pull_enabled
  customer_managed_key                    = var.customer_managed_key
  data_endpoint_enabled                   = var.data_endpoint_enabled
  diagnostic_settings                     = module.base.diagnostic_settings
  enable_telemetry                        = module.base.enable_telemetry
  enable_trust_policy                     = var.enable_trust_policy
  export_policy_enabled                   = var.export_policy_enabled
  georeplications                         = var.georeplications
  lock                                    = module.base.lock
  managed_identities                      = var.managed_identities
  network_rule_bypass_option              = var.network_rule_bypass_option
  network_rule_set                        = var.network_rule_set
  private_endpoints                       = module.base.private_endpoints
  private_endpoints_manage_dns_zone_group = var.private_endpoints_manage_dns_zone_group
  public_network_access_enabled           = var.public_network_access_enabled
  quarantine_policy_enabled               = var.quarantine_policy_enabled
  role_assignments                        = module.base.role_assignments
  zone_redundancy_enabled                 = var.zone_redundancy_enabled
  tags                                    = module.base.tags

  # TODO: Figure out whether the bug is in the base code or locally and uncomment this line.
  retention_policy_in_days = var.retention_policy_in_days

  # Forcing dependencies and deployment order to allow the resource group to be deployed first.
  depends_on = [module.base]
}
