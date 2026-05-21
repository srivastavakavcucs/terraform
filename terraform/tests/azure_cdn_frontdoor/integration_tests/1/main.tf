#------------------------------------------------------------------------
# Purpose: VNet Integration test with 2 subnets.
#          Subnet 1: Subnet Delegation enabled.
#          Subnet 2: Only Service Endpoints enabled.
#          Connect the subnets to an existing route table.
#------------------------------------------------------------------------
#-----------------------------------------------------------------------
# STEP 1: Purpose: Create a route table for the VNet.
#------------------------------------------------------------------------

# module "route_table" {
#   source = "../../../../modules/azure_route_table"

#   # Required Input Parameters
#   app_name                  = "vystarsampleapp"
#   region                    = "eastus"
#   environment               = "dev"
#   environment_number_suffix = "002"

#   # Updated routes to enforce valid next_hop_in_ip_address
#   routes = [
#     {
#       destination_name       = "route-to-vnet"
#       address_prefix         = "10.1.0.0/16"
#       next_hop_type          = "VirtualNetworkGateway"
#       next_hop_in_ip_address = null # Must be null for VirtualNetworkGateway
#     },
#     {
#       destination_name       = "route-to-hub-vnet"
#       address_prefix         = "10.0.0.0/9"
#       next_hop_type          = "VirtualAppliance"
#       next_hop_in_ip_address = "10.216.0.68"
#     },
#     {
#       destination_name       = "route-to-azure-devops-vnet"
#       address_prefix         = "10.216.80.0/24"
#       next_hop_type          = "VirtualAppliance"
#       next_hop_in_ip_address = "10.216.0.68"
#     }
#   ]

#   common_tags = {
#     Business_Unit        = "Finance"
#     Workload             = "Application"
#     Business_Criticality = "Gold"
#     Owner                = "Digital Team"
#     Operations_Team      = "Cloud Engineering"
#     Cost_Center          = "701"
#   }

#   # lock = {
#   #   kind = "CanNotDelete"
#   # }

#   resource_tags = {
#     Project = "Integration Test"
#   }

#   # Providers
#   providers = {
#     azurerm                                        = azurerm
#     azurerm.private_dns_zone_subscription_provider = azurerm.private_dns_zone_subscription_provider
#   }
# }

#-----------------------------------------------------------------------
# STEP 2: Purpose: Create test with 1 subnets.
#                  Subnet 1:  Shared Private Endpoints Subnet
#------------------------------------------------------------------------

# module "vnet" {
#   source = "../../../../modules/azure_virtual_network"

#   # Required Input Parameters
#   app_name                  = "vystarsampleapp"
#   region                    = "eastus"
#   environment               = "dev"
#   environment_number_suffix = "002"

#   cidr = ["10.190.0.0/16"]

#   dns_servers = {
#     dns_servers = [
#       "10.216.232.4",
#       "10.50.232.11"
#     ]
#   }

#   subnets = {
#     aro-main-subnet = {
#       name_segment      = "aro-main"
#       address_prefix    = "10.192.1.0/24"
#       service_endpoints = ["Microsoft.ContainerRegistry", "Microsoft.Storage"]
#       route_table = {
#         name                = "rt-vystarsampleapp-dev-002"
#         resource_group_name = "rg-vystarsampleapp-routetable-dev-002"
#       }
#     },
#     aro-worker-subnet = {
#       name_segment      = "aro-worker"
#       address_prefix    = "10.192.2.0/24"
#       service_endpoints = ["Microsoft.Storage", "Microsoft.ContainerRegistry", "Microsoft.KeyVault"]
#       route_table = {
#         name                = module.route_table.name
#         resource_group_name = module.route_table.resource_group_name
#       }
#     },
#     shared-private-endpoints-subnet = {
#       name_segment      = "shared-private-endpoints-subnet"
#       address_prefix    = "10.192.6.0/24"
#       service_endpoints = ["Microsoft.Storage", "Microsoft.ContainerRegistry", "Microsoft.KeyVault"]
#       route_table = {
#         name                = module.route_table.name
#         resource_group_name = module.route_table.resource_group_name
#       }
#     }
#   }

#   common_tags = {
#     Business_Unit        = "Finance"
#     Workload             = "Application"
#     Business_Criticality = "Gold"
#     Owner                = "Digital Team"
#     Operations_Team      = "Cloud Engineering"
#     Cost_Center          = "701"
#   }

#   resource_tags = {
#     Project = "Integration Test"
#   }

#   # Providers
#   providers = {
#     azurerm                                        = azurerm
#     azurerm.private_dns_zone_subscription_provider = azurerm.private_dns_zone_subscription_provider
#   }

#   depends_on = [module.route_table]
# }

# ----------------------------------------------------------------
# STEP 3: Create Private Link Service in the Vnet
# ----------------------------------------------------------------

# module "private_link" {

#   source = "../../../../modules/azure_private_link_service"

#   # Required Variables
#   app_name                  = "omb" #"vystarsampleapp"
#   region                    = "eastus"
#   environment               = "dev"
#   environment_number_suffix = "002"

