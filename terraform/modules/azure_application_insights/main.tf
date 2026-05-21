#---------------------------------------------------------
# Azure Application Insights Resource Creation
#----------------------------------------------------------

module "app_insights" {
  source  = "Azure/avm-res-insights-component/azurerm"
  version = "0.1.4"

  #Required inputs
  location            = module.base.location
  name                = "app-insight-${module.base.app_name}${module.base.environment}${module.base.environment_number_suffix}"
  resource_group_name = module.base.resource_group_name
  workspace_id        = var.workspace_id

  #Optional inputs
  enable_telemetry                      = module.base.enable_telemetry
  lock                                  = module.base.lock
  managed_identities                    = var.managed_identities
  application_type                      = var.application_type
  daily_data_cap_in_gb                  = var.daily_data_cap_in_gb
  daily_data_cap_notifications_disabled = var.daily_data_cap_notifications_disabled
  disable_ip_masking                    = var.disable_ip_masking
  internet_ingestion_enabled            = var.internet_ingestion_enabled
  internet_query_enabled                = var.internet_query_enabled
  local_authentication_disabled         = var.local_authentication_disabled
  retention_in_days                     = var.retention_in_days
  sampling_percentage                   = var.sampling_percentage
  tags                                  = module.base.tags

  # Forcing dependencies and deployment order to allow the resource group to be deployed first.
  depends_on = [module.base]
}



