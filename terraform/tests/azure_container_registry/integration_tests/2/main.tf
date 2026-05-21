# # Virtual Network Module
# module "vnet" {
#   source = "../../../../modules/azure_virtual_network"

#   # Required Input Parameters
#   app_name                  = "vystarsampleapp"
#   region                    = "eastus"
#   environment               = "dev"
#   environment_number_suffix = "002"

#   cidr = ["10.190.0.0/16"]

#   dns_servers = {
#     dns_servers = [
#       "10.216.232.4",
#       "10.50.232.11"
#     ]
#   }

#   subnets = {
#     subnet1 = {
#       name_segment   = "Main"
#       address_prefix = "10.190.1.0/24"
#       delegation = [
#         {
#           name = "Microsoft.Web.serverFarms"
#           service_delegation = {
#             name = "Microsoft.Web/serverFarms"
#           }
#         }
#       ]
#     }
#     subnet2 = {
#       name_segment      = "secondary-backup"
#       address_prefix    = "10.190.2.0/24"
#       service_endpoints = ["Microsoft.Storage", "Microsoft.ContainerRegistry", "Microsoft.KeyVault"]
#     }

#     subnet3 = {
#       name_segment   = "pgsql"
#       address_prefix = "10.190.3.0/24"
#       delegation = [
#         {
#           name = "postgresql_delegation"
#           service_delegation = {
#             name    = "Microsoft.DBforPostgreSQL/flexibleServers"
#           }
#         }
#       ]
#       service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
#     }
#     subnet4 = {
#       name_segment      = "shared-private-endpoints"
#       address_prefix    = "10.190.6.0/24"
#       service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
#     }
#   }

#   common_tags = {
#     Business_Unit        = "Finance"
#     Workload             = "Application"
#     Business_Criticality = "Gold"
#     Owner                = "Digital Team"
#     Operations_Team      = "Cloud Engineering"
#     Cost_Center          = "701"
#   }

#   resource_tags = {
#     Project = "Integration Test"
#   }

#   # Providers
#   providers = {
#     azurerm                                        = azurerm
#     azurerm.private_dns_zone_subscription_provider = azurerm.private_dns_zone_subscription_provider
#   }
# }

# Azure Container Registry Module
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

  private_endpoints = {
    acr_endpoints = {
      private_endpoint_subnet_name_segment = "shared-private-endpoints"
      private_dns_zones = [
        {
          name                = "privatelink.azurecr.io"
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

  # Dependency on VNet Module
  # depends_on = [module.vnet]
}
