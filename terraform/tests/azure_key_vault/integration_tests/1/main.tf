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