#   load_balancer_frontend_ip_configuration_ids = [data.azurerm_lb.this.frontend_ip_configuration[0].id]
#   visibility_subscription_ids                 = ["8897145f-1e24-42a2-9a1d-c1b7af13fd2c", "c1bc5dd7-ea97-469c-89fa-8f26624902fd"]
#   auto_approval_subscription_ids              = ["8897145f-1e24-42a2-9a1d-c1b7af13fd2c", "c1bc5dd7-ea97-469c-89fa-8f26624902fd"]
#   #nat_ip_configuration_name        = "primary"
#   nat_ip_address = "10.190.6.251"
#   #nat_ip_address_version           = "IPv4"
#   #nat_ip_primary                   = true
#   #existing_lb_resource_group       = "rg_test_lb" #"rg-managed-omb-aro-dev-002" #
#   #existing_lb_name                 = "test_lb" #"omb-aro-dev-002-66lpk-internal" #
#   private_link_subnet_name_segment = "shared-private-endpoints"
#   resource_name_for_private_link   = "cdn_frontdoor_private_link"


#   resource_tags = {
#     Project = "Integration Test"
#   }
#   common_tags = {
#     Business_Unit        = "Finance"
#     Workload             = "Application"
#     Business_Criticality = "Gold"
#     Owner                = "Digital Team"
#     Operations_Team      = "Cloud Engineering"
#     Cost_Center          = "701"
#   }

#   # Providers
#   providers = {
#     azurerm                                        = azurerm
#     azurerm.private_dns_zone_subscription_provider = azurerm.private_dns_zone_subscription_provider
#   }

#   #depends_on = [module.vnet]


# }

#------------------------------------------------------------------------
# STEP 3: Purpose: Create the cdn-frontdoor in the VNet.
#------------------------------------------------------------------------

module "cdn_frontdoor" {
  source = "../../../../modules/azure_cdn_frontdoor"

  # Required Input Parameters

  app_name                  = "omb" #"vystarsampleapp"
  region                    = "eastus"
  environment               = "dev"
  environment_number_suffix = "002"

  nat_ip_address                              = "10.190.6.251"
  load_balancer_frontend_ip_configuration_ids = [data.azurerm_lb.this.frontend_ip_configuration[0].id]
  private_link_subnet_name_segment            = "shared-private-endpoints"
  resource_name_for_private_link              = "cdn-frontdoor"


  diagnostic_settings = {}
  enable_telemetry    = false

  front_door_custom_domains = {
    contoso1_key = {
      name      = "contoso1"
      host_name = "pocombdev.vystarcu.org"
      tls = {
        certificate_type    = "ManagedCertificate" #"CustomerCertificate" #
        minimum_tls_version = "TLS12"
        #cdn_frontdoor_secret_key = "vystar-test-vystarcu-org-latest" # This requires when we use custom certificate
      }
    }
  }

  front_door_endpoints = {
    ep_key = {
      name    = "frontdoor-endpoint"
      enabled = true
    }
  }

  front_door_firewall_policies = {
    fd_waf_key = {
      name                              = "cdnfrontdoorWAF"
      resource_group_name               = "rg-omb-cdn-frontdoor-dev-002"
      sku_name                          = "Premium_AzureFrontDoor"
      enabled                           = true
      mode                              = "Prevention"
      redirect_url                      = "https://www.vystarcu.org"
      custom_block_response_status_code = 403
      custom_block_response_body        = "PGh0bWw+CjxoZWFkZXI+PHRpdGxlPkhlbGxvPC90aXRsZT48L2hlYWRlcj4KPGJvZHk+CkhlbGxvIHdvcmxkCjwvYm9keT4KPC9odG1sPg=="
      custom_rules = {
        cr1 = {
          name                           = "Rule1"
          enabled                        = true
          priority                       = 1
          rate_limit_duration_in_minutes = 1
          rate_limit_threshold           = 10
          type                           = "MatchRule"
          action                         = "Block"
          match_conditions = {
            m1 = {
              match_variable     = "RemoteAddr"
              operator           = "IPMatch"
              negation_condition = false
              match_values       = ["10.190.2.0/24"]
            }
          }
        }
      }
    }
  }

  front_door_origin_groups = {
    og_key = {
      name = "cdnfrontdoor-origin-group"
      health_probe = {
        hp1 = {
          interval_in_seconds = 30
          path                = "/"
          protocol            = "Https"
          request_type        = "HEAD"
        }
      }
      load_balancing = {
        lb1 = {
          additional_latency_in_milliseconds = 50
          sample_size                        = 4
          successful_samples_required        = 3
        }
      }
    }
  }

  front_door_origins = {
    origin_key = {
      name                           = "origin-cdnfrontdoor"
      origin_group_key               = "og_key"
      enabled                        = true
      certificate_name_check_enabled = true
      host_name                      = "10.190.6.9" #"console-openshift-console.apps.vystarcu.eastus.aroapp.io" #"10.190.6.9"
      http_port                      = 80
      https_port                     = 443
      priority                       = 1
      weight                         = 1000
      private_link = {
        pl = {
          request_message        = "Message from AFD"
          location               = "eastus"
          private_link_target_id = module.private_link.id
        }
      }
    }
  }

