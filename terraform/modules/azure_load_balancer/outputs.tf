
#-----------------------------------------------------------------------------------------
# Output details about the Azure Log Analytics Workspace that was provisioned.
#-----------------------------------------------------------------------------------------

output "azurerm_lb" {
  description = "Outputs the entire Azure Load Balancer resource"
  value       = module.load_balancer.azurerm_lb
}

output "azurerm_lb_backend_address_pool" {
  description = "Outputs each backend address pool in its entirety"
  value       = module.load_balancer.azurerm_lb_backend_address_pool
}

output "name" {
  description = "Outputs the entire Azure Load Balancer resource"
  value       = module.load_balancer.name
}

output "resource" {
  description = "Outputs the entire Azure Load Balancer resource"
  value       = module.load_balancer.resource
}

output "resource_id" {
  description = "Outputs the entire Azure Load Balancer resource"
  value       = module.load_balancer.resource_id
}