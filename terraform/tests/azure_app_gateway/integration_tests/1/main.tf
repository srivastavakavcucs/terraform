module "azure_app_gateway" {

    source = "../../../../modules/azure_app_gateway"

  # Required Input Parameters

  app_name                  = "omb"
  region                    = "eastus"
  environment               = "dev"
  environment_number_suffix = "002"

  # Backend Address Pool
  backend_address_pools = {
    "apg-backend-pools" ={
       name = "apg-backend-pools-1"
       ip_addresses = ["10.190.6.4"] 
    }
  }
  # Backend HTTP Settings
   backend_http_settings = {
    "apg-backedn-http-settings" = {
      name                  = "apg-backedn-http-settings"
      port                  = 80
      protocol              = "Http"
      request_timeout       = 60
      affinity_cookie_name = "Disabled"  # If disabled, make sure this field is valid as per your logic
    }
  }
   # Frontend Ports
   frontend_ports = {
    "apg-frontend-port" = {
      name = "apg-frontend-port"
      port = 80
    }
  }
  # HTTP Listeners
  http_listeners = {
    "apg-http-listeners" = {
      name                           = "apg-http-listeners"
      frontend_port_name             = "apg-frontend-port"
      # frontend_ip_configuration_name = "apgtw-ip-config-omb-dev-eastus-002"
      protocol                       = "Http"
    }
  }
# Request Routing Rules
  request_routing_rules = {
    "apg-routing-rules" = {
      name                         = "apg-routing-rules"
      rule_type                    = "Basic"
      http_listener_name           = "apg-http-listeners"
      backend_address_pool_name    = "apg-backend-pools-1"
      backend_http_settings_name   = "apg-backedn-http-settings"
      priority                     = 10
    }
  }

 # Optional Input Parameters
  
  gateway_subnet_name_segment    = "app-gateway"
  
 # Autoscale Configuration
  autoscale_configuration = {
    min_capacity = 1
    max_capacity = 100
  }

  fips_enabled                       = false
  global                             = {
    request_buffering_enabled  = true
    response_buffering_enabled = true
  }

  http2_enable                       = true
  probe_configurations = {
    "apg-probe" = {
      name                   = "apg-probe"
      interval               = 240
      protocol               = "Http"
      timeout                = 60
      path                   = "/path1/"
      pick_host_name_from_backend_http_settings = true
      unhealthy_threshold    = 10
    }
  }
  # SKU Configuration
  sku = {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }
 
  # WAF Configuration
  waf_configuration  = {
    enabled          = true
    firewall_mode    = "Prevention"
    rule_set_version = "3.1"
    rule_set_type    = "OWASP"
  }

  # zones = ["zone1", "zone2", "zone3"]

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

  # Providers
  providers = {
    azurerm                                        = azurerm
    azurerm.private_dns_zone_subscription_provider = azurerm.private_dns_zone_subscription_provider
  }
}
