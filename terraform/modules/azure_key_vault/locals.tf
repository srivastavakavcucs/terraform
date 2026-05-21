#-------------------------------------------------------------------------------------
# Locals:
# 1. Check if the Key Vault name will be >= 24 characters.
#    If so, truncate the app name so that the key Vault name length = 24 characters.
# 2. Generate the key vault name.
#-------------------------------------------------------------------------------------

locals {
  truncated_app_name = substr(module.base.app_name, 0, 24 - length("kv-${module.base.environment}-${module.base.environment_number_suffix}") - 1)
  key_vault_name     = "kv-${local.truncated_app_name}-${module.base.environment}-${module.base.environment_number_suffix}"
}
