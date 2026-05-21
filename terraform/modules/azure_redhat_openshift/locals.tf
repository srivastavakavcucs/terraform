#---------------------------------------------------------------------------------------------
# Retrieve: All the required local variables to retrieve the subnet information dynamically.
# 1. Route tables associated with the main and worker subnets.
# 2. Determine if both subnets have the same route table.
#---------------------------------------------------------------------------------------------
locals {
  # Retrieve route table IDs for the main and worker subnets
  main_route_table_id = module.base.subnet_name_segments_to_subnet_info[var.main_subnet_name_segment].route_table_id

  worker_route_table_id = module.base.subnet_name_segments_to_subnet_info[var.worker_subnet_name_segment].route_table_id

  # Determine if the route table IDs are different and worker route table is valid
  create_worker_role_assignments = local.main_route_table_id != local.worker_route_table_id && local.worker_route_table_id != null
}
