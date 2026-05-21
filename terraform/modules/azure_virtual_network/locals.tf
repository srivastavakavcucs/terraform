
#-------------------------------------------------------------------------------------------
# Local Variables to generate the subnet in the format expected by the Azure Verified Module
#-------------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------------------
#VyStar Naming Standards: Azure Naming and Tagging Standards v4.0.0.0_20241022.docx
# Subnet : snet-<subscription purpose>-<region>-<###>
# Examples: snet-openshift-mstr-01-10.x.x.x_24
#           snet-redis-01-10.x.x.x_24
#           snet-database-01-10.x.x.x_24
#-------------------------------------------------------------------------------------------
locals {
  service_endpoint_policies_map = {
    for item in local.service_endpoint_policies_flattened :
    item.unique_key => {
      id = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${item.resource_group_name}/providers/Microsoft.Network/serviceEndpointPolicies/${item.name}"
    }
  }

  subnets = {
    for subnet_name, subnet in var.subnets : subnet_name => merge(
      subnet,
      {
        address_prefix   = subnet.address_prefix,
        address_prefixes = subnet.address_prefixes,
        name = format(
          "snet-%s-%s-%s-%s",
          subnet.name_segment,
          module.base.region,
          module.base.environment_number_suffix,
          replace(
            try(join("_", subnet.address_prefixes), subnet.address_prefix != null ? subnet.address_prefix : "unknown"),
            "/",
            "_"
          )
        ),
        nat_gateway = subnet.nat_gateway != null ? {
          id = try(data.azurerm_nat_gateway.nat_gateways[subnet_name].id, null)
        } : null,
        network_security_group = subnet.network_security_group != null ? {
          id = try(data.azurerm_network_security_group.nsgs[subnet_name].id, null)
        } : null,
        route_table = subnet.route_table != null ? {
          id = try(data.azurerm_route_table.route_tables[subnet_name].id, null)
        } : null,
        service_endpoint_policies = subnet.service_endpoint_policies != null ? {
          for key, policy in subnet.service_endpoint_policies :
          key => {
            id = try(local.service_endpoint_policies_map["${subnet_name}_${key}"].id, null)
          }
        } : null,
        private_endpoint_network_policies             = subnet.private_endpoint_network_policies,
        private_link_service_network_policies_enabled = subnet.private_link_service_network_policies_enabled,
        service_endpoints                             = subnet.service_endpoints,
        default_outbound_access_enabled               = subnet.default_outbound_access_enabled,
        sharing_scope                                 = subnet.sharing_scope,
        delegation                                    = subnet.delegation,
        timeouts                                      = subnet.timeouts,
        role_assignments                              = subnet.role_assignments
      }
    )
  }

  # subnet_names = [
  #   for subnet_key, subnet in var.subnets :
  #   format(
  #     "snet-%s-%s-%s-%s",
  #     subnet.name_segment,
  #     module.base.region,
  #     module.base.environment_number_suffix,
  #     replace(
  #       try(join("_", subnet.address_prefixes), subnet.address_prefix != null ? subnet.address_prefix : "unknown"),
  #       "/",
  #       "_"
  #     )
  #   )
  # ]
}
