#-----------------------------------------------------------
# Resource Lock
#-----------------------------------------------------------

resource "azurerm_management_lock" "this" {
  count = module.base.lock != null ? 1 : 0

  lock_level = module.base.lock.kind
  name       = coalesce(module.base.lock.name, "lock-${azurerm_api_management.this.name}")
  scope      = azurerm_api_management.this.id
  notes      = module.base.lock.kind == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources."
}
