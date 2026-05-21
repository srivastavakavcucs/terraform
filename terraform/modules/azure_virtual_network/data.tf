# Get the current Azure Subscription
data "azurerm_subscription" "current" {}

# Data block for Nat Gateways
data "azurerm_nat_gateway" "nat_gateways" {
  for_each = { for subnet_name, subnet in var.subnets : subnet_name => subnet if subnet.nat_gateway != null }

  name                = each.value.nat_gateway.name
  resource_group_name = each.value.nat_gateway.resource_group_name
}

# Data block for Network Security Groups
data "azurerm_network_security_group" "nsgs" {
  for_each = { for subnet_name, subnet in var.subnets : subnet_name => subnet if subnet.network_security_group != null }

  name                = each.value.network_security_group.name
  resource_group_name = each.value.network_security_group.resource_group_name
}

# Data block for Route Tables
data "azurerm_route_table" "route_tables" {
  for_each = { for subnet_name, subnet in var.subnets : subnet_name => subnet if subnet.route_table != null }

  name                = each.value.route_table.name
  resource_group_name = each.value.route_table.resource_group_name
}

# Flatten Service Endpoint Policies into a list and resolve IDs
locals {
  service_endpoint_policies_flattened = flatten([
    for subnet_name, subnet in var.subnets :
    [
      for key, policy in(subnet.service_endpoint_policies != null ? subnet.service_endpoint_policies : {}) :
      {
        unique_key          = "${subnet_name}_${key}"
        name                = policy.name
        resource_group_name = policy.resource_group_name
      }
    ]
  ])
}
