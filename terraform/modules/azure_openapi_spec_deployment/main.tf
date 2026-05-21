
# ------------------------------------------------------------------------------
# API
# Bicep: resource apim_api 'Microsoft.ApiManagement/service/apis@2022-08-01'
# ------------------------------------------------------------------------------
resource "azurerm_api_management_api" "this" {
  name                  = local.api.name
  resource_group_name   = var.apim_resource_group_name
  api_management_name   = var.apim_name
  revision              = local.api.properties.apiRevision
  display_name          = local.api.properties.displayName
  description           = local.api.properties.description
  path                  = local.api.properties.path
  protocols             = local.api.properties.protocols
  api_type              = local.api.properties.apiType
  subscription_required = local.api.properties.subscriptionRequired

  # Bicep: union(api_settings.properties, { value: api_spec_content })
  import {
    content_format = local.api.properties.format
    content_value  = var.api_spec_content
  }

  subscription_key_parameter_names {
    header = local.api.properties.subscriptionKeyParameterNames.header
    query  = local.api.properties.subscriptionKeyParameterNames.query
  }

  dynamic "contact" {
    for_each = local.api.properties.contact.email != "" ? [1] : []
    content {
      email = local.api.properties.contact.email
    }
  }
}

# ------------------------------------------------------------------------------
# API Policy
# Bicep: module api_policy 'policies/apim_api_policy.bicep'
#        → resource Microsoft.ApiManagement/service/apis/policies  name:'policy'  format:'rawxml'
# ------------------------------------------------------------------------------
resource "azurerm_api_management_api_policy" "this" {
  api_name            = azurerm_api_management_api.this.name
  api_management_name = var.apim_name
  resource_group_name = var.apim_resource_group_name
  xml_content         = var.api_policy_content
}

# ------------------------------------------------------------------------------
# Product
# Bicep: module apim_product 'products/apim_product.bicep'
#        → resource Microsoft.ApiManagement/service/products
# Note: approval_required and subscriptions_limit are conditionally null when
#       subscription_required = false, matching the Bicep union() logic.
# ------------------------------------------------------------------------------
resource "azurerm_api_management_product" "this" {
  product_id            = local.prod.name
  api_management_name   = var.apim_name
  resource_group_name   = var.apim_resource_group_name
  display_name          = local.prod.properties.displayName
  description           = local.prod.properties.description != "" ? local.prod.properties.description : "Product for ${local.prod.name}"
  terms                 = local.prod.properties.terms
  subscription_required = local.prod.properties.subscriptionRequired
  approval_required     = local.prod.properties.subscriptionRequired ? local.prod.properties.approvalRequired : null
  subscriptions_limit   = local.prod.properties.subscriptionRequired ? local.prod.properties.subscriptionsLimit : null
  published             = local.prod.properties.state == "published"

  depends_on = [azurerm_api_management_api.this]
}

# ------------------------------------------------------------------------------
# Product <-> API association
# Bicep: module product_apis 'api/product_api.bicep' (for-loop, single item here)
#        → resource Microsoft.ApiManagement/service/products/apis
# ------------------------------------------------------------------------------
resource "azurerm_api_management_product_api" "this" {
  api_name            = azurerm_api_management_api.this.name
  product_id          = azurerm_api_management_product.this.product_id
  api_management_name = var.apim_name
  resource_group_name = var.apim_resource_group_name
}

# ------------------------------------------------------------------------------
# Subscription (scoped to the product)
# Bicep: module apim_subscription 'subscription/subscription.bicep'
#        → resource Microsoft.ApiManagement/service/subscriptions
#        scope: '/products/${apim_product.outputs.resourceId}'
# ------------------------------------------------------------------------------
resource "azurerm_api_management_subscription" "this" {
  subscription_id     = local.sub.name
  api_management_name = var.apim_name
  resource_group_name = var.apim_resource_group_name
  display_name        = local.sub.properties.displayName
  product_id          = azurerm_api_management_product.this.id
  allow_tracing       = local.sub.properties.allowTracing
  state               = var.subscription_state

  depends_on = [azurerm_api_management_product_api.this]
}
