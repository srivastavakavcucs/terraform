#-----------------------------------------------------------
# Create the Azure Virtual Network Resource
#-----------------------------------------------------------

module "azure_virtual_network" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.7.1"

  # Required Variables
  name                = module.base.vnet_name
  location            = module.base.location
  resource_group_name = module.base.resource_group_name
  address_space       = var.cidr
  dns_servers         = var.dns_servers
  tags                = module.base.tags

  # Optional inputs
  bgp_community           = var.bgp_community
  diagnostic_settings     = module.base.diagnostic_settings
  enable_telemetry        = module.base.enable_telemetry
  enable_vm_protection    = var.enable_vm_protection
  encryption              = var.encryption
  extended_location       = var.extended_location
  flow_timeout_in_minutes = var.flow_timeout_in_minutes
  lock                    = module.base.lock
  role_assignments        = module.base.role_assignments

  # DDOS Protection Plan
  ddos_protection_plan = local.ddos_protection_plan

  # Subnets
  subnets = local.subnets

  #VNET Peering
  peerings = var.peerings


  # Forcing dependencies and deployment order to allow the resource group to be deployed first.
  depends_on = [module.base]
}
