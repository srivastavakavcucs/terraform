/*
--------------------------------------------------------------------------------
  MODULE DATA SOURCES
--------------------------------------------------------------------------------
*/

# Reference existing Service Fabric Managed Cluster
data "azapi_resource" "sfmc" {
  type      = "Microsoft.ServiceFabric/managedClusters@2022-01-01"
  name      = var.cluster_name
  parent_id = "/subscriptions/${data.azapi_client_config.current.subscription_id}/resourceGroups/${var.sfmc_cluster_resource_group_name}"
}

# Reference existing Managed Identity
data "azapi_resource" "sfmc_managed_identity" {
  type                   = "Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30"
  name                   = var.sfmc_managed_identity_name
  parent_id              = "/subscriptions/${data.azapi_client_config.current.subscription_id}/resourceGroups/${var.sfmc_resource_group_name}"
  response_export_values = ["*"]
}

# Get current Azure subscription details
data "azapi_client_config" "current" {}
