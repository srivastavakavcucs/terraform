
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

variable "TENANT_ID" {
  description = "The value of the tenant id"
  type        = string
}