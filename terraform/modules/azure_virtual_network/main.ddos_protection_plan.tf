#-----------------------------------------------------------------------
# Discover or use an existing DDoS Protection Plan if enabled
#-----------------------------------------------------------------------

# Local values to safely handle attributes of var.ddos_protection_plan
locals {
  ddos_plan_enabled = var.ddos_protection_plan != null ? var.ddos_protection_plan.enable : false
  ddos_plan_name    = var.ddos_protection_plan != null ? var.ddos_protection_plan.name : ""
  ddos_plan_rg_name = var.ddos_protection_plan != null ? var.ddos_protection_plan.resource_group_name : ""
}

# Conditional data block to fetch an existing DDoS Protection Plan
data "azurerm_network_ddos_protection_plan" "this" {
  count               = local.ddos_plan_enabled ? 1 : 0
  name                = local.ddos_plan_name
  resource_group_name = local.ddos_plan_rg_name
}

# Local to prepare the output for the DDoS Protection Plan
locals {
  ddos_protection_plan = local.ddos_plan_enabled ? {
    id     = data.azurerm_network_ddos_protection_plan.this[0].id
    enable = true
  } : null
}

# Output the DDoS Protection Plan configuration
output "ddos_protection_plan_config" {
  description = "DDoS Protection Plan configuration to be used by the Azure Virtual Network."
  value       = local.ddos_protection_plan
}
