#--------------------------------------------------------------------------------
# Create the Azure Red Hat OpenShift cluster
#--------------------------------------------------------------------------------

#--------------------------------------------------------------------------------
# Source: Azure Naming and Tagging Standards v4.0.0.0_20241022.docx
# Resource group	Naming: rg-<app or service name>-<subscription purpose>-<###>
# Example : rg-omb-redis-dev-001
#--------------------------------------------------------------------------------

# Create the Azure Red Hat OpenShift (ARO) Cluster
resource "azurerm_redhat_openshift_cluster" "this" {
  name                = "${var.app_name}-aro-${var.environment}-${var.environment_number_suffix}"
  location            = module.base.location
  resource_group_name = module.base.resource_group_name

  # Cluster profile configuration
  cluster_profile {
    version                     = var.openshift_version
    domain                      = var.domain
    pull_secret                 = var.rh_pull_secret
    managed_resource_group_name = "rg-managed-${var.app_name}-aro-${var.environment}-${var.environment_number_suffix}"
  }

  # Network profile for the cluster
  network_profile {
    pod_cidr                                     = var.pod_cidr
    service_cidr                                 = var.service_cidr
    preconfigured_network_security_group_enabled = var.preconfigured_network_security_group_enabled
  }

  # Main (Control Plane) node configuration
  main_profile {
    subnet_id                  = module.base.subnet_name_segments_to_subnet_id_map[var.main_subnet_name_segment]
    vm_size                    = var.main_vm_size
    encryption_at_host_enabled = var.main_node_encryption_at_host_enabled
    # Configures the control plane nodes with encryption at host enabled by default
  }

  # Worker node configuration
  worker_profile {
    subnet_id                  = module.base.subnet_name_segments_to_subnet_id_map[var.worker_subnet_name_segment]
    node_count                 = var.worker_node_count
    vm_size                    = var.worker_node_vm_size
    disk_size_gb               = var.worker_node_disk_size_gb
    encryption_at_host_enabled = var.worker_node_encryption_at_host_enabled
    # Configures the worker nodes with encryption at host enabled by default
  }

  # API server profile for access control
  api_server_profile {
    visibility = var.api_server_visibility
  }

  # Ingress controller configuration
  ingress_profile {
    visibility = var.ingress_visibility
  }

  # Service Principal credentials for cluster authentication
  service_principal {
    client_id     = var.sp_client_id
    client_secret = var.sp_client_secret
  }

  tags = module.base.tags

  timeouts {
    create = "180m"
    delete = "180m"
  }

  # Ensure that the base module, role assignments and route table updates are completed before the ARO cluster is created
  depends_on = [
    module.base,
    azurerm_role_assignment.aro_cluster_service_principal_vnet_network_contributor,
    azurerm_role_assignment.aro_resource_provider_service_principal_vnet_network_contributor,
    azurerm_role_assignment.aro_cluster_service_principal_main_route_table_network_contributor,
    azurerm_role_assignment.aro_cluster_service_principal_worker_route_table_network_contributor,
    azurerm_role_assignment.aro_resource_provider_service_principal_main_route_table_network_contributor,
    azurerm_role_assignment.aro_resource_provider_service_principal_worker_route_table_network_contributor,
  ]

  provider = azurerm
}
