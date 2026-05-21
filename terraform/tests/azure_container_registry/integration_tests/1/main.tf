module "azure_container_registry" {

  source = "../../../../modules/azure_container_registry"

  # Required Input Parameters
  app_name                  = "vystarsampleapp"
  region                    = "eastus"
  environment               = "dev"
  environment_number_suffix = "002"
  sku                       = "Premium"


  # Optional Input Parameters

  admin_enabled                 = false
  public_network_access_enabled = false
  zone_redundancy_enabled       = true
  retention_policy_in_days      = 90
  georeplications = [{
    location                  = "centralus"
    regional_endpoint_enabled = true
    zone_redundancy_enabled   = true
  }]

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
