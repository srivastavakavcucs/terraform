
variable "INTEGRATION_TEST_SUBSCRIPTION_ID" {
  description = "ID of the Azure Subscription where the resources will be deployed."
  type        = string
}

# The subscription ID for the VyStar Shared Hub Azure account (Required)
variable "SHARED_HUB_SUBSCRIPTION_ID" {
  description = "The subscription ID for the VyStar Shared Hub subscription Azure account. This is required for configuring the Private DNS Zones VNet."
  type        = string
  nullable    = false
}

variable "SERVICE_PLAN_ID" {
  description = "The resource ID of an existing App Service Plan for the integration test."
  type        = string
}

variable "STORAGE_ACCOUNT_NAME" {
  description = "The name of an existing Storage Account for the integration test."
  type        = string
}

variable "STORAGE_ACCOUNT_ACCESS_KEY" {
  description = "The access key of the Storage Account for the integration test."
  type        = string
  sensitive   = true
}
