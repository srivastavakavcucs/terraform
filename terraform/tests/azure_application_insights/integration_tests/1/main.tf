module "azure-log-Analytics-workspace" {

  source = "../../../../modules/azure_log_analytics_workspace"

  # Required Input Parameters
  app_name                  = "vystarsampleapp"
  region                    = "eastus"
  environment               = "dev"
  environment_number_suffix = "002"

  # Optional Input Parameters

  sku                                = "PerGB2018"
  allow_resource_only_permissions    = true
  daily_quota_gb                     = 1
  retention_in_days                  = 45
  reservation_capacity_in_gb_per_day = 200
  local_authentication_disabled      = false
  internet_query_enabled             = true
  internet_ingestion_enabled         = true

  ### Log analytics Private Endpoint Configuration vars

  private_endpoints = {
    log_analytics_endpoint = {
      private_endpoint_subnet_name_segment = "shared-private-endpoints"
      private_dns_zones = [
        {
          name                = "privatelink.monitor.azure.com"
          resource_group_name = "rg-private-dns-shared01-eu-vy"
        }
      ]
      tags = {
        Project = "Integration Test"
      }
    }
  }

  common_tags = {
    Business_Unit        = "Finance"
    Workload             = "Application"
    Business_Criticality = "Gold"
    Owner                = "Digital Team"
    Operations_Team      = "Cloud Engineering"
    Cost_Center          = "701"
  }

  resource_tags = {
    Project = "Integration Test"
  }

  # Providers
  providers = {
    azurerm                                        = azurerm
    azurerm.private_dns_zone_subscription_provider = azurerm.private_dns_zone_subscription_provider
  }
}
