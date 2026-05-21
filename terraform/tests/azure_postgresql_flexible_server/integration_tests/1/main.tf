
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

module "azure_postgresql_flexible_server" {

  source = "../../../../modules/azure_postgresql_flexible_server"

  # Required Input Parameters
  app_name                  = "vystarsampleapp"
  region                    = "eastus"
  environment               = "dev"
  environment_number_suffix = "002"

  # Optional Input Parameter

  administrator_login          = "pgadmin"
  administrator_password       = "Pa$$w0rd"
  authentication               = null
  auto_grow_enabled            = false
  backup_retention_days        = 30
  customer_managed_key         = null
  create_mode                  = "Default"
  geo_redundant_backup_enabled = false
  high_availability = {
    mode = "ZoneRedundant"
  }
  public_network_access_enabled           = false
  delegated_subnet_name_segment           = "pgsql"
  server_version                          = 12
  sku_name                                = "GP_Standard_D2s_v3"
  storage_mb                              = 32768
  storage_tier                            = "P4"
  zone                                    = 2
  private_endpoints_manage_dns_zone_group = true

  private_dns_zone = {
    name                = "privatelink.postgres.database.azure.com"
    resource_group_name = "rg-private-dns-shared01-eu-vy"
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
    azurerm.private_dns_zone_subscription_provider = azurerm.private_dns_zone_subscription_provider
  }

  # depends_on = [module.vnet]
}
