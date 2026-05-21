module "azure-app-config" {

  source = "../../../../modules/azure_app_config"

  # Required Input Parameters
  app_name                  = "vystarsampleapp"
  region                    = "eastus"
  environment               = "dev"
  environment_number_suffix = "002"
  tenant_id                 = var.TENANT_ID
  existing_keyvault_name    = "kv-vystarsamplea-dev-002"
  existing_keyvault_resource_group = "rg-vystarsampleapp-keyvault-dev-002"
  key_type = "RSA"
  key_size = 2048
  key_opts =  [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey"
  ]

  # Optional Input Parameters

  sku_name = "standard"
  local_auth_enabled = false
  public_network_access = "Disabled"
  purge_protection_enabled = false
  soft_delete_retention_days = 7


### Log analytics Private Endpoint Configuration vars

private_endpoints = {
 appconfig_analytics_endpoint ={
  private_endpoint_subnet_name_segment = "shared-private-endpoints"
  private_dns_zones = [
  {
    name                = "privatelink.azconfig.io"
    resource_group_name = "rg-private-dns-shared01-eu-vy"
  }
   ]  
  tags ={
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
}
