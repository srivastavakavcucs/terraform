# ------------------------------------------------------------------------------
# APIM - Core (flat, not environment-specific)
# ------------------------------------------------------------------------------
variable "apim_name" {
  description = "Name of the existing API Management service."
  type        = string
}

variable "apim_resource_group_name" {
  description = "Resource group that contains the API Management service."
  type        = string
}

# ------------------------------------------------------------------------------
# api_settings
# Mirrors apim_api_config in apim_exports.bicep and parameters.<env>.json
# ------------------------------------------------------------------------------
variable "api_settings" {
  description = "API configuration. Mirrors the api_settings parameter block in the ARM parameters files."
  type = object({
    name = string
    properties = object({
      apiRevision          = string
      apiType              = optional(string, "http")
      displayName          = string
      description          = optional(string, "")
      format               = optional(string, "openapi")
      path                 = string
      protocols            = list(string)
      subscriptionRequired = bool

      subscriptionKeyParameterNames = optional(object({
        header = optional(string, "Ocp-Apim-Subscription-Key")
        query  = optional(string, "subscription-key")
        }), {
        header = "Ocp-Apim-Subscription-Key"
        query  = "subscription-key"
      })

      contact = optional(object({
        email = optional(string, "")
      }), { email = "" })

      # authenticationSettings is accepted but not mapped to a resource property
      # (APIM REST API handles it via the spec import)
      authenticationSettings = optional(any, null)
    })
  })
}

# ------------------------------------------------------------------------------
# product_settings
# Mirrors apim_product_config in apim_exports.bicep and parameters.<env>.json
# ------------------------------------------------------------------------------
variable "product_settings" {
  description = "Product configuration. Mirrors the product_settings parameter block in the ARM parameters files."
  type = object({
    name = string
    properties = object({
      displayName          = string
      description          = optional(string, "")
      subscriptionRequired = optional(bool, true)
      approvalRequired     = optional(bool, false)
      subscriptionsLimit   = optional(number, null)
      state                = optional(string, "published")
      terms                = optional(string, null)
    })
  })
}

# ------------------------------------------------------------------------------
# subscription_settings
# Mirrors apim_subscription_config in apim_exports.bicep and parameters.<env>.json
# ------------------------------------------------------------------------------
variable "subscription_settings" {
  description = "Subscription configuration. Mirrors the subscription_settings parameter block in the ARM parameters files."
  type = object({
    name = string
    properties = object({
      displayName  = string
      allowTracing = bool
    })
  })
}

# ------------------------------------------------------------------------------
# File contents (loaded by the caller, equivalent to loadTextContent() in Bicep)
# ------------------------------------------------------------------------------
variable "api_spec_content" {
  description = "Full OAS/Swagger spec content. Caller uses: file(\"../openapi/swagger.json\")."
  type        = string
}

variable "api_policy_content" {
  description = "Raw XML policy content. Caller uses: file(\"../policies/api-policy.<env>.xml\")."
  type        = string
}

# ------------------------------------------------------------------------------
# Subscription state (not in the original parameters files; added as a separate
# input so it can be overridden without touching the settings object)
# ------------------------------------------------------------------------------
variable "subscription_state" {
  description = "Initial state of the APIM subscription."
  type        = string
  default     = "active"
  validation {
    condition     = contains(["active", "cancelled", "expired", "rejected", "submitted", "suspended"], var.subscription_state)
    error_message = "subscription_state must be one of: active, cancelled, expired, rejected, submitted, suspended."
  }
}
