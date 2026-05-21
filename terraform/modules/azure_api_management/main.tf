#--------------------------------------------------------------------------------
# Create the API Management API Gateway
#--------------------------------------------------------------------------------

#--------------------------------------------------------------------------------
# Source: Azure Naming and Tagging Standards v4.0.0.0_20241022.docx
# API Management	Naming: apim-<app or service name>
# Example : apim-navigator-prod
# NOTE: The naming here adds the environment suffix
#--------------------------------------------------------------------------------

resource "azurerm_api_management" "this" {
  name                = "apim-${var.app_name}-${var.environment}-${var.environment_number_suffix}"
  location            = module.base.location
  resource_group_name = module.base.resource_group_name
  publisher_email     = var.publisher_email
  publisher_name      = var.publisher_name
  sku_name            = "${var.sku_name}_${var.sku_capacity}"
  tags                = module.base.tags

  min_api_version = var.min_api_version
  zones           = var.zones

  # Identity configuration
  identity {
    type         = var.identity.type
    identity_ids = var.identity.identity_ids
  }

  # Additional locations configuration
  dynamic "additional_location" {
    for_each = var.additional_locations
    content {
      location             = additional_location.value.location
      capacity             = additional_location.value.capacity
      zones                = additional_location.value.zones
      public_ip_address_id = additional_location.value.public_ip_address_id
      gateway_disabled     = additional_location.value.gateway_disabled

      virtual_network_configuration {
        subnet_id = additional_location.value.virtual_network_configuration != null ? additional_location.value.virtual_network_configuration.subnet_id : null
      }
    }
  }

  # Certificate block (if provided)
  dynamic "certificate" {
    for_each = var.certificate == null ? [] : [var.certificate]
    content {
      encoded_certificate  = certificate.value.encoded_certificate
      store_name           = certificate.value.store_name
      certificate_password = certificate.value.certificate_password
    }
  }

  # Client certificate enabled
  client_certificate_enabled = var.client_certificate_enabled

  # Delegation block
  dynamic "delegation" {
    for_each = var.delegation == null ? [] : [var.delegation]
    content {
      subscriptions_enabled     = delegation.value.subscriptions_enabled
      user_registration_enabled = delegation.value.user_registration_enabled
      url                       = delegation.value.url
      validation_key            = delegation.value.validation_key
    }
  }

  # Hostname configuration block
  dynamic "hostname_configuration" {
    for_each = var.hostname_configuration == null ? [] : [var.hostname_configuration]
    content {
      dynamic "management" {
        for_each = hostname_configuration.value.management
        content {
          host_name                       = management.value.host_name
          key_vault_id                    = management.value.key_vault_id
          certificate                     = management.value.certificate
          certificate_password            = management.value.certificate_password
          negotiate_client_certificate    = management.value.negotiate_client_certificate
          ssl_keyvault_identity_client_id = management.value.ssl_keyvault_identity_client_id
        }
      }

      dynamic "portal" {
        for_each = hostname_configuration.value.portal
        content {
          host_name                       = portal.value.host_name
          key_vault_id                    = portal.value.key_vault_id
          certificate                     = portal.value.certificate
          certificate_password            = portal.value.certificate_password
          negotiate_client_certificate    = portal.value.negotiate_client_certificate
          ssl_keyvault_identity_client_id = portal.value.ssl_keyvault_identity_client_id
        }
      }

      dynamic "developer_portal" {
        for_each = hostname_configuration.value.developer_portal
        content {
          host_name                       = developer_portal.value.host_name
          key_vault_id                    = developer_portal.value.key_vault_id
          certificate                     = developer_portal.value.certificate
          certificate_password            = developer_portal.value.certificate_password
          negotiate_client_certificate    = developer_portal.value.negotiate_client_certificate
          ssl_keyvault_identity_client_id = developer_portal.value.ssl_keyvault_identity_client_id
        }
      }

      dynamic "proxy" {
        for_each = hostname_configuration.value.proxy
        content {
          host_name                       = proxy.value.host_name
          key_vault_id                    = proxy.value.key_vault_id
          certificate                     = proxy.value.certificate
          certificate_password            = proxy.value.certificate_password
          negotiate_client_certificate    = proxy.value.negotiate_client_certificate
          ssl_keyvault_identity_client_id = proxy.value.ssl_keyvault_identity_client_id
          default_ssl_binding             = proxy.value.default_ssl_binding
        }
      }

      dynamic "scm" {
        for_each = hostname_configuration.value.scm
        content {
          host_name                       = scm.value.host_name
          key_vault_id                    = scm.value.key_vault_id
          certificate                     = scm.value.certificate
          certificate_password            = scm.value.certificate_password
          negotiate_client_certificate    = scm.value.negotiate_client_certificate
          ssl_keyvault_identity_client_id = scm.value.ssl_keyvault_identity_client_id
        }
      }
    }
  }

  # Notification sender email
  notification_sender_email = var.notification_sender_email

  # Protocols block
  dynamic "protocols" {
    for_each = var.protocols == null ? [] : [var.protocols]
    content {
      enable_http2 = protocols.value.enable_http2
    }
  }

  # Security block
  dynamic "security" {
    for_each = var.security == null ? [] : [var.security]
    content {
      enable_backend_ssl30                                = security.value.enable_backend_ssl30
      enable_backend_tls10                                = security.value.enable_backend_tls10
      enable_backend_tls11                                = security.value.enable_backend_tls11
      enable_frontend_ssl30                               = security.value.enable_frontend_ssl30
      enable_frontend_tls10                               = security.value.enable_frontend_tls10
      enable_frontend_tls11                               = security.value.enable_frontend_tls11
      tls_ecdhe_ecdsa_with_aes128_cbc_sha_ciphers_enabled = security.value.tls_ecdhe_ecdsa_with_aes128_cbc_sha_ciphers_enabled
      tls_ecdhe_ecdsa_with_aes256_cbc_sha_ciphers_enabled = security.value.tls_ecdhe_ecdsa_with_aes256_cbc_sha_ciphers_enabled
      tls_ecdhe_rsa_with_aes128_cbc_sha_ciphers_enabled   = security.value.tls_ecdhe_rsa_with_aes128_cbc_sha_ciphers_enabled
      tls_ecdhe_rsa_with_aes256_cbc_sha_ciphers_enabled   = security.value.tls_ecdhe_rsa_with_aes256_cbc_sha_ciphers_enabled
      tls_rsa_with_aes128_cbc_sha256_ciphers_enabled      = security.value.tls_rsa_with_aes128_cbc_sha256_ciphers_enabled
      tls_rsa_with_aes128_cbc_sha_ciphers_enabled         = security.value.tls_rsa_with_aes128_cbc_sha_ciphers_enabled
      tls_rsa_with_aes128_gcm_sha256_ciphers_enabled      = security.value.tls_rsa_with_aes128_gcm_sha256_ciphers_enabled
      tls_rsa_with_aes256_gcm_sha384_ciphers_enabled      = security.value.tls_rsa_with_aes256_gcm_sha384_ciphers_enabled
      tls_rsa_with_aes256_cbc_sha256_ciphers_enabled      = security.value.tls_rsa_with_aes256_cbc_sha256_ciphers_enabled
      tls_rsa_with_aes256_cbc_sha_ciphers_enabled         = security.value.tls_rsa_with_aes256_cbc_sha_ciphers_enabled
      triple_des_ciphers_enabled                          = security.value.triple_des_ciphers_enabled
    }
  }

  # Sign-in block
  dynamic "sign_in" {
    for_each = var.sign_in == null ? [] : [var.sign_in]
    content {
      enabled = sign_in.value.enabled
    }
  }

  # Sign-up block
  dynamic "sign_up" {
    for_each = var.sign_up == null ? [] : [var.sign_up]
    content {
      enabled = sign_up.value.enabled
      terms_of_service {
        consent_required = sign_up.value.terms_of_service.consent_required
        enabled          = sign_up.value.terms_of_service.enabled
        text             = sign_up.value.terms_of_service.text
      }
    }
  }

  # Tenant Access block
  dynamic "tenant_access" {
    for_each = var.tenant_access == null ? [] : [var.tenant_access]
    content {
      enabled = tenant_access.value.enabled
    }
  }

  # Public IP Address ID
  public_ip_address_id = var.public_ip_address_id

  # Public network access
  public_network_access_enabled = var.public_network_access_enabled

  # Virtual network configuration
  dynamic "virtual_network_configuration" {
    for_each = var.virtual_network_configuration == null ? [] : [var.virtual_network_configuration]
    content {
      subnet_id = virtual_network_configuration.value.subnet_id
    }
  }

  # Gateway settings
  gateway_disabled = var.gateway_disabled

  # Ensure that the resource group is created before attempting to deploy the API Management Component
  depends_on = [module.base]
}
