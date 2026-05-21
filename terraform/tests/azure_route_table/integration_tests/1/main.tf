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
}
