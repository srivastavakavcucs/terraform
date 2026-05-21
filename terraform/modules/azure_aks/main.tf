# AKS Cluster with Managed Identity
resource "azurerm_kubernetes_cluster" "this" {
  name                = "${var.app_name}-aks-${var.environment}-${var.environment_number_suffix}"
  location            = module.base.location
  resource_group_name = module.base.resource_group_name
  dns_prefix          = "${var.app_name}-aks-${var.environment}-${var.environment_number_suffix}"

  sku_tier = "Standard"
  identity {
    type         = "UserAssigned"
    identity_ids = [data.azurerm_user_assigned_identity.aks_identity.id]
  }

  default_node_pool {
    name                 = "default"
    vm_size              = var.vm_size
    auto_scaling_enabled = true
    vnet_subnet_id       = module.base.subnet_name_segments_to_subnet_id_map[var.node_subnet_name_segment]
    pod_subnet_id        = module.base.subnet_name_segments_to_subnet_id_map[var.pod_subnet_name_segment]
    min_count            = var.min_node_count
    max_count            = var.max_node_count
  }

  azure_policy_enabled = var.enable_psa_support

  network_profile {
    network_plugin = "azure"
    service_cidr   = var.service_cidr
    dns_service_ip = var.dns_service_ip
    outbound_type  = "userDefinedRouting"
  }

  private_dns_zone_id     = data.azurerm_private_dns_zone.aks_private_dns.id
  private_cluster_enabled = true

  # Enable OIDC and Workload Identity
  oidc_issuer_enabled               = true
  workload_identity_enabled         = true
  role_based_access_control_enabled = true
  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "30m"
  }

  depends_on = [module.base]
}