#-----------------------------------------------------------------------
# Setup Module for Azure Resource Group Integration Tests
# Purpose: Dynamically handle resource group - create if doesn't exist, use if exists
# 
# PREREQUISITE: Azure CLI must be authenticated before running tests
# Run: az login (or use pipeline authentication)
#
# Use Cases:
# 1. Variable provided + RG doesn't exist → Creates RG
# 2. Variable provided + RG exists → Uses existing RG (idempotent)
# 3. Variable empty → Skips all execution
#
# Cleanup Logic:
# - If RG was created by this setup → Deletes on destroy
# - If RG existed before → Preserves on destroy
#-----------------------------------------------------------------------

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.3"
    }
  }
}

# Variable declarations for setup module
variable "custom_resource_group_name" {
  type        = string
  description = "Name of the resource group to check/create. If empty, no action is taken."
  default     = ""
}

variable "region" {
  type        = string
  description = "Azure region for resource group if creation is needed"
}

variable "INTEGRATION_TEST_SUBSCRIPTION_ID" {
  type        = string
  description = "Azure subscription ID for integration tests"
}

variable "TENANT_ID" {
  type        = string
  description = "Azure tenant ID"
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags to apply to resources"
  default     = {}
}

#-----------------------------------------------------------------------
# Locals: Determine execution path based on variable value
#-----------------------------------------------------------------------
locals {
  # Use Case 3: Check if variable is empty - if so, skip all execution
  should_execute = length(trimspace(var.custom_resource_group_name)) > 0
}

# Provider configuration
provider "azurerm" {
  features {}
  use_oidc        = true
  subscription_id = var.INTEGRATION_TEST_SUBSCRIPTION_ID
  tenant_id       = var.TENANT_ID
}

#-----------------------------------------------------------------------
# Pre-check: Does the resource group already exist?
# This determines whether we need to create it
#-----------------------------------------------------------------------
data "external" "rg_exists" {
  count   = local.should_execute ? 1 : 0
  program = ["pwsh", "-NoLogo", "-NoProfile", "-Command", "$name='${var.custom_resource_group_name}'; $sub='${var.INTEGRATION_TEST_SUBSCRIPTION_ID}'; $exists=az group exists --name $name --subscription $sub --only-show-errors; $json=@{exists=$exists}|ConvertTo-Json -Compress; Write-Output $json"]
}

#-----------------------------------------------------------------------
# Use Case 1 & 2: Ensure resource group exists with intelligent cleanup
# - Creates RG if doesn't exist (Use Case 1)
# - Uses existing RG if exists (Use Case 2)
# - Tracks creation state in triggers for destroy-time decision
#-----------------------------------------------------------------------
resource "null_resource" "ensure_rg_exists" {
  count = local.should_execute ? 1 : 0

  # Creation provisioner: Only creates if RG doesn't exist
  provisioner "local-exec" {
    when    = create
    command = "if ('${data.external.rg_exists[0].result.exists}' -eq 'false') { Write-Host 'Resource group does not exist. Creating...'; az group create --name '${var.custom_resource_group_name}' --location '${var.region}' --subscription '${var.INTEGRATION_TEST_SUBSCRIPTION_ID}' --tags Purpose='Terraform_Integration_Testing' Managed_By='Terraform_Test_Setup' --only-show-errors; az group wait --created --name '${var.custom_resource_group_name}' --subscription '${var.INTEGRATION_TEST_SUBSCRIPTION_ID}' --only-show-errors; Write-Host 'Resource group created successfully.' } else { Write-Host 'Resource group already exists. Using existing resource group.' }"
    interpreter = ["pwsh", "-NoLogo", "-NoProfile", "-Command"]
  }

  # Destroy provisioner: Only deletes if we created the RG
  provisioner "local-exec" {
    when    = destroy
    command = "if ('${self.triggers.was_provisioned}' -eq 'true') { Write-Host 'Cleaning up resource group that was created by this test...'; az group delete --name '${self.triggers.rg_name}' --subscription '${self.triggers.subscription_id}' --yes --no-wait --only-show-errors; Write-Host 'Resource group deletion initiated.' } else { Write-Host 'Resource group existed before test. Skipping deletion.' }"
    interpreter = ["pwsh", "-NoLogo", "-NoProfile", "-Command"]
  }

  # Triggers store state for destroy-time provisioner access
  triggers = {
    rg_name         = var.custom_resource_group_name
    subscription_id = var.INTEGRATION_TEST_SUBSCRIPTION_ID
    was_provisioned = local.should_execute ? (data.external.rg_exists[0].result.exists == "false" ? "true" : "false") : "false"
  }
}

#-----------------------------------------------------------------------
# Use Case 1 & 2: Read the resource group after ensuring it exists
# Use Case 3: Skipped (count = 0)
#-----------------------------------------------------------------------
data "azurerm_resource_group" "final" {
  count      = local.should_execute ? 1 : 0
  name       = var.custom_resource_group_name
  depends_on = [null_resource.ensure_rg_exists]
}

#-----------------------------------------------------------------------
# Outputs: Resource group information
# Returns null/empty if custom_resource_group_name was empty (Use Case 3)
#-----------------------------------------------------------------------
output "resource_group_name" {
  description = "Name of the existing or newly created resource group"
  value       = local.should_execute ? data.azurerm_resource_group.final[0].name : null
}

output "resource_group_id" {
  description = "ID of the existing or newly created resource group"
  value       = local.should_execute ? data.azurerm_resource_group.final[0].id : null
}

output "resource_group_location" {
  description = "Location of the existing or newly created resource group"
  value       = local.should_execute ? data.azurerm_resource_group.final[0].location : null
}

output "was_provisioned" {
  description = "True if setup created the RG; false if it already existed"
  value       = local.should_execute ? (data.external.rg_exists[0].result.exists == "false") : false
}

output "execution_skipped" {
  description = "True when custom_resource_group_name is empty"
  value       = !local.should_execute
}