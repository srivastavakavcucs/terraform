
#-----------------------------------------------------------
# Azure Resource Lock
#-----------------------------------------------------------

resource "azurerm_management_lock" "this" {
  count = module.base.lock != null ? 1 : 0

  lock_level = module.base.lock.kind
  name       = coalesce(module.base.lock.name, "lock-${azurerm_private_dns_zone_virtual_network_link.this.name}")
  scope      = azurerm_private_dns_zone_virtual_network_link.this.id
  notes      = module.base.lock.kind == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources."
}
