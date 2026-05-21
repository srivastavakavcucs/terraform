#-----------------------------------------------------------------------
# Purpose: VNet Integration test with 2 subnets.
#          Subnet 1: Subnet Delegation enabled.
#          Subnet 2: Only Service Endpoints enabled.
#------------------------------------------------------------------------

module "vnet" {
  source = "../../../../modules/azure_virtual_network"

  # Required Input Parameters
  app_name                  = "vystarsampleapp"
  region                    = "eastus"
  environment               = "dev"
  environment_number_suffix = "002"

  cidr = ["10.254.0.0/16"]

  dns_servers = {
    dns_servers = [
      "10.216.232.4",
      "10.50.232.11"
    ]
  }

  subnets = {
    subnet1 = {
      name_segment   = "Main"
      address_prefix = "10.254.1.0/24"
      delegation = [
        {
          name = "Microsoft.Web.serverFarms"
          service_delegation = {
            name = "Microsoft.Web/serverFarms"
          }
        }
      ]
    }
    subnet2 = {
      name_segment      = "secondary-backup"
      address_prefix    = "10.254.2.0/24"
      service_endpoints = ["Microsoft.Storage", "Microsoft.ContainerRegistry", "Microsoft.KeyVault"]
    }

    subnet3 = {
      name_segment   = "pgsql"
      address_prefix = "10.254.3.0/24"
      delegation = [
        {
          name = "postgresql_delegation"
          service_delegation = {
            name = "Microsoft.DBforPostgreSQL/flexibleServers"
          }
        }
      ]
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
    }
    subnet4 = {
      name_segment      = "shared-private-endpoints"
      address_prefix    = "10.254.6.0/24"
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
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
