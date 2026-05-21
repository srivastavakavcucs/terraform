
#---------------------------------------------------------
# Create a Private Link Service
# STEP 1:
# Check if the Private Link Service Link exists
#---------------------------------------------------------

module "load_balancer" {
  source  = "Azure/avm-res-network-loadbalancer/azurerm"
  version = "0.3.2"

  # Required Input Parameters
  name                = "lb-${module.base.app_name}${module.base.environment}${module.base.environment_number_suffix}"
  resource_group_name = module.base.resource_group_name
  location            = module.base.location
  sku                 = "Standard"

  frontend_ip_configurations = {
    frontend_configuration_1 = {
      name                                   = var.lb_frontend_ip_name #"test_frontend_ip"
      frontend_private_ip_address_version    = "IPv4"
      frontend_private_ip_address_allocation = "Static"
      private_ip_address                     = var.lb_private_ip_address #"10.190.6.5"
      frontend_private_ip_subnet_resource_id = module.base.subnet_name_segments_to_subnet_id_map[var.lb_subnet_name_segment]
      # zones                                  = ["1"]
    }

  }


  backend_address_pool_addresses = {
    address1 = {
      name                             = "backend_vm_address"
      backend_address_pool_object_name = "pool1"
      ip_address                       = "10.190.6.5"
    }
  }

  backend_address_pool_configuration = "null"

  backend_address_pool_network_interfaces = {
    interface1 = {
      backend_address_pool_object_name = "pool1"
      network_interface_resource_id    = data.azurerm_virtual_network.this.id
      ip_configuration_name            = "ipconfig1"
    }
  }

  backend_address_pools = {
    pool1 = {
      name                        = "test-pool"
      virtual_network_resource_id = data.azurerm_virtual_network.this.id
    }
  }

  # frontend_ip_configurations = var.frontend_ip_configurations
  # #frontend_subnet_resource_id             = values(data.azurerm_subnet.private_link_subnet)[0].id
  # backend_address_pool_addresses          = var.backend_address_pool_addresses
  # backend_address_pool_configuration      = var.backend_address_pool_configuration
  # backend_address_pool_network_interfaces = var.backend_address_pool_network_interfaces
  # backend_address_pools                   = var.backend_address_pools
  # diagnostic_settings             = var.diagnostic_settings
  # edge_zone                       = var.edge_zone
  # enable_telemetry                = var.enable_telemetry
  # lock                            = var.lock
  # lb_nat_pools                    = var.lb_nat_pools
  # lb_nat_rules                    = var.lb_nat_rules
  # lb_outbound_rules               = var.lb_outbound_rules
  # lb_probes                       = var.lb_probes
  # lb_rules                        = var.lb_rules
  # public_ip_address_configuration = var.public_ip_address_configuration


  # Forcing dependencies and deployment order to allow the resource group to be deployed first.
  depends_on = [module.base]
}




