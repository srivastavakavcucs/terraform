module "private_link_service" {
  source = "../../../../modules/azure_private_link_service"

  # Required Input Parameters
  app_name                  = "vystarsampleapp"
  region                    = "eastus"
  environment               = "dev"
  environment_number_suffix = "002"
  #tenant_id                 = var.TENANT_ID

  # # Updated routes to enforce valid next_hop_in_ip_address

  # visibility_subscription_ids      = ["469217d4-0c3a-4e4d-8f72-f57391ea321e", "c1bc5dd7-ea97-469c-89fa-8f26624902fd"]
  # auto_approval_subscription_ids   = ["469217d4-0c3a-4e4d-8f72-f57391ea321e", "c1bc5dd7-ea97-469c-89fa-8f26624902fd"]
  # nat_ip_configuration_name        = "primary"
  nat_ip_address = "10.190.6.8"
  # existing_lb_resource_group       = "rg_test_lb"
  # existing_lb_name                 = "test_lb"
  private_link_subnet_name_segment = "shared-private-endpoints-subnet"
  resource_name_for_private_link   = "test_private_link"

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
