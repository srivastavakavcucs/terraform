#-----------------------------------------------------------
#Azure Key Vault Resource Creation
#-----------------------------------------------------------

module "azure-keyvault" {
  source  = "Azure/avm-res-keyvault-vault/azurerm"
  version = "0.10.0"

  #Required inputs
  name                = local.key_vault_name
  resource_group_name = module.base.resource_group_name
  location            = module.base.location
  tenant_id           = var.tenant_id

  #Optional inputs

  contacts                                = var.contacts
  diagnostic_settings                     = module.base.diagnostic_settings
  enable_telemetry                        = module.base.enable_telemetry
  enabled_for_deployment                  = var.enabled_for_deployment
  enabled_for_disk_encryption             = var.enabled_for_disk_encryption
  enabled_for_template_deployment         = var.enabled_for_template_deployment
  keys                                    = var.keys
  legacy_access_policies                  = var.legacy_access_policies
  legacy_access_policies_enabled          = var.legacy_access_policies_enabled
  lock                                    = module.base.lock
  network_acls                            = var.network_acls
  private_endpoints                       = module.base.private_endpoints
  public_network_access_enabled           = var.public_network_access_enabled
  private_endpoints_manage_dns_zone_group = var.private_endpoints_manage_dns_zone_group
  purge_protection_enabled                = var.purge_protection_enabled
  role_assignments                        = module.base.role_assignments
  secrets                                 = var.secrets
  secrets_value                           = var.secrets_value
  sku_name                                = var.sku_name
  soft_delete_retention_days              = var.soft_delete_retention_days
  wait_for_rbac_before_contact_operations = var.wait_for_rbac_before_contact_operations
  wait_for_rbac_before_key_operations     = var.wait_for_rbac_before_key_operations
  wait_for_rbac_before_secret_operations  = var.wait_for_rbac_before_secret_operations
  tags                                    = module.base.tags

  # Forcing dependencies and deployment order to allow the resource group to be deployed first.
  depends_on = [module.base]
}

