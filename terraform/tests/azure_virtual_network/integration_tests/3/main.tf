#------------------------------------------------------------------------
# Purpose: VNet Integration test with 2 subnets.
#          Subnet 1: Subnet Delegation enabled.
#          Subnet 2: Only Service Endpoints enabled.
#          Connect the subnets to an existing route table.
#------------------------------------------------------------------------

# Route Table Module
module "route_table" {
  source = "../../../../modules/azure_route_table"

  # Required Input Parameters
  app_name                  = "vystarsampleapp"
  region                    = "eastus"
  environment               = "dev"
  environment_number_suffix = "002"

  # Routes
  routes = [
    {
      destination_name       = "route-to-vnet"
      address_prefix         = "10.1.0.0/16"
      next_hop_type          = "VirtualNetworkGateway"
      next_hop_in_ip_address = null
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

# Virtual Network Module
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

  subnets = {
    subnet1 = {
      name_segment   = "Main"
      address_prefix = "10.190.1.0/24"
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
      address_prefix    = "10.190.2.0/24"
      service_endpoints = ["Microsoft.Storage", "Microsoft.ContainerRegistry", "Microsoft.KeyVault"]
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

  depends_on = [module.route_table]
}
