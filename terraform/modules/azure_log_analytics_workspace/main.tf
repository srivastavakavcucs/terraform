#---------------------------------------------------------
# Azure Log Analytics Workspace Resource Creation
#----------------------------------------------------------

locals {
  log_analytics_workspace_name = "lg-${module.base.app_name}${module.base.environment}${module.base.environment_number_suffix}"
}

module "azure-log-Analytics-workspace" {

  source  = "Azure/avm-res-operationalinsights-workspace/azurerm"
  version = "0.4.2"

  #Required inputs
  name                = local.log_analytics_workspace_name
  location            = module.base.location
  resource_group_name = module.base.resource_group_name

  #Optional inputs
  customer_managed_key                                       = var.customer_managed_key
  diagnostic_settings                                        = module.base.diagnostic_settings
  enable_telemetry                                           = module.base.enable_telemetry
  lock                                                       = module.base.lock
  log_analytics_workspace_allow_resource_only_permissions    = var.allow_resource_only_permissions
  log_analytics_workspace_cmk_for_query_forced               = var.cmk_for_query_forced
  log_analytics_workspace_daily_quota_gb                     = var.daily_quota_gb
  log_analytics_workspace_identity                           = var.identity
  log_analytics_workspace_internet_ingestion_enabled         = var.internet_ingestion_enabled
  log_analytics_workspace_internet_query_enabled             = var.internet_query_enabled
  log_analytics_workspace_local_authentication_disabled      = var.local_authentication_disabled
  log_analytics_workspace_reservation_capacity_in_gb_per_day = var.reservation_capacity_in_gb_per_day
  log_analytics_workspace_retention_in_days                  = var.retention_in_days
  log_analytics_workspace_sku                                = var.sku
  log_analytics_workspace_timeouts                           = var.timeouts
  monitor_private_link_scope                                 = var.monitor_private_link_scope
  monitor_private_link_scoped_resource                       = var.monitor_private_link_scoped_resource
  monitor_private_link_scoped_service_name                   = var.monitor_private_link_scoped_service_name
  private_endpoints                                          = module.base.private_endpoints
  private_endpoints_manage_dns_zone_group                    = var.private_endpoints_manage_dns_zone_group
  role_assignments                                           = module.base.role_assignments
  tags                                                       = module.base.tags

  # Forcing dependencies and deployment order to allow the resource group to be deployed first.
  depends_on = [module.base]
}
