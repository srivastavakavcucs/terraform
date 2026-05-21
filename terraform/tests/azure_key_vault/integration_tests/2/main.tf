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

module "azure_key_vault" {
  source = "../../../../modules/azure_key_vault"

  # Required Input Parameters
  app_name                  = "vystarsampleapp"
  region                    = "eastus"
  environment               = "dev"
  environment_number_suffix = "002"
  tenant_id                 = var.TENANT_ID

  # Updated routes to enforce valid next_hop_in_ip_address

  sku_name                                = "premium"
  soft_delete_retention_days              = 60
  enable_telemetry                        = true
  enabled_for_deployment                  = false
  enabled_for_disk_encryption             = false
  legacy_access_policies_enabled          = false
  private_endpoints_manage_dns_zone_group = true
  purge_protection_enabled                = true
  role_assignments                        = {}
  secrets                                 = {}
  secrets_value                           = null
  network_acls                            =  {
    bypass                     = "AzureServices"
    default_action             = "Allow"
    ip_rules                   = ["10.190.0.0/16"]
    virtual_network_subnet_ids = []
  }

  private_endpoints = {
    keyvault_endpoint = {
      private_endpoint_subnet_name_segment = "shared-private-endpoints"
      private_dns_zones = [
        {
          name                = "privatelink.vaultcore.azure.net"
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

  # Add a dependency to force deployment order.
  # depends_on = [module.vnet]
}
