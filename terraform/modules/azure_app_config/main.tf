
#-------------------------------------------------------------------------
# Create the Azure User Assigned Identity to be to the App Configuration
#-------------------------------------------------------------------------
resource "azurerm_user_assigned_identity" "this" {
  name                = "appconfig-user-identity-${var.app_name}-${var.environment}-${var.region}-${var.environment_number_suffix}"
  location            = module.base.location
  resource_group_name = module.base.resource_group_name

  depends_on = [module.base]
}

#-------------------------------------------------------------------------
# Check if the replica is provided or not
#-------------------------------------------------------------------------
locals {
  replica_enabled = var.replica != null
}

#-------------------------------------------------------------------------
# Create the Key Vault Access Policy to allow the User Assigned Identity
#-------------------------------------------------------------------------
resource "azurerm_key_vault_access_policy" "server" {
  key_vault_id = data.azurerm_key_vault.existing.id
  tenant_id    = var.tenant_id
  object_id    = azurerm_user_assigned_identity.this.principal_id

  key_permissions    = ["Get", "Create", "Delete", "Import", "List"]
  secret_permissions = ["Get", "Set", "Delete"]

  depends_on = [azurerm_user_assigned_identity.this]
}

#-------------------------------------------------------------------------
# Create a new Key in the Key Vault
#-------------------------------------------------------------------------
resource "azurerm_key_vault_key" "kv_key" {
  name            = "appconfig-key-${var.app_name}-${var.environment}-${var.region}-${var.environment_number_suffix}"
  key_vault_id    = data.azurerm_key_vault.existing.id
  key_type        = var.key_type # You can use "RSA" or "EC" depending on the type of key you want
  key_size        = var.key_size # RSA key size, you can adjust as needed
  key_opts        = var.key_opts
  expiration_date = timeadd(formatdate("YYYY-MM-01'T'00:00:00Z", timestamp()), "2160h")
  tags            = module.base.tags
}

#-------------------------------------------------------------------------
# Create the Azure App Configuration
#-------------------------------------------------------------------------
resource "azurerm_app_configuration" "this" {
  name                       = "appconfig-${var.app_name}-${var.environment}-${var.region}-${var.environment_number_suffix}"
  location                   = module.base.location
  resource_group_name        = module.base.resource_group_name
  tags                       = module.base.tags
  sku                        = var.sku_name
  local_auth_enabled         = var.local_auth_enabled
  public_network_access      = var.public_network_access
  purge_protection_enabled   = var.purge_protection_enabled
  soft_delete_retention_days = var.soft_delete_retention_days

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.this.id,
    ]
  }
  encryption {
    key_vault_key_identifier = azurerm_key_vault_key.kv_key.id #data.azurerm_key_vault.existing.id
    identity_client_id       = azurerm_user_assigned_identity.this.client_id
  }

  # Conditionally add replica block using dynamic block
  dynamic "replica" {
    for_each = local.replica_enabled ? [var.replica] : []

    content {
      name     = "replica${var.app_name}${var.environment}${var.region}${var.environment_number_suffix}"
      location = var.replica.region
    }

  }

  # Forcing dependencies and deployment order to allow the resource group to be deployed first.
  depends_on = [module.base, azurerm_user_assigned_identity.this]
}


