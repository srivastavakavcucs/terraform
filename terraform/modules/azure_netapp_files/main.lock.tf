#-----------------------------------------------------------
# Resource Locks
#-----------------------------------------------------------

resource "azurerm_management_lock" "this" {
  count = module.base.lock != null ? 1 : 0

  lock_level = module.base.lock.kind
  name       = coalesce(module.base.lock.name, "lock-${module.netapp_account}")
  scope      = module.netapp_account.az_netapp_account_id
  notes      = module.base.lock.kind == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources."
}
