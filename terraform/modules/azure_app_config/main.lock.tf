#-----------------------------------------------------------
# Resource Locks
#-----------------------------------------------------------

resource "azurerm_management_lock" "this" {
  count = module.base.lock != null ? 1 : 0

  lock_level = module.base.lock.kind
  name       = coalesce(module.base.lock.name, "lock-${azurerm_app_configuration.this.name}")
  scope      = azurerm_app_configuration.this.id
  notes      = module.base.lock.kind == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources."
}
