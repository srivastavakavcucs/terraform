provider "azurerm" {
  subscription_id = var.INTEGRATION_TEST_SUBSCRIPTION_ID
  features {}
}

provider "azurerm" {
  alias           = "private_dns_zone_subscription_provider"
  subscription_id = var.SHARED_HUB_SUBSCRIPTION_ID
  features {}
}
