# #-----------------------------------------------------------------------
# # STEP 1: Purpose: Create a route table for the VNet.
# #------------------------------------------------------------------------

# module "route_table" {
#   source = "../../../../modules/azure_route_table"

#   # Required Input Parameters
#   app_name                  = "vystarsampleapp"
#   region                    = "eastus"
#   environment               = "dev"
#   environment_number_suffix = "002"

#   # Updated routes to enforce valid next_hop_in_ip_address
#   routes = [
#     {
#       destination_name       = "route-to-vnet"
#       address_prefix         = "10.1.0.0/16"
#       next_hop_type          = "VirtualNetworkGateway"
#       next_hop_in_ip_address = null # Must be null for VirtualNetworkGateway
#     },
#     {
#       destination_name       = "route-to-hub-vnet"
#       address_prefix         = "10.0.0.0/9"
#       next_hop_type          = "VirtualAppliance"
#       next_hop_in_ip_address = "10.216.0.68"
#     },
#     {
#       destination_name       = "route-to-azure-devops-vnet"
#       address_prefix         = "10.216.80.0/24"
#       next_hop_type          = "VirtualAppliance"
#       next_hop_in_ip_address = "10.216.0.68"
#     }
#   ]

#   common_tags = {
#     Business_Unit        = "Finance"
#     Workload             = "Application"
#     Business_Criticality = "Gold"
#     Owner                = "Digital Team"
#     Operations_Team      = "Cloud Engineering"
#     Cost_Center          = "701"
#   }

#   # lock = {
#   #   kind = "CanNotDelete"
#   # }

#   resource_tags = {
#     Project = "Integration Test"
#   }

#   # Providers
#   providers = {
#     azurerm                                        = azurerm
#     azurerm.private_dns_zone_subscription_provider = azurerm.private_dns_zone_subscription_provider
#   }
# }

# #-----------------------------------------------------------------------
# # STEP 2: Purpose: Create test with 2 subnets.
# #                  Subnet 1: ARO Cluster Main Subnet
# #                  Subnet 2: ARO Cluster Worker Subnet
# #------------------------------------------------------------------------

# module "vnet" {
#   source = "../../../../modules/azure_virtual_network"

#   # Required Input Parameters
#   app_name                  = "vystarsampleapp"
#   region                    = "eastus"
#   environment               = "dev"
#   environment_number_suffix = "002"

#   cidr = ["10.254.0.0/16"]

#   dns_servers = {
#     dns_servers = [
#       "10.216.232.4",
#       "10.50.232.11"
#     ]
#   }

#   subnets = {
#     aro-main-subnet = {
#       name_segment      = "aro-main"
#       address_prefix    = "10.254.1.0/24"
#       service_endpoints = ["Microsoft.ContainerRegistry", "Microsoft.Storage"]
#       route_table = {
#         name                = "rt-vystarsampleapp-dev-002"
#         resource_group_name = "rg-vystarsampleapp-routetable-dev-002"
#       }
#     },
#     aro-worker-subnet = {
#       name_segment      = "aro-worker"
#       address_prefix    = "10.254.2.0/24"
#       service_endpoints = ["Microsoft.Storage", "Microsoft.ContainerRegistry", "Microsoft.KeyVault"]
#       route_table = {
#         name                = module.route_table.name
#         resource_group_name = module.route_table.resource_group_name
#       }
#     },
#     shared-private-endpoints-subnet = {
#       name_segment      = "shared-private-endpoints-subnet"
#       address_prefix    = "10.254.6.0/24"
#       service_endpoints = ["Microsoft.Storage", "Microsoft.ContainerRegistry", "Microsoft.KeyVault"]
#       route_table = {
#         name                = module.route_table.name
#         resource_group_name = module.route_table.resource_group_name
#       }
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

#   depends_on = [module.route_table]
# }

#------------------------------------------------------------------------
# STEP 3: Purpose: Create the ARO Cluster in the VNet.
#------------------------------------------------------------------------


# ARO Cluster
module "cluster" {
  source = "../../../../modules/azure_redhat_openshift"

  # Required Input Parameters
  app_name                  = "vystarsampleapp"
  region                    = "eastus"
  environment               = "dev"
  environment_number_suffix = "002"

  # Service Principals and Secrets
  sp_client_id                           = "e86533ef-0a98-4073-ae6a-8d46cbc43ee8"
  sp_client_secret                       = "another_secret"
  aro_cluster_aad_sp_object_id           = "a115c4b3-aac8-49c5-82f0-985c21a5df72"
  aro_resource_provider_aad_sp_object_id = "246d5aaa-cb9e-4c9e-b259-be85b0cca690"
  rh_pull_secret                         = "some_secret"

  # Required Variables
  main_subnet_name_segment   = "aro-main"
  worker_subnet_name_segment = "aro-worker"

  # # Optional Variables
  # openshift_version          = "4.15.27"
  # pod_cidr                   = "10.128.0.0/14"
  # service_cidr               = "172.30.0.0/16"
  # main_vm_size               = "Standard_D8as_v5"
  # worker_node_count          = 3
  # worker_node_vm_size        = "Standard_D4as_v5"
  # worker_node_disk_size_gb   = 128

  # Tags
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

  # depends_on = [module.vnet]
}
