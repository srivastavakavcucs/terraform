#-----------------------------------------------------------------------
# Terraform Test File for Azure Resource Group Module
# Test Case: Create New Resource Group
#
# This test validates that the module correctly creates a NEW resource
# group with auto-generated naming when custom_resource_group_name is null.
# After the test completes, the resource group is automatically destroyed.
#-----------------------------------------------------------------------

# Variable declarations required for test file
variable "region" {
  type        = string
  description = "Azure region for resource deployment"
}

variable "app_name" {
  type        = string
  description = "Application name"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "environment_number_suffix" {
  type        = string
  description = "Environment number suffix"
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags to apply to resources"
}

variable "INTEGRATION_TEST_SUBSCRIPTION_ID" {
  type        = string
  description = "Azure subscription ID for integration tests"
}

variable "TENANT_ID" {
  type        = string
  description = "Azure tenant ID"
}

provider "azurerm" {
  features {}
  use_oidc        = true
  subscription_id = var.INTEGRATION_TEST_SUBSCRIPTION_ID
  tenant_id       = var.TENANT_ID
}

provider "azurerm" {
  alias           = "private_dns_zone_subscription_provider"
  features {}
  use_oidc        = true
  subscription_id = var.INTEGRATION_TEST_SUBSCRIPTION_ID
  tenant_id       = var.TENANT_ID
}

#-----------------------------------------------------------------------
# Test Run: Create New Resource Group
# This test applies the module configuration, validates outputs, and
# automatically destroys all created resources after completion.
#-----------------------------------------------------------------------
run "integration_test_create_new_resource_group" {
  command = apply

  # Module under test
  module {
    source = "../../../modules/azure_resource_group"
  }

  variables {
    # Required Variables - From tfvars
    region                     = var.region
    app_name                   = var.app_name
    component_name             = "testing-resource-group"
    environment                = var.environment
    environment_number_suffix  = var.environment_number_suffix
    
    # Set to null to test NEW resource group creation path
    # When null, module generates name following pattern: rg-{app_name}-{component}-{environment}-{region}-{suffix}
    custom_resource_group_name = null

    # Required Tags - From tfvars
    common_tags = var.common_tags

    # Optional Tags for test identification
    resource_tags = {
      Test_Type   = "Terraform_Test_POC"
      Test_Module = "azure_resource_group"
      Test_Case   = "Create_New_RG"
      Temporary   = "true"
    }

  }

  # Assert 1: Resource group name is auto-generated and not null
  assert {
    condition     =  output.name != null && output.name != ""
    error_message = "Resource group name should be auto-generated and not null when custom_resource_group_name is null"
  }

  # Assert 2: Resource group name follows naming convention (starts with 'rg-')
  assert {
    condition     =  ( can(regex("^rg-", output.name)) )
    error_message = "Resource group name should follow naming convention and start with 'rg-'"
  }

  # Assert 3: Resource group name contains expected components (app_name and environment)
  assert {
    condition = (
      can(regex(var.app_name, output.name)) && 
      can(regex(var.environment, output.name))
    )
    error_message = "Auto-generated resource group name should contain app_name (${var.app_name}) and environment (${var.environment})"
  }
}


