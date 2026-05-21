# Azure Function Terraform Module

This Terraform module provisions an Azure Function resource. It is designed to support configurable runtimes and integrates with VyStar's standard naming conventions and tagging requirements.

---

## Table of Contents

- [Azure Function Terraform Module](#azure-function-terraform-module)
  - [Table of Contents](#table-of-contents)
  - [Module Overview](#module-overview)
  - [Requirements](#requirements)
  - [Providers](#providers)
  - [Module Inputs](#module-inputs)
  - [Additional Details on Complex Optional Inputs](#additional-details-on-complex-optional-inputs)
  - [Module Outputs](#module-outputs)
  - [Usage Examples](#usage-examples)
  - [Additional Documentation](#additional-documentation)

---

## Module Overview

The Azure Function Terraform Module provisions an Azure Function App in Azure. This module supports configurable runtimes and follows VyStar's Pipeline 2.0 standards for naming, tagging, and resource group management via the shared `iac_base` module. Unlike most IaC modules, it does not wrap an Azure Verified Module (AVM) — no AVM for Function Apps exists at this time (see [Azure Verified Modules registry](https://registry.terraform.io/search/modules?namespace=Azure&q=function)) — and provisions `azurerm_linux_function_app` or `azurerm_windows_function_app` directly.

---

## Requirements

- **Terraform**: `>= 1.9.2` — [Latest Releases](https://github.com/hashicorp/terraform/releases)
- **Providers**:
  - `azurerm`: `>= 4.69.0`

---

## Providers

| Provider | Source            | Version  |
| -------- | ----------------- | -------- |
| azurerm  | hashicorp/azurerm | `>= 4.69.0` |

> **Note:** This module requires `azurerm >= 4.69.0` and Terraform `>= 1.9.2`. See [AzureRM Provider Releases](https://github.com/hashicorp/terraform-provider-azurerm/releases) and [Terraform Releases](https://github.com/hashicorp/terraform/releases) for available versions.

---

## Module Inputs

### Required Variables

| Name                         | Type          | Description                                                                                              |
| ---------------------------- | ------------- | -------------------------------------------------------------------------------------------------------- |
| `region`                     | `string`      | Azure region where the resource should be deployed (`eastus` or `westus`).                               |
| `app_name`                   | `string`      | Name of the VyStar application that will be deployed.                                                    |
| `environment`                | `string`      | Target environment abbreviation for naming.                                                              |
| `environment_number_suffix`  | `string`      | Environment number suffix for naming.                                                                    |
| `common_tags`                | `map(string)` | Common tags for all VyStar Azure resources.                                                              |
| `os_type`                    | `string`      | The operating system type for the Function App. Valid values: `Linux` or `Windows`.                      |
| `service_plan_id`            | `string`      | The resource ID of the App Service Plan where this Function App will be deployed.                        |
| `storage_account_name`       | `string`      | The name of the Storage Account required by the Function App for internal operations (3-24 characters).  |
| `storage_account_access_key` | `string`      | The access key for the Storage Account. This is required for Function App operation. (sensitive)         |
| `runtime`                    | `string`      | The runtime stack. Valid values: `dotnet`, `dotnet-isolated`, `node`, `python`, `java`, `powershell`, `custom`. |
| `runtime_version`            | `string`      | The version of the runtime. Examples: `8.0` (dotnet), `20` (node), `3.11` (python), `11` (java), `7.4` (powershell). |

### Optional Variables

| Name | Type | Default | Description |
| ---- | ---- | ------- | ----------- |
| `managed_identities` | `object` | `{}` | Controls the Managed Identity configuration. Supports `system_assigned` (bool) and `user_assigned_resource_ids` (set of strings). |
| `app_settings` | `map(string)` | `{}` | A map of application settings for the Function App. `FUNCTIONS_WORKER_RUNTIME` is set automatically and should not be included. |
| `enable_telemetry` | `bool` | `true` | Enable telemetry for the module. |
| `lock` | `object` | `null` | Resource lock configuration. Requires `kind` (`CanNotDelete` or `ReadOnly`) and optional `name`. |
| `diagnostic_settings` | `map(object)` | `{}` | Diagnostic settings for the resource group managed by this module. |
| `role_assignments` | `map(object)` | `{}` | RBAC role assignments to create on the resource group managed by this module. |
| `private_endpoints` | `map(object)` | `{}` | Private endpoint configuration. Use `subresource_name = "sites"` for Function Apps. |
| `resource_tags` | `map(string)` | `{}` | Additional tags applied to the Function App resource. |
| `custom_resource_group_name` | `string` | `null` | Name of an existing resource group to use instead of creating a new one. |
| `custom_vnet_name` | `string` | `""` | Custom VNet name override. If empty, the default naming convention is used. |
| `custom_vnet_resource_group_name` | `string` | `""` | Custom VNet resource group name override. If empty, the default naming convention is used. |

---

## Additional Details on Complex Optional Inputs

### `managed_identities`

- **Description**: Controls the Managed Identity configuration on this resource.
- **Type**: `object`
  - **`system_assigned`** (bool, optional): Enables System Assigned Managed Identity. Default: `false`.
  - **`user_assigned_resource_ids`** (set of strings, optional): Resource IDs of User Assigned Managed Identities to assign. Default: `[]`.
- **Default**: `{}`

#### Example

```hcl
managed_identities = {
  system_assigned            = true
  user_assigned_resource_ids = [
    "/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/<identity-name>"
  ]
}
```

---

### `role_assignments`

- **Description**: A map of role assignments to create on the resource group managed by this module.
- **Type**: `map(object)`
  - **`role_definition_id_or_name`** (string, required): Role definition ID or built-in role name (e.g., `"Reader"`).
  - **`principal_id`** (string, required): Object ID of the user, group, or service principal.
  - **`description`** (string, optional): Description for the role assignment.
  - **`skip_service_principal_aad_check`** (bool, optional): Skip the Azure AD check for service principals. Default: `false`.
  - **`condition`** (string, optional): ABAC condition expression.
  - **`condition_version`** (string, optional): ABAC condition version (e.g., `"2.0"`).
  - **`delegated_managed_identity_resource_id`** (string, optional): Managed identity resource ID for cross-tenant scenarios.
  - **`principal_type`** (string, optional): `"User"`, `"Group"`, or `"ServicePrincipal"`.
- **Default**: `{}`

#### Example

```hcl
role_assignments = {
  "developer_reader" = {
    role_definition_id_or_name = "Reader"
    principal_id               = "<object-id>"
    description                = "Developer read access"
  }
}
```

---

### `diagnostic_settings`

- **Description**: A map of diagnostic settings to create on the resource group managed by this module.
- **Type**: `map(object)`
  - **`name`** (string, optional): Display name for the diagnostic setting.
  - **`log_categories`** (set of strings, optional): Specific log categories to enable. Default: `[]`.
  - **`log_groups`** (set of strings, optional): Log groups to enable. Default: `["allLogs"]`.
  - **`metric_categories`** (set of strings, optional): Metric categories to enable. Default: `["AllMetrics"]`.
  - **`log_analytics_destination_type`** (string, optional): `"Dedicated"` or `"AzureDiagnostics"`. Default: `"Dedicated"`.
  - **`workspace_resource_id`** (string, optional): Resource ID of a Log Analytics workspace.
  - **`storage_account_resource_id`** (string, optional): Resource ID of a Storage Account for log archival.
  - **`event_hub_authorization_rule_resource_id`** (string, optional): Resource ID of an Event Hub authorization rule.
  - **`event_hub_name`** (string, optional): Name of the Event Hub.
  - **`marketplace_partner_resource_id`** (string, optional): Resource ID of a Marketplace partner integration.
- **Default**: `{}`

#### Example

```hcl
diagnostic_settings = {
  "function_diagnostics" = {
    name                  = "diag-myapp-dev-001"
    log_groups            = ["allLogs"]
    metric_categories     = ["AllMetrics"]
    workspace_resource_id = "/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.OperationalInsights/workspaces/<workspace-name>"
  }
}
```

---

### `private_endpoints`

- **Description**: A map of private endpoints to create on the Function App. Because this module uses `iac_base` directly rather than an AVM wrapper, the `private_endpoints` schema follows `iac_base`'s name-based resolution pattern — subnet and DNS zone names are resolved internally rather than passed as resource IDs. Use `subresource_name = "sites"` for Function Apps.
- **Type**: `map(object)`
  - **`subresource_name`** (string, required): Sub-resource to connect. Use `"sites"` for Function Apps.
  - **`private_endpoint_subnet_name_segment`** (string, required): Subnet name segment used by `iac_base` to resolve the target subnet within the VNet.
  - **`private_dns_zones`** (list of objects, required): DNS zones for private endpoint registration.
    - **`name`** (string, required): Private DNS zone name (e.g., `"privatelink.azurewebsites.net"`).
    - **`resource_group_name`** (string, required): Resource group containing the DNS zone.
  - **`role_assignments`** (map of objects, optional): Role assignments on the private endpoint. Follows the same structure as `var.role_assignments`.
  - **`lock`** (object, optional): Lock for the private endpoint. `kind`: `"CanNotDelete"` or `"ReadOnly"`; `name`: optional.
  - **`tags`** (map of strings, optional): Tags for the private endpoint.
  - **`application_security_group_associations`** (map of strings, optional).
  - **`private_service_connection_name`** (string, optional).
  - **`network_interface_name`** (string, optional).
  - **`ip_configurations`** (map of objects, optional): Static IP configurations. Each entry requires `name` and `private_ip_address`.
- **Default**: `{}`

> **Provider alias requirement:** This module always passes `azurerm.private_dns_zone_subscription_provider` to `iac_base`. The root module must configure this provider alias and pass it to the module via a `providers` block. This supports environments where private DNS zones are managed in a hub subscription separate from the Function App deployment. See [Terraform provider aliases](https://developer.hashicorp.com/terraform/language/providers/configuration#alias-multiple-provider-configurations).

#### Example

```hcl
private_endpoints = {
  "function_pe" = {
    subresource_name                     = "sites"
    private_endpoint_subnet_name_segment = "privateendpoints"
    private_dns_zones = [
      {
        name                = "privatelink.azurewebsites.net"
        resource_group_name = "rg-network-shared-prod-001"
      }
    ]
  }
}
```

---

## Module Outputs

| Name                    | Description                                                  |
| ----------------------- | ------------------------------------------------------------ |
| `name`                  | The name of the Function App resource.                       |
| `resource_group_name`   | The name of the resource group where the Function App is deployed. |
| `resource_id`           | The resource ID of the Function App.                         |
| `default_hostname`      | The default hostname of the Function App.                    |
| `kind`                  | The kind of Function App ('functionapp,linux' for Linux or 'functionapp' for Windows). |
| `outbound_ip_addresses` | A comma-separated list of outbound IP addresses.             |
| `principal_id`          | The Principal ID of the System Assigned Managed Identity. Returns `null` if no system-assigned identity is configured. |

> **Note on `kind` output:** The asymmetry in values (`'functionapp,linux'` vs `'functionapp'`) is an Azure platform characteristic, not a module design choice. Windows Function Apps were released first and assigned the kind `'functionapp'`. When Linux support was added later, Azure appended `,linux` to distinguish them. Azure maintains this naming for backward compatibility. This value is returned directly from Azure's Resource Manager API.

---

## Usage Examples

### Basic Example - Linux Function App with Python

```hcl
module "azure_function" {
  source = "git::https://dev.azure.com/vcuvs/IaC/_git/IaC//terraform/modules/azure_function?ref=<version>"

  region                     = "eastus"
  app_name                   = "myapp"
  environment                = "dev"
  environment_number_suffix  = "001"
  
  os_type                    = "Linux"
  service_plan_id            = azurerm_service_plan.example.id
  storage_account_name       = "mystorageacct001"
  storage_account_access_key = azurerm_storage_account.example.primary_access_key
  runtime                    = "python"
  runtime_version            = "3.11"

  common_tags = {
    Business_Unit        = "Finance"
    Workload             = "Application"
    Business_Criticality = "Gold"
    Owner                = "VyStar Credit Union"
    Operations_Team      = "Cloud Engineering"
    Cost_Center          = "701"
  }
}
```

### Example - Windows Function App with .NET

```hcl
module "azure_function" {
  source = "git::https://dev.azure.com/vcuvs/IaC/_git/IaC//terraform/modules/azure_function?ref=<version>"

  region                     = "eastus"
  app_name                   = "myapp"
  environment                = "prod"
  environment_number_suffix  = "001"
  
  os_type                    = "Windows"
  service_plan_id            = azurerm_service_plan.example.id
  storage_account_name       = "mystorageacct001"
  storage_account_access_key = azurerm_storage_account.example.primary_access_key
  runtime                    = "dotnet-isolated"
  runtime_version            = "8.0"

  common_tags = {
    Business_Unit        = "Finance"
    Workload             = "Application"
    Business_Criticality = "Platinum"
    Owner                = "VyStar Credit Union"
    Operations_Team      = "Cloud Engineering"
    Cost_Center          = "701"
  }
}
```

---

## Additional Documentation

- [Azure Functions Documentation](https://learn.microsoft.com/en-us/azure/azure-functions/)
- [AzureRM Provider Releases](https://github.com/hashicorp/terraform-provider-azurerm/releases)
- [Terraform Releases](https://github.com/hashicorp/terraform/releases)
- [Terraform Modules Documentation](https://developer.hashicorp.com/terraform/language/modules/develop)
