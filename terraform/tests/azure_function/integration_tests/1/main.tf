module "azure_function" {

  source = "../../../../modules/azure_function"

  # Required Input Parameters
  app_name                  = "vystarsampleapp"
  region                    = "eastus"
  environment               = "dev"
  environment_number_suffix = "002"

  os_type                    = "Linux"
  service_plan_id            = var.SERVICE_PLAN_ID
  storage_account_name       = var.STORAGE_ACCOUNT_NAME
  storage_account_access_key = var.STORAGE_ACCOUNT_ACCESS_KEY
  runtime                    = "python"
  runtime_version            = "3.11"

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