  front_door_routes = {
    route_key = {
      name                   = "cdnfrontdoor-route"
      endpoint_key           = "ep_key"
      origin_group_key       = "og_key"
      origin_keys            = ["origin_key"]
      https_redirect_enabled = false
      custom_domain_keys     = ["contoso1_key"]
      patterns_to_match      = ["/*"]
      supported_protocols    = ["Https", "Http"]
      forwarding_protocol    = "MatchRequest"
      rule_set_names         = ["cdnfrontdoorRuleSet"]
      cache = {
        cache1 = {
          query_string_caching_behavior = "IgnoreSpecifiedQueryStrings"
          query_strings                 = ["account", "settings"]
          compression_enabled           = true
          content_types_to_compress     = ["text/html", "text/javascript", "text/xml"]
        }
      }
    }
  }

  front_door_rule_sets = ["ombvystarcdnrule002"]
  front_door_rules = {
    rule_key = {
      name              = "cdnrule"
      order             = 1
      behavior_on_match = "Continue"
      rule_set_name     = "ombvystarcdnrule002"
      origin_group_key  = "og_key"
      actions = {

        url_rewrite_actions = [{
          source_pattern          = "/"
          destination             = "/index3.html"
          preserve_unmatched_path = false
        }]
        route_configuration_override_actions = [{
          set_origin_groupid            = true
          forwarding_protocol           = "HttpsOnly"
          query_string_caching_behavior = "IncludeSpecifiedQueryStrings"
          query_string_parameters       = ["foo", "clientIp={client_ip}"]
          compression_enabled           = true
          cache_behavior                = "OverrideIfOriginMissing"
          cache_duration                = "365.23:59:59"
        }]
        response_header_actions = [{
          header_action = "Append"
          header_name   = "headername"
          value         = "/abc"
        }]
        request_header_actions = [{
          header_action = "Append"
          header_name   = "headername"
          value         = "/abc"
        }]
      }

      conditions = {
        remote_address_conditions = [{
          operator         = "IPMatch"
          negate_condition = false
          match_values     = ["10.0.0.0/23"]
        }]

        query_string_conditions = [{
          negate_condition = false
          operator         = "BeginsWith"
          match_values     = ["Query1", "Query2"]
          transforms       = ["Uppercase"]
        }]

        request_header_conditions = [{
          header_name      = "headername"
          negate_condition = false
          operator         = "BeginsWith"
          match_values     = ["Header1", "Header2"]
          transforms       = ["Uppercase"]
        }]

        request_body_conditions = [{
          negate_condition = false
          operator         = "BeginsWith"
          match_values     = ["Body1", "Body2"]
          transforms       = ["Uppercase"]
        }]

        request_scheme_conditions = [{ #request protocol
          negate_condition = false
          operator         = "Equal"
          match_values     = ["HTTP"]
        }]

        url_path_conditions = [{
          negate_condition = false
          operator         = "BeginsWith"
          match_values     = ["UrlPath1", "UrlPath2"]
          transforms       = ["Uppercase"]
        }]

        url_file_extension_conditions = [{
          negate_condition = false
          operator         = "BeginsWith"
          match_values     = ["ext1", "ext2"]
          transforms       = ["Uppercase"]
        }]

        url_filename_conditions = [{
          negate_condition = false
          operator         = "BeginsWith"
          match_values     = ["filename1", "filename2"]
          transforms       = ["Uppercase"]
        }]

        http_version_conditions = [{
          negate_condition = false
          operator         = "Equal"
          match_values     = ["2.0"]
        }]

        cookies_conditions = [{
          cookie_name      = "cookie"
          negate_condition = false
          operator         = "BeginsWith"
          match_values     = ["cookie1", "cookie2"]
          transforms       = ["Uppercase"]
        }]
      }
    }
  }

  front_door_secrets = {}
  front_door_security_policies = {
    secpol_key = {
      name = "cdnfrontdoor-Security-Policy"
      firewall = {
        front_door_firewall_policy_key = "fd_waf_key"
        association = {
          endpoint_keys     = ["ep_key"]
          patterns_to_match = ["/*"]
          domain_keys       = ["contoso1_key"]
        }
      }
    }
  }
  #lock                     = {}
  managed_identities       = {}
  response_timeout_seconds = 120
  role_assignments         = {}
  sku                      = "Premium_AzureFrontDoor"

  resource_tags = {
    Project = "Integration Test"
  }

  common_tags = {
    Business_Unit        = "Finance"
    Workload             = "Application"
    Business_Criticality = "Gold"
    Owner                = "Digital Team"
    Operations_Team      = "Cloud Engineering"
    Cost_Center          = "701"
  }

  # Providers
  providers = {
    azurerm                                        = azurerm
    azurerm.private_dns_zone_subscription_provider = azurerm.private_dns_zone_subscription_provider
  }

  # depends_on = [module.private_link]
}
