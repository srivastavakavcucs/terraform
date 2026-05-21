#---------------------------------------------------------------------------------------------------
# Data sources to dynamically retrieve:
# 1. VNet
# 2. Subnet IDs of the main and worker subnets dynamically from the VNet based on naming conventions
#---------------------------------------------------------------------------------------------------

# Retrieve the VNet details from the specified resource group and name
# data "azurerm_virtual_network" "this" {
#   name                = module.base.vnet_name
#   resource_group_name = module.base.vnet_resource_group_name
# }

# # Retrieve the main subnet details dynamically based on the naming convention
# data "azurerm_subnet" "private_link_subnet" {
#   for_each = {
#     for subnet_name in data.azurerm_virtual_network.this.subnets :
#     subnet_name => subnet_name if startswith(subnet_name, "snet-${var.private_link_subnet_name_segment}")
#   }

#   name                 = each.key
#   virtual_network_name = data.azurerm_virtual_network.this.name
#   resource_group_name  = data.azurerm_virtual_network.this.resource_group_name
# }

# data "azurerm_lb" "this" {
#   name                = var.existing_lb_name           # Replace with your Load Balancer name
#   resource_group_name = var.existing_lb_resource_group # Replace with your Resource Group name
# }

# data "azurerm_lb" "created_lb" {
#   name                = module.load_balancer.name
#   resource_group_name = "rg-vystar-sample-app-private-link-dev-002" #module.azurerm_private_link_service.this.resource_group_name
# }

# data "azurerm_lb_frontend_ip_configuration" "frontend_ips" {
#   name            = "test_lb_frontend" # Name defined in the module
#   loadbalancer_id = data.azurerm_lb.created_lb.id
# }

# output "frontend_ip_configuration_id" {
#   description = "Outputs the ID of the frontend IP configuration"
#   value       = azurerm_lb.lb.frontend_ip_configuration[0].id
# }

