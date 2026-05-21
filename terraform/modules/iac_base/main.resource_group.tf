#-------------------------------------------------------------------------
# Create an Azure Resource Group for the specified component if needed.
# Use the Azure Verified Module to Create or Manage the Resource Group.
#--------------------------------------------------------------------------

####################################################################################
#  ENABLE THIS ONCE AGAIN WHEN PROVIDER 4.x SUPPORT IS ENABLED WITH A NEW RELEASE  #
# 👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇 #
####################################################################################

# module "azure_resource_group" {
#   source  = "Azure/avm-res-resources-resourcegroup/azurerm"
#   version = "0.1.0"

#   count = var.deploy_resource_group ? 1 : 0

#   # Required inputs
#   location = var.deploy_resource_group ? local.location : null
#   name     = var.deploy_resource_group ? local.resource_group_name : null
#   tags     = var.deploy_resource_group ? local.enhanced_tags : null

#   # Optional inputs
#   lock             = var.deploy_resource_group ? local.lock : null
#   enable_telemetry = var.deploy_resource_group ? local.enable_telemetry : null
#   role_assignments = var.deploy_resource_group ? local.role_assignments : null

#   # Force the provider to make it compatible with the AVM
#   providers = {
#     azurerm = azurerm.resource_group_provider
#   }
# }

####################################################################################
#  DELETE THE CODE BELOW ONCE WE UPGRADE TO THE LATEST AVM                         #
#  NOTE: This code was directly copied from the AVM                                #
# 👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇 #
####################################################################################

data "azurerm_subscription" "current" {}

locals {
  role_definition_resource_substring = "/providers/Microsoft.Authorization/roleDefinitions"
}

resource "azurerm_resource_group" "this" {
  count = var.custom_resource_group_name == null && var.deploy_resource_group ? 1 : 0

  location = var.deploy_resource_group ? local.location : null
  name     = var.deploy_resource_group ? local.resource_group_name : null
  tags     = var.deploy_resource_group ? local.enhanced_tags : null
}

data "azurerm_resource_group" "existing" {
  count = var.custom_resource_group_name != null ? 1 : 0

  name = var.custom_resource_group_name
}

# required AVM resources interfaces
resource "azurerm_management_lock" "this" {
  count = ((var.lock != null) && (var.deploy_resource_group)) ? 1 : 0

  lock_level = var.lock.kind
  name       = coalesce(var.lock.name, "lock-${var.lock.kind}")
  scope      = azurerm_resource_group.this[0].id
  notes      = var.lock.kind == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources."
}

resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  principal_id                           = each.value.principal_id
  scope                                  = azurerm_resource_group.this[0].id
  condition                              = each.value.condition
  condition_version                      = each.value.condition_version
  delegated_managed_identity_resource_id = each.value.delegated_managed_identity_resource_id
  role_definition_id                     = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? "/subscriptions/${data.azurerm_subscription.current.subscription_id}${each.value.role_definition_id_or_name}" : null
  role_definition_name                   = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? null : each.value.role_definition_id_or_name
  skip_service_principal_aad_check       = each.value.skip_service_principal_aad_check
}

data "azurerm_client_config" "telemetry" {
  count = ((var.enable_telemetry) && (var.deploy_resource_group)) ? 1 : 0
}

data "modtm_module_source" "telemetry" {
  count = ((var.enable_telemetry) && (var.deploy_resource_group)) ? 1 : 0

  module_path = path.module
}

resource "random_uuid" "telemetry" {
  count = ((var.enable_telemetry) && (var.deploy_resource_group)) ? 1 : 0
}

resource "modtm_telemetry" "telemetry" {
  count = ((var.enable_telemetry) && (var.deploy_resource_group)) ? 1 : 0

  tags = {
    subscription_id = one(data.azurerm_client_config.telemetry).subscription_id
    tenant_id       = one(data.azurerm_client_config.telemetry).tenant_id
    module_source   = one(data.modtm_module_source.telemetry).module_source
    module_version  = one(data.modtm_module_source.telemetry).module_version
    random_id       = one(random_uuid.telemetry).result
  }
}

####################################################################################
# ☝☝☝☝☝☝☝☝☝☝☝☝☝☝☝☝☝☝☝☝☝☝☝☝☝☝☝☝☝☝☝☝ #
#  DELETE THE CODE ABOVE ONCE WE UPGRADE TO THE LATEST AVM                         #
####################################################################################