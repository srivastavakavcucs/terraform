# locals {
#   #-------------------------------------------------------------------------------------------
#   # Retrieve the subnets whose name segments were passed in through the variables.
#   #-------------------------------------------------------------------------------------------

#   # Step 1: Generate a map of subnet names and their subnet IDs
#   subnet_map = {
#     for subnet in data.azurerm_subnet.subnets : subnet.name => subnet.id
#   }

#   # Step 2: Generate a list of subnet names
#   subnet_names = [
#     for subnet in data.azurerm_subnet.subnets : subnet.name
#   ]

#   # Step 3: Generate a map of subnet_name_segment as key and subnet_name as value
#   #         where the name segment is a substring of the subnet name.
#   #         Example: Name Segment 'redis' for subnet name 'snet-redis-10.190.5.0_24'
#   subnet_name_segments_to_subnet_name_map = {
#     for name_segment in values(var.subnet_name_segments) :
#     name_segment => one(
#       [
#         for subnet_name in local.subnet_names :
#         subnet_name if can(regex(name_segment, subnet_name))
#       ]
#     )
#   }

#   # Step 4: Generate a map of name_segment as key and subnet ID as value
#   #         Example:
#   #         Key - Name Segment 'redis'
#   #         Value - Subnet ID '/subscriptions/469217d4-0c3a-4e4d-8f72-f57391ea321e/resourceGroups/rg-omb-vnet-dev-002/providers/Microsoft.Network/virtualNetworks/vnet-omb-dev-eastus-002/subnets/snet-redis-eastus-002-10.190.6.0_24'
#   #   subnet_name_segments_to_subnet_id_map = {
#   #     for name_segment, subnet_name in local.subnet_name_segments_to_subnet_name_map :
#   #     name_segment => lookup(local.subnet_map, subnet_name, null)
#   #   }
# }
