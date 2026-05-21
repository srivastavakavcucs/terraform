#-------------------------------------------------------------------------------------------
# Consume all the VyStar Common Variables into the module components modules.
#-------------------------------------------------------------------------------------------
module "azure_route_table" {
  source  = "Azure/avm-res-network-routetable/azurerm"
  version = "0.3.1"

  #-------------------------------------------------------------------------------------------
  # Naming Standards Document: Azure Naming and Tagging Standards v4.0.0.0_20241022
  # Redis : rt-<subscription purpose>-<region>-<###>
  # Example: rt-omb-dev-001
  #-------------------------------------------------------------------------------------------

  # Required Variables
  name                = "rt-${module.base.app_name}-${module.base.environment}-${module.base.environment_number_suffix}"
  location            = module.base.location
  resource_group_name = module.base.resource_group_name
  tags                = module.base.tags

  # Optional inputs
  bgp_route_propagation_enabled = var.bgp_route_propagation_enabled
  enable_telemetry              = module.base.enable_telemetry
  lock                          = module.base.lock
  role_assignments              = module.base.role_assignments

  # Transform the list of subnet IDs into the required map of strings
  subnet_resource_ids = module.base.subnet_name_segments_to_subnet_id_map
  routes              = local.routes

  depends_on = [module.base]
}
