#--------------------------------------------------------------------
# Create the network contributor roles needed for the cluster
#--------------------------------------------------------------------

# Assign Network Contributor role to the ARO Cluster Service Principal for the VNet
resource "azurerm_role_assignment" "aro_cluster_service_principal_vnet_network_contributor" {
  scope                = module.base.vnet_resource_id
  role_definition_name = "Network Contributor"
  principal_id         = var.aro_cluster_aad_sp_object_id
  principal_type       = "ServicePrincipal"

  skip_service_principal_aad_check = true

  lifecycle {
    ignore_changes = [role_definition_name, principal_id]
  }
}

# Assign Network Contributor role to the Resource Provider Service Principal for the VNet
resource "azurerm_role_assignment" "aro_resource_provider_service_principal_vnet_network_contributor" {
  scope                = module.base.vnet_resource_id
  role_definition_name = "Network Contributor"
  principal_id         = var.aro_resource_provider_aad_sp_object_id
  principal_type       = "ServicePrincipal"

  skip_service_principal_aad_check = true

  lifecycle {
    ignore_changes = [role_definition_name, principal_id]
  }
}

# Assign Network Contributor role to the ARO Cluster Service Principal for the main route table
resource "azurerm_role_assignment" "aro_cluster_service_principal_main_route_table_network_contributor" {
  count                = local.main_route_table_id != null ? 1 : 0
  scope                = local.main_route_table_id
  role_definition_name = "Network Contributor"
  principal_id         = var.aro_cluster_aad_sp_object_id
  principal_type       = "ServicePrincipal"

  skip_service_principal_aad_check = true

  lifecycle {
    ignore_changes = [role_definition_name, principal_id]
  }
}

# Assign Network Contributor role to the Resource Provider for the main route table
resource "azurerm_role_assignment" "aro_resource_provider_service_principal_main_route_table_network_contributor" {
  count                = local.main_route_table_id != null ? 1 : 0
  scope                = local.main_route_table_id
  role_definition_name = "Network Contributor"
  principal_id         = var.aro_resource_provider_aad_sp_object_id
  principal_type       = "ServicePrincipal"

  skip_service_principal_aad_check = true

  lifecycle {
    ignore_changes = [role_definition_name, principal_id]
  }
}

# Assign Network Contributor role to the ARO Cluster Service Principal for the worker route table
resource "azurerm_role_assignment" "aro_cluster_service_principal_worker_route_table_network_contributor" {
  count                = local.create_worker_role_assignments ? 1 : 0
  scope                = local.worker_route_table_id
  role_definition_name = "Network Contributor"
  principal_id         = var.aro_cluster_aad_sp_object_id
  principal_type       = "ServicePrincipal"

  skip_service_principal_aad_check = true

  lifecycle {
    ignore_changes = [role_definition_name, principal_id]
  }
}

# Assign Network Contributor role to the Resource Provider for the worker route table
resource "azurerm_role_assignment" "aro_resource_provider_service_principal_worker_route_table_network_contributor" {
  count                = local.create_worker_role_assignments ? 1 : 0
  scope                = local.worker_route_table_id
  role_definition_name = "Network Contributor"
  principal_id         = var.aro_resource_provider_aad_sp_object_id
  principal_type       = "ServicePrincipal"

  skip_service_principal_aad_check = true

  lifecycle {
    ignore_changes = [role_definition_name, principal_id]
  }
}
