#-------------------------------------------------------------------------------------------
# Naming Standards: Azure Naming and Tagging Standards
# Function App: func-<app_name>-<environment>-<environment_number_suffix>
# Example: func-myapp-dev-001
#-------------------------------------------------------------------------------------------

locals {
  function_app_name = "func-${module.base.app_name}-${module.base.environment}-${module.base.environment_number_suffix}"

  # Determine identity type based on managed_identities configuration
  identity_type = var.managed_identities.system_assigned && length(var.managed_identities.user_assigned_resource_ids) > 0 ? "SystemAssigned, UserAssigned" : (
    var.managed_identities.system_assigned ? "SystemAssigned" : (
      length(var.managed_identities.user_assigned_resource_ids) > 0 ? "UserAssigned" : null
    )
  )
}

#-------------------------------------------------------------------------------------------
# Linux Function App
#-------------------------------------------------------------------------------------------

resource "azurerm_linux_function_app" "this" {
  count = var.os_type == "Linux" ? 1 : 0

  name                       = local.function_app_name
  location                   = module.base.location
  resource_group_name        = module.base.resource_group_name
  service_plan_id            = var.service_plan_id
  storage_account_name       = var.storage_account_name
  storage_account_access_key = var.storage_account_access_key

  site_config {
    application_stack {
      # Runtime-specific configuration
      dotnet_version              = var.runtime == "dotnet" || var.runtime == "dotnet-isolated" ? var.runtime_version : null
      use_dotnet_isolated_runtime = var.runtime == "dotnet-isolated" ? true : null
      node_version                = var.runtime == "node" ? var.runtime_version : null
      python_version              = var.runtime == "python" ? var.runtime_version : null
      java_version                = var.runtime == "java" ? var.runtime_version : null
      powershell_core_version     = var.runtime == "powershell" ? var.runtime_version : null
      use_custom_runtime          = var.runtime == "custom" ? true : null
    }
  }

  # Managed Identity Configuration
  dynamic "identity" {
    for_each = local.identity_type != null ? [1] : []
    content {
      type         = local.identity_type
      identity_ids = length(var.managed_identities.user_assigned_resource_ids) > 0 ? var.managed_identities.user_assigned_resource_ids : null
    }
  }

  # App Settings
  app_settings = merge(
    var.app_settings,
    {
      "FUNCTIONS_WORKER_RUNTIME" = var.runtime
    }
  )

  tags = module.base.tags

  # Ensure resource group is created first
  depends_on = [module.base]
}

#-------------------------------------------------------------------------------------------
# Windows Function App
#-------------------------------------------------------------------------------------------

resource "azurerm_windows_function_app" "this" {
  count = var.os_type == "Windows" ? 1 : 0

  name                       = local.function_app_name
  location                   = module.base.location
  resource_group_name        = module.base.resource_group_name
  service_plan_id            = var.service_plan_id
  storage_account_name       = var.storage_account_name
  storage_account_access_key = var.storage_account_access_key

  site_config {
    application_stack {
      # Runtime-specific configuration for Windows
      dotnet_version              = var.runtime == "dotnet" || var.runtime == "dotnet-isolated" ? var.runtime_version : null
      use_dotnet_isolated_runtime = var.runtime == "dotnet-isolated" ? true : null
      node_version                = var.runtime == "node" ? var.runtime_version : null
      java_version                = var.runtime == "java" ? var.runtime_version : null
      powershell_core_version     = var.runtime == "powershell" ? var.runtime_version : null
      use_custom_runtime          = var.runtime == "custom" ? true : null
    }
  }

  # Managed Identity Configuration
  dynamic "identity" {
    for_each = local.identity_type != null ? [1] : []
    content {
      type         = local.identity_type
      identity_ids = length(var.managed_identities.user_assigned_resource_ids) > 0 ? var.managed_identities.user_assigned_resource_ids : null
    }
  }

  # App Settings
  app_settings = merge(
    var.app_settings,
    {
      "FUNCTIONS_WORKER_RUNTIME" = var.runtime
    }
  )

  tags = module.base.tags

  # Ensure resource group is created first
  depends_on = [module.base]

  lifecycle {
    precondition {
      condition     = var.runtime != "python"
      error_message = "Python runtime is not supported on Windows Azure Functions. Set os_type to 'Linux' for Python."
    }
  }
}
