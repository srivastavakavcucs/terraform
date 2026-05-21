#-----------------------------------------------------------------------
# Purpose: Simple VNet Integration test without subnets.
#------------------------------------------------------------------------

module "vnet" {
  source = "../../../../modules/azure_virtual_network"

  # Required Input Parameters
  app_name                  = "vystarsampleapp"
  region                    = "eastus"
  environment               = "dev"
  environment_number_suffix = "002"

  cidr = ["10.190.0.0/16"]
  dns_servers = {
    dns_servers = [
      "10.216.232.4",
      "10.50.232.11"
    ]
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

  providers = {
    azurerm                                        = azurerm
    azurerm.private_dns_zone_subscription_provider = azurerm
  }
}
