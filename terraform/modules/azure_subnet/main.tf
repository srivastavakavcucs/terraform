#-----------------------------------------------------------
# Azure Vitrual Subnet
#-----------------------------------------------------------

resource "azurerm_subnet" "subnet" {
  name                 = var.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = var.address_prefixes

  # Set default outbound access
  default_outbound_access_enabled = var.default_outbound_access_enabled

  # Set private endpoint network policies
  private_endpoint_network_policies = var.private_endpoint_network_policies

  # Set private link service network policies
  private_link_service_network_policies_enabled = var.private_link_service_network_policies_enabled

  # Add service endpoints if provided
  service_endpoints = var.service_endpoints

  # Add service endpoint policies if provided
  service_endpoint_policy_ids = var.service_endpoint_policy_ids

  # Dynamic block to handle delegations if provided
  dynamic "delegation" {
    for_each = length(var.delegations) > 0 ? var.delegations : []
    content {
      name = delegation.value.name

      service_delegation {
        name    = delegation.value.service_delegation.name
        actions = delegation.value.service_delegation.actions
      }
    }
  }
}
