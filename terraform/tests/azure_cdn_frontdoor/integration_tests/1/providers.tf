
provider "azurerm" {
  subscription_id = var.INTEGRATION_TEST_SUBSCRIPTION_ID
  features {}
}

provider "azurerm" {
  alias           = "private_dns_zone_subscription_provider"
  subscription_id = var.SHARED_HUB_SUBSCRIPTION_ID
  features {}
}

terraform {
  required_version = ">= 1.9.2"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.116, < 5.0.0"
    }
    modtm = {
      source  = "azure/modtm"
      version = "~> 0.3"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0"
    }
  }
}
