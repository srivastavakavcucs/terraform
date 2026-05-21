
#-------------------------------------------------------------------------------------------
# Locals
#-------------------------------------------------------------------------------------------

locals {
  #-------------------------------------------------------------------------------------------
  # Retrieve the VNet ID of for the specified environment if available.
  #-------------------------------------------------------------------------------------------

  vnet_resource_id = try(data.azurerm_virtual_network.this["fetch"].id, "")

  #-------------------------------------------------------------------------------------------
  # Generate a list of all subnet names, a map of the subnet name and subnet IDs
  # and route table map for subnet name to route table ID
  #-------------------------------------------------------------------------------------------

  # Step 1: Generate a list of subnet names
  subnet_names = [
    for subnet in data.azurerm_subnet.subnets : subnet.name
  ]

  # Step 2: Generate a map of subnet names and their subnet IDs
  subnet_map = {
    for subnet in data.azurerm_subnet.subnets : subnet.name => subnet.id
  }

  # Step 3: Generate a map of subnet names and their route table IDs
  route_table_map = {
    for subnet in data.azurerm_subnet.subnets : subnet.name => subnet.route_table_id
  }

  #-------------------------------------------------------------------------------------------
  # Retrieve the subnets ID for the subnet name segments provided.
  #-------------------------------------------------------------------------------------------

  # Step 1: Generate a map of subnet_name_segment as key and subnet_name as value
  #         where the name segment is a substring of the subnet name.
  #         Example: Name Segment 'redis' for subnet name 'snet-redis-10.190.5.0_24'
  subnet_name_segments_to_subnet_name_map = {
    for name_segment in var.subnet_name_segments :
    name_segment => one(
      [
        for subnet_name in local.subnet_names :
        subnet_name if can(regex(name_segment, subnet_name))
      ]
    )
  }

  # Step 2: Generate a map of name_segment as key and subnet ID as value
  #         Example:
  #         Key - Name Segment 'redis'
  #         Value - Subnet ID '/subscriptions/469217d4-0c3a-4e4d-8f72-f57391ea321e/resourceGroups/rg-omb-vnet-dev-002/providers/Microsoft.Network/virtualNetworks/vnet-omb-dev-eastus-002/subnets/snet-redis-eastus-002-10.190.6.0_24'
  subnet_name_segments_to_subnet_id_map = {
    for name_segment, subnet_name in local.subnet_name_segments_to_subnet_name_map :
    name_segment => lookup(local.subnet_map, subnet_name, null)
  }

  # Step 3:  Generate a map of subnet name segment as key and an object with subnet name, subnet ID, and route table ID as value
  subnet_name_segments_to_subnet_info = {
    for name_segment, subnet_name in local.subnet_name_segments_to_subnet_name_map :
    name_segment => {
      subnet_name    = subnet_name
      subnet_id      = lookup(local.subnet_map, subnet_name, null)
      route_table_id = lookup(local.route_table_map, subnet_name, null)
    }
  }

  #-------------------------------------------------------------------------------------------
  # Retrieve the subnets that will be used by the private endpoints.
  #-------------------------------------------------------------------------------------------

  # Step 1: Retrieve all subnet name segments from all the private endpoints that will be created.
  private_endpoint_subnet_name_segments = {
    for key, endpoint in var.private_endpoints : key => endpoint.private_endpoint_subnet_name_segment
  }

  # Step 2: Generate a map of private_endpoint_subnet_name_segment as key and subnet_name as value
  #         where the name segment is a substring of the subnet name.
  #         Example: Name Segment 'redis' for subnet name 'snet-redis-10.190.5.0_24'
  private_endpoint_subnet_name_segments_to_subnet_name_map = {
    for name_segment in values(local.private_endpoint_subnet_name_segments) :
    name_segment => one(
      [
        for subnet_name in local.subnet_names :
        subnet_name if can(regex(name_segment, subnet_name))
      ]
    )
  }

  # Step 3: Generate a map of name_segment as key and subnet ID as value
  #         Example:
  #         Key - Name Segment 'redis'
  #         Value - Subnet ID '/subscriptions/469217d4-0c3a-4e4d-8f72-f57391ea321e/resourceGroups/rg-omb-vnet-dev-002/providers/Microsoft.Network/virtualNetworks/vnet-omb-dev-eastus-002/subnets/snet-redis-eastus-002-10.190.6.0_24'
  private_endpoint_subnet_name_segments_to_subnet_id_map = {
    for name_segment, subnet_name in local.private_endpoint_subnet_name_segments_to_subnet_name_map :
    name_segment => lookup(local.subnet_map, subnet_name, null)
  }

  #-------------------------------------------------------------------------------------------
  # VyStar Naming Standards: Azure Naming and Tagging Standards v4.0.0.0_20241022.docx
  # Virtual network: vnet-<subscription purpose>-<region>-<###>
  # Examples: vnet-omb-dev-eastus-001
  #           vnet-omb-prod-westus-001
  #           vnet-eft-eastus2-001
  #-------------------------------------------------------------------------------------------

  vnet_name = var.custom_vnet_name != "" ? var.custom_vnet_name : "vnet-${var.app_name}-${var.environment}-${var.region}-${var.environment_number_suffix}"
  #-------------------------------------------------------------------------------------------
  # VyStar Naming Standards: Azure Naming and Tagging Standards v4.0.0.0_20241022.docx
  # Resource group name: rg-<app or service name>-<subscription purpose>-<###>
  # Examples: rg-mktgsharepoint-prod-001
  #           rg-acctlookupsvc-shared-001
  #           rg-ad-dir-services-shared-001
  #           rg-eft-network-prod-001
  #           rg-gseeft-prod-001
  #           rg-omb-redis-dev-001
  #           rg-daas-prod-001
  #-------------------------------------------------------------------------------------------
  vnet_resource_group_name = var.custom_vnet_resource_group_name != "" ? var.custom_vnet_resource_group_name : "rg-network-${var.app_name}-${var.environment}-${var.environment_number_suffix}"

  #vnet_resource_group_name = "rg-network-omb-dev-001"
  #-------------------------------------------------------------------------------------------
  # Process all the input variables and enhance/transform them them as necessary
  #-------------------------------------------------------------------------------------------

  location                  = var.region
  region                    = var.region
  environment               = var.environment
  environment_number_suffix = var.environment_number_suffix
  app_name                  = var.app_name
  diagnostic_settings       = var.diagnostic_settings
  lock                      = var.lock
  enable_telemetry          = var.enable_telemetry
  role_assignments          = var.role_assignments

  #-------------------------------------------------------------------------------------------
  #VyStar Naming Standards: Azure Naming and Tagging Standards v4.0.0.0_20241022.docx
  # Resource group name: rg-<app or service name>-<subscription purpose>-<###>
  # Examples: rg-mktgsharepoint-prod-001
  #           rg-acctlookupsvc-shared-001
  #           rg-ad-dir-services-shared-001
  #           rg-eft-network-prod-001
  #           rg-gseeft-prod-001
  #           rg-omb-redis-dev-001
  #           rg-daas-prod-001
  #-------------------------------------------------------------------------------------------
  resource_group_name = var.custom_resource_group_name != null ? var.custom_resource_group_name : "rg-${var.app_name}-${var.component_name}-${var.environment}-${var.environment_number_suffix}"


  private_endpoints = {
    for idx, endpoint_key in keys(var.private_endpoints) : endpoint_key => {
      # Generate the name dynamically with a two-digit count
      # Private Endpoint name: pe-<count>-<app_name>-<component_name>-<environment>-<environment_number>
      # Examples: pe-01-omb-acr-prod-001
      #           pe-02-omb-acr-prod-001
      # name = format("pe-%s-%02d-%s-%s-%s", var.app_name, idx + 1, var.component_name, var.environment, var.environment_number_suffix)
      name = format("pe-%s-%s-%s-%s", var.component_name, var.app_name, var.environment, var.environment_number_suffix)


      # Use private_endpoint_subnet_name_segments_to_subnet_id_map for subnet_resource_id
      subnet_resource_id = lookup(
        local.private_endpoint_subnet_name_segments_to_subnet_id_map,
        var.private_endpoints[endpoint_key].private_endpoint_subnet_name_segment,
        null
      )

      private_dns_zone_resource_ids = try(
        [
          data.azurerm_private_dns_zone.this[endpoint_key].id
        ],
        []
      )

      # Place the private endpoint in the same resource group as the resource group.
      resource_group_name                     = local.resource_group_name
      private_dns_zone_group_name             = "group-private-endpoints-${var.app_name}-${var.component_name}-${var.environment}-${var.environment_number_suffix}"
      lock                                    = var.private_endpoints[endpoint_key].lock
      role_assignments                        = var.private_endpoints[endpoint_key].role_assignments
      application_security_group_associations = var.private_endpoints[endpoint_key].application_security_group_associations
      private_service_connection_name         = var.private_endpoints[endpoint_key].private_service_connection_name
      network_interface_name                  = var.private_endpoints[endpoint_key].network_interface_name
      location                                = local.location
      ip_configurations                       = var.private_endpoints[endpoint_key].ip_configurations
      tags                                    = merge(var.private_endpoints[endpoint_key].tags, local.enhanced_tags)
      subresource_name                        = var.private_endpoints[endpoint_key].subresource_name
    }
  }

  #-------------------------------------------------------------------------------------------
  # VyStar Naming Standards: Azure Naming and Tagging Standards v4.0.0.0_20241022.docx
  # Refer to 'Azure Tagging Standards' for more information on required common tags.
  #-------------------------------------------------------------------------------------------

  # Generate the enhanced tags with underscores replaced by spaces for Azure compatibility
  processed_tags = {
    for key, value in var.common_tags : (
      key == "Business_Unit" ? "Business Unit" :
      key == "Workload" ? "Workload" :
      key == "Business_Criticality" ? "Business Criticality" :
      key == "Operations_Team" ? "Operations Team" :
      key == "Cost_Center" ? "Cost Center" :
      key # Fallback for other keys
    ) => value
  }

  # Read and decode the YAML file content   
  version_data = yamldecode(file("${path.module}/../../modules-version.yml"))

  # Access the version field from the decoded data   
  version = local.version_data["version"]

  #---------------------------------------------------------------------------------------------------------
  # Add "IaC Module Registry Version to Common Tags with the hard coded version number from the module
  # Combine processed tags and resource tags with version number and created date
  #---------------------------------------------------------------------------------------------------------
  enhanced_tags = merge(
    local.processed_tags,
    var.resource_tags,
    {
      "Created"                     = formatdate("YYYYMMDD", timestamp()) # Set Created tag to current date in YYYYMMDD format
      "IaC Module Registry Version" = local.version
    }
  )

  # Version number to be extracted 
  version_number = local.version
}


