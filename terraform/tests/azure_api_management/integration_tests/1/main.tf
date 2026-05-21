module "api_management" {
  source = "../../../../modules/azure_api_management"

  # Required Input Parameters
  app_name                  = "vystarsampleapp"
  region                    = "eastus"
  environment               = "dev"
  environment_number_suffix = "002"

  # Module Required Inputs
  publisher_email = "support@vystar.org"

  # Optional Inputs
  publisher_name = "VyStar Credit Union"
  sku_name       = "Premium"
  sku_capacity   = 6

  identity = {
    type         = "SystemAssigned"
    identity_ids = []
  }

  #   # Additional Locations
  #   additional_locations = {
  #     "westus" = {
  #       location             = "westus"
  #       capacity             = 2
  #       zones                = ["1", "2"]
  #       public_ip_address_id = "/subscriptions/xxx/resourceGroups/rg/providers/Microsoft.Network/publicIPAddresses/public-ip-westus"
  #       virtual_network_configuration = {
  #         subnet_id = "/subscriptions/xxx/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet-westus/subnets/subnet1"
  #       }
  #       gateway_disabled = false
  #     }
  #   }

  #   # Certificate Block
  #   certificate = {
  #     encoded_certificate  = "Base64EncodedCertificateContent"
  #     store_name           = "Root"
  #     certificate_password = "securepassword123"
  #   }

  #   # Delegation Block
  #   delegation = {
  #     subscriptions_enabled     = true
  #     user_registration_enabled = true
  #     url                       = "https://auth.vystar.org/delegation"
  #     validation_key            = "Base64EncodedValidationKey"
  #   }

  #   # Hostname Configuration
  #   hostname_configuration = {
  #     management = [{
  #       host_name                       = "api.management.vystar.org"
  #       key_vault_id                    = "/subscriptions/xxx/resourceGroups/rg/providers/Microsoft.KeyVault/vaults/myKeyVault/secrets/cert"
  #       certificate                     = null
  #       certificate_password            = null
  #       negotiate_client_certificate    = false
  #       ssl_keyvault_identity_client_id = null
  #     }]
  #     portal = []
  #     developer_portal = [{
  #       host_name                       = "portal.management.vystar.org"
  #       key_vault_id                    = null
  #       certificate                     = "Base64EncodedCertificateForPortal"
  #       certificate_password            = "securepassword456"
  #       negotiate_client_certificate    = false
  #       ssl_keyvault_identity_client_id = null
  #     }]
  #     proxy = [{
  #       host_name                       = "proxy.vystar.org"
  #       key_vault_id                    = null
  #       certificate                     = "Base64EncodedCertificateForProxy"
  #       certificate_password            = "proxycertpassword"
  #       negotiate_client_certificate    = true
  #       ssl_keyvault_identity_client_id = null
  #       default_ssl_binding             = true
  #     }]
  #     scm = []
  #   }

  # Protocols Block
  protocols = {
    enable_http2 = true
  }

  # Security Configuration
  security = {
    enable_backend_ssl30                                = false
    enable_backend_tls10                                = false
    enable_backend_tls11                                = false
    enable_frontend_ssl30                               = false
    enable_frontend_tls10                               = false
    enable_frontend_tls11                               = false
    tls_ecdhe_ecdsa_with_aes128_cbc_sha_ciphers_enabled = false
    tls_ecdhe_ecdsa_with_aes256_cbc_sha_ciphers_enabled = true
    tls_ecdhe_rsa_with_aes128_cbc_sha_ciphers_enabled   = true
    tls_ecdhe_rsa_with_aes256_cbc_sha_ciphers_enabled   = true
    tls_rsa_with_aes128_cbc_sha256_ciphers_enabled      = false
    tls_rsa_with_aes128_cbc_sha_ciphers_enabled         = false
    tls_rsa_with_aes128_gcm_sha256_ciphers_enabled      = true
    tls_rsa_with_aes256_gcm_sha384_ciphers_enabled      = true
    tls_rsa_with_aes256_cbc_sha256_ciphers_enabled      = true
    tls_rsa_with_aes256_cbc_sha_ciphers_enabled         = false
    triple_des_ciphers_enabled                          = false
  }

  #   # Sign-up Block
  #   sign_up = {
  #     enabled = true
  #     terms_of_service = {
  #       consent_required = true
  #       enabled          = true
  #       text             = "By signing up, you agree to our terms and privacy policy."
  #     }
  #   }

  # Tenant Access
  tenant_access = {
    enabled = true
  }

  # Public Network Access
  public_network_access_enabled = true

  # Virtual Network Configuration
  #   virtual_network_type = "Internal"
  #   virtual_network_configuration = {
  #     subnet_id = "/subscriptions/xxx/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet-eastus/subnets/subnet1"
  #   }

  # Other Settings
  client_certificate_enabled = false
  gateway_disabled           = false
  notification_sender_email  = "no-reply@vystar.org"

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
