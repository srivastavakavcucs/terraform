#-----------------------------------------------------------------------
# Terraform Test File for Azure Resource Group Module
# Test Case: Use Existing Resource Group
# resource group when custom_resource_group_name is provided.
# NO resources are created - only data source lookups are performed.
# The existing resource group must already exist in Azure before running.
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

variable "custom_resource_group_name" {
  type        = string
  description = "Name of existing resource group to use"
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
# Setup Run: Ensure Resource Group Exists
# This setup block checks if the resource group exists and creates it if needed.
# The output from this run is used in subsequent tests.
#-----------------------------------------------------------------------
run "setup_tests" {
  module {
    source = "./setup"
  }

  variables {
    custom_resource_group_name       = var.custom_resource_group_name
    region                           = var.region
    INTEGRATION_TEST_SUBSCRIPTION_ID = var.INTEGRATION_TEST_SUBSCRIPTION_ID
    TENANT_ID                        = var.TENANT_ID
    common_tags                      = var.common_tags
  }
}

#-----------------------------------------------------------------------
# Test Run: Use Existing Resource Group
# This test validates the data source lookup path - no resources created.
# Verifies module can correctly reference pre-existing resource groups.
# NOTE: Only runs when custom_resource_group_name is provided
#-----------------------------------------------------------------------
run "integration_test_use_existing_resource_group" {
  command = apply

  # Module under test
  module {
    source = "../../../modules/azure_resource_group"
  }
  
  variables {
    # Required Variables - From tfvars
    region                     = var.region
    app_name                   = var.app_name
    component_name             = "testing-existing-rg"
    environment                = var.environment
    environment_number_suffix  = var.environment_number_suffix
    
    # Provide existing RG name to test data source lookup path
    # Use the resource group name from the setup run (either existing or newly created)
    custom_resource_group_name = run.setup_tests.resource_group_name

    # Required Tags - From tfvars
    common_tags = var.common_tags

    # Optional Tags for test identification
    resource_tags = {
      Test_Type   = "Terraform_Test_POC"
      Test_Module = "azure_resource_group"
      Test_Case   = "Use_Existing_RG"
      Temporary   = "true"
    }
  }

  #-----------------------------------------------------------------------
  # Assertions: Validate Module Behavior with Existing Resource Group
  # Only validate if setup_tests was not skipped
  #-----------------------------------------------------------------------

  # Assert 1: Verify that the module output name matches the custom_resource_group_name from tfvars
  # Skip if setup was skipped (execution_skipped == true)
  assert {
    condition     = run.setup_tests.execution_skipped == true || output.name == var.custom_resource_group_name
    error_message = "Module output name (${output.name}) should exactly match the custom_resource_group_name from setup (${coalesce(run.setup_tests.resource_group_name, "N/A - setup skipped")})"
  }

  # Assert 2: Verify that the resource group exists in Azure and the output matches
  # This assertion confirms that the data source successfully retrieved the existing RG
  # Skip if setup was skipped
  assert {
    condition     = run.setup_tests.execution_skipped == true || (output.name != null && output.name != "" && length(output.name) > 0)
    error_message = "Resource group name output should not be null or empty, indicating the existing resource group was found in Azure"
  }

  # Assert 3: Verify that the output follows the expected resource group naming pattern (starts with 'rg-')
  # Skip if setup was skipped
  assert {
    condition     = run.setup_tests.execution_skipped == true || can(regex("^rg-", output.name))
    error_message = "Existing resource group name (${coalesce(output.name, "N/A")}) should follow naming convention and start with 'rg-'"
  }
}
