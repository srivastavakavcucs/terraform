#-----------------------------------------------------------------------------------------
# Output details about the Azure Function App that was provisioned.
#-----------------------------------------------------------------------------------------

output "name" {
  description = "The name of the Function App resource."
  value       = var.os_type == "Linux" ? azurerm_linux_function_app.this[0].name : azurerm_windows_function_app.this[0].name
}

output "resource_group_name" {
  description = "The name of the resource group where the Function App is deployed."
  value       = module.base.resource_group_name
}

output "resource_id" {
  description = "The resource ID of the Function App."
  value       = var.os_type == "Linux" ? azurerm_linux_function_app.this[0].id : azurerm_windows_function_app.this[0].id
}

output "default_hostname" {
  description = "The default hostname of the Function App."
  value       = var.os_type == "Linux" ? azurerm_linux_function_app.this[0].default_hostname : azurerm_windows_function_app.this[0].default_hostname
}

output "kind" {
  description = "The kind of Function App ('functionapp,linux' for Linux or 'functionapp' for Windows)."
  value       = var.os_type == "Linux" ? azurerm_linux_function_app.this[0].kind : azurerm_windows_function_app.this[0].kind
}

output "outbound_ip_addresses" {
  description = "A comma-separated list of outbound IP addresses."
  value       = var.os_type == "Linux" ? azurerm_linux_function_app.this[0].outbound_ip_addresses : azurerm_windows_function_app.this[0].outbound_ip_addresses
}

output "principal_id" {
  description = "The Principal ID of the System Assigned Managed Identity. Returns null if no system-assigned identity is configured."
  value = try(
    var.os_type == "Linux" ? azurerm_linux_function_app.this[0].identity[0].principal_id : azurerm_windows_function_app.this[0].identity[0].principal_id,
    null
  )
}
