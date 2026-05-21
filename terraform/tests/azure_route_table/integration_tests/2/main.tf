# #------------------------------------------------------------------------
# # Purpose: Route Table integration test into a VNet with 2 subnets.
# #          Step 1: Create VNet.
# #          Step 2: Retrieve subnet IDs.
# #          Step 3: Create a route table and attach the subnet IDs to it.
# #------------------------------------------------------------------------

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
#       name_segment   = "main"
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

# # Retrieve all subnet names for the VNet created by the "vnet" module
# data "azurerm_virtual_network" "vnet" {
#   name                = module.vnet.name
#   resource_group_name = module.vnet.resource_group_name

#   depends_on = [module.vnet]
# }

data "azurerm_virtual_network" "vnet" {
  name                = "vnet-vystarsampleapp-dev-eastus-002"
  resource_group_name = "rg-vystarsampleapp-vnet-dev-002"

  # depends_on = [module.vnet]
}

locals {
  subnet_name_segments = data.azurerm_virtual_network.vnet.subnets
}
# # Data source for Subnets, conditional on Virtual Network data
# data "azurerm_subnet" "subnets" {
#   count = length(data.azurerm_virtual_network.this.subnets)

#   name                 = data.azurerm_virtual_network.vnet.subnets[count.index]
#   virtual_network_name = module.vnet.name
#   resource_group_name  = module.vnet.resource_group_name
# }

#   # Step 1: Generate a map of subnet names and their subnet IDs
#   subnet_map = {
#     for subnet in data.azurerm_subnet.subnets : subnet.name => subnet.id
#   }

# Create a Route Table Module to apply the routes to the subnets.
module "route_table" {
  source = "../../../../modules/azure_route_table"

  # Required Input Parameters
  app_name                  = "vystarsampleapp"
  region                    = "eastus"
  environment               = "dev"
  environment_number_suffix = "002"

  # Updated routes to enforce valid next_hop_in_ip_address
  routes = [
    {
      destination_name       = "route-to-vnet"
      address_prefix         = "10.1.0.0/16"
      next_hop_type          = "VirtualNetworkGateway"
      next_hop_in_ip_address = null # Must be null for VirtualNetworkGateway
    },
    {
      destination_name       = "route-to-hub-vnet"
      address_prefix         = "10.0.0.0/9"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.216.0.68"
    },
    {
      destination_name       = "route-to-azure-devops-vnet"
      address_prefix         = "10.216.80.0/24"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.216.0.68"
    }
  ]

  subnet_name_segments = local.subnet_name_segments

  common_tags = {
    Business_Unit        = "Finance"
    Workload             = "Application"
    Business_Criticality = "Gold"
    Owner                = "Digital Team"
    Operations_Team      = "Cloud Engineering"
    Cost_Center          = "701"
  }

  # lock = {
  #   kind = "CanNotDelete"
  # }

  resource_tags = {
    Project = "Integration Test"
  }

  # Providers
  providers = {
    azurerm                                        = azurerm
    azurerm.private_dns_zone_subscription_provider = azurerm.private_dns_zone_subscription_provider
  }

  # Reference to the VNet module
  depends_on = [data.azurerm_virtual_network.vnet]
}
