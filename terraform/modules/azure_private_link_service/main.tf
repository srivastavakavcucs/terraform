
#---------------------------------------------------------
# Create a Azure Private Link Service
#---------------------------------------------------------

resource "azurerm_private_link_service" "this" {
  name                = "private-link-${var.resource_name_for_private_link}"
  resource_group_name = module.base.resource_group_name
  location            = module.base.location
  tags                = module.base.tags

  visibility_subscription_ids                 = var.visibility_subscription_ids
  load_balancer_frontend_ip_configuration_ids = var.load_balancer_frontend_ip_configuration_ids
  auto_approval_subscription_ids              = var.auto_approval_subscription_ids

  nat_ip_configuration {
    name                       = "pl-nat-ip-config-${var.nat_ip_address}"
    private_ip_address         = var.nat_ip_address
    private_ip_address_version = "IPv4"
    subnet_id                  = module.base.subnet_name_segments_to_subnet_id_map[var.private_link_subnet_name_segment]
    primary                    = true
  }
  # Exported attribute
  lifecycle {
    create_before_destroy = true
  }

  # Forcing dependencies and deployment order to allow the resource group to be deployed first.
  depends_on = [module.base]
}


