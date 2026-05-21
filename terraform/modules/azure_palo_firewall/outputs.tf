#-----------------------------------------------------------------------------------------
# Output details about the Palo Alto Firewall that was provisioned.
#-----------------------------------------------------------------------------------------

output "vm_name" {
  description = "Name of the Palo Alto Firewall VM."
  value       = azurerm_linux_virtual_machine.palo_alto_vm.name
}

output "vm_id" {
  description = "Resource ID of the Palo Alto Firewall VM."
  value       = azurerm_linux_virtual_machine.palo_alto_vm.id
}

output "resource_group_name" {
  description = "Resource Group of the Palo Alto Firewall."
  value       = module.base.resource_group_name
}

output "public_ip_address" {
  description = "Public IP address of the Palo Alto Firewall management interface."
  value       = azurerm_public_ip.palo_mgmt_pip.ip_address
}

output "public_ip_fqdn" {
  description = "Fully qualified domain name of the Palo Alto Firewall management interface."
  value       = azurerm_public_ip.palo_mgmt_pip.fqdn
}

output "management_private_ip" {
  description = "Private IP address of the management interface."
  value       = azurerm_network_interface.palo_mgmt_nic.private_ip_address
}

output "untrust_private_ip" {
  description = "Private IP address of the untrust interface."
  value       = azurerm_network_interface.palo_untrust_nic.private_ip_address
}

output "trust_private_ip" {
  description = "Private IP address of the trust interface."
  value       = azurerm_network_interface.palo_trust_nic.private_ip_address
}

output "network_interface_ids" {
  description = "List of network interface IDs attached to the VM."
  value = {
    management = azurerm_network_interface.palo_mgmt_nic.id
    untrust    = azurerm_network_interface.palo_untrust_nic.id
    trust      = azurerm_network_interface.palo_trust_nic.id
  }
}

output "availability_set_id" {
  description = "Resource ID of the availability set (if enabled)."
  value       = var.enable_availability_set ? azurerm_availability_set.palo_alto_avset[0].id : null
}

output "availability_zone" {
  description = "Availability zone of the VM (if enabled)."
  value       = var.enable_availability_zones ? var.availability_zone : null
}

output "vm_size" {
  description = "Size of the Palo Alto Firewall VM."
  value       = azurerm_linux_virtual_machine.palo_alto_vm.size
}

output "admin_username" {
  description = "Admin username for the Palo Alto Firewall VM."
  value       = azurerm_linux_virtual_machine.palo_alto_vm.admin_username
  sensitive   = true
}
