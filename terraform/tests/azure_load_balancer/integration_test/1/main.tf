
#---------------------------------------------------------
# Create a Private Link Service
# STEP 1:
# Check if the Private Link Service Link exists
#---------------------------------------------------------

module "load_balancer" {
  source = "../../../../modules/azure_load_balancer"

  # Required Input Parameters

  app_name                  = "vystarsampleapp"
  region                    = "eastus"
  environment               = "dev"
  environment_number_suffix = "002"

  lb_frontend_ip_name    = "test_frontend_ip"
  lb_private_ip_address  = "10.190.6.5"
  lb_subnet_name_segment = "shared-private-endpoints-subnet"

  # frontend_ip_configurations = {
  #   frontend_configuration_1 = {
  #     name                                   = "test_frontend_ip"
  #     frontend_private_ip_address_version    = "IPv4"
  #     frontend_private_ip_address_allocation = "Static"
  #     private_ip_address                     = "10.190.6.5"
  #     frontend_private_ip_subnet_resource_id = values(data.azurerm_subnet.private_link_subnet)[0].id
  #     zones                                  = ["1"]
  #   }

  # }


  # backend_address_pool_addresses = {
  #   address1 = {
  #     name                             = "backend_vm_address"
  #     backend_address_pool_object_name = "pool1"
  #     ip_address                       = "10.190.6.5"
  #   }
  # }

  # backend_address_pool_configuration = "null"

  # backend_address_pool_network_interfaces = {
  #   interface1 = {
  #     backend_address_pool_object_name = "pool1"
  #     network_interface_resource_id    = data.azurerm_virtual_network.this.id
  #     ip_configuration_name            = "ipconfig1"
  #   }
  # }

  # backend_address_pools = {
  #   pool1 = {
  #     name                        = "test-pool"
  #     virtual_network_resource_id = data.azurerm_virtual_network.this.id
  #   }
  # }
  # diagnostic_settings = {}
  # edge_zone           = "null"
  # enable_telemetry    = false
  # #lock                            = var.lock
  # lb_nat_pools = {
  #   lb_nat_pool_1 = {
  #     #resource_group_name            = azurerm_resour
  #     #loadbalancer_id                = azurerm_lb.example.id
  #     name                           = "SampleApplicationPool"
  #     protocol                       = "Tcp"
  #     frontend_port_start            = 80
  #     frontend_port_end              = 81
  #     backend_port                   = 8080
  #     frontend_ip_configuration_name = "PublicIPAddress"
  #   }
  # }

  # lb_nat_rules = {
  #   lb_nat_rule_1 = {
  #     name                           = "tcp_nat_rule_1"
  #     frontend_ip_configuration_name = "test_frontend_ip"
  #     protocol                       = "Tcp"
  #     frontend_port                  = 3389
  #     backend_port                   = 3389
  #   }
  # }
  # lb_outbound_rules = {
  #   lb_outbound_rule_1 = {
  #     name = "outbound_rule_1"
  #     frontend_ip_configurations = [
  #       {
  #         name = "test_frontend_ip"
  #       }
  #     ]
  #   }
  # }

  # lb_probes = {
  #   probe1 = {
  #     name                = "probe_1"
  #     protocol            = "Tcp"
  #     port                = 80
  #     interval_in_seconds = 5
  #   },
  #   probe2 = {
  #     name                = "probe_2"
  #     protocol            = "Http"
  #     port                = 80
  #     request_path        = "/"
  #     interval_in_seconds = 5
  #   },
  #   probe3 = {
  #     name                = "probe_3"
  #     protocol            = "Https"
  #     port                = 443
  #     request_path        = "/"
  #     interval_in_seconds = 5
  #   }
  # }
  # lb_rules = {
  #   lb_rule_1 = {
  #     name                              = "myHTTPRule"
  #     frontend_ip_configuration_name    = "test_frontend_ip"
  #     backend_address_pool_object_names = ["pool1"]
  #     protocol                          = "Tcp" # default
  #     frontend_port                     = 80
  #     backend_port                      = 80
  #     probe_object_name                 = "tcp1"
  #     idle_timeout_in_minutes           = 15
  #     enable_tcp_reset                  = true
  #   }
  # }

  #public_ip_address_configuration = var.public_ip_address_configuration

  common_tags = {
    Business_Unit        = "Finance"
    Workload             = "Application"
    Business_Criticality = "Gold"
    Owner                = "Digital Team"
    Operations_Team      = "Cloud Engineering"
    Cost_Center          = "701"
  }


  resource_tags = {
    Project = "Integration Test"
  }

  providers = {
    azurerm                                        = azurerm
    azurerm.private_dns_zone_subscription_provider = azurerm.private_dns_zone_subscription_provider
  }




}




