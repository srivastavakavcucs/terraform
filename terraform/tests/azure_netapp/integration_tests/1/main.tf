module "netapp_files" {

  source = "../../../../modules/azure_netapp_files"

  # Required Input Parameters

  app_name                  = "omb"
  region                    = "eastus"
  environment               = "dev"
  environment_number_suffix = "002"

  #Netapp Pool Variables
  pool_service_level = "Premium"
  pool_size          = 2

  #Netapp Volume Variables
  volume_service_level          = "Premium"
  zone                          = "1"
  volume_path                   = "vystar-unique-file-path"
  network_features              = "Standard"
  protocols                     = ["NFSv4.1"]
  security_style                = "unix"
  storage_quota_in_gb           = 100
  snapshot_directory_visible    = false
  rule_index                    = 1
  allowed_clients               = ["10.190.0.0/16"]
  protocols_enabled             = ["NFSv4.1"]
  unix_read_write               = true
  delegated_subnet_name_segment = "netapp"

  resource_tags = {
    Project = "Integration Test"
  }
  common_tags = {
    Business_Unit        = "Finance"
    Workload             = "Application"
    Business_Criticality = "Gold"
    Owner                = "Digital Team"
    Operations_Team      = "Cloud Engineering"
    Cost_Center          = "701"
  }

  # Providers
  providers = {
    azurerm                                        = azurerm
    azurerm.private_dns_zone_subscription_provider = azurerm.private_dns_zone_subscription_provider
  }

}

