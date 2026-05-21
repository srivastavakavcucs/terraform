# Azure Log Analytics Workspace Terraform Module

This Terraform module provisions an Azure Log Analytics Workspace resource by utilizing the Azure verified module,'avm-res-operationalinsights-workspace/azurerm' with a range of customizable settings,including options for customer-managed keys, diagnostic settings, telemetry, private endpoints, and more. It provides a flexible solution to deploy and manage a Log Analytics Workspace within your Azure environment.

## Table of Contents

- [Azure Log Analytics Workspace Terraform Module](#azure-log-analytics-workspace-terraform-module)
  - [Table of Contents](#table-of-contents)
  - [Requirements](#requirements)
  - [Module Overview](#module-overview)
  - [Usage](#usage)
- [Inputs and Outputs](#inputs-and-outputs)
  - [Required Inputs](#required-inputs)
  - [Optional Inputs](#optional-inputs)
  - [Outputs](#outputs)
  - [Conclusion](#conclusion)
  - [References](#references)

---

## Requirements

- **Terraform 0.14 or later**
- **Azure Provider version 2.x or later**

## Module Overview

This module creates an Azure Log Analytics Workspace, along with optional configurations such as:

- Customer-managed keys
- Diagnostic settings
- Telemetry and workspace lock
- Private endpoint configuration
- Role assignments
- Tags and resource grouping

## Usage

You can use this module by calling it within your Terraform configuration. Below is an example of how to use this module:

```hcl
module "log_analytics_workspace" {
  source = "github.com/Azure/terraform-azurerm-avm-res-operationalinsights-workspace"

  # Required variables
  location             = "East US"
  name                 = "my-log-analytics"
  resource_group_name  = "my-resource-group"

  # Optional variables
  customer_managed_key = {
    key_vault_resource_id = "/subscriptions/00000/resourceGroups/my-rg/providers/Microsoft.KeyVault/vaults/my-key-vault"
    key_name              = "my-key"
    key_version           = "version-1"
    user_assigned_identity = {
      resource_id = "/subscriptions/00000/resourceGroups/my-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/my-identity"
    }
  }

  diagnostic_settings = {
    my_setting = {
      log_categories                 = ["AuditLogs"]
      metric_categories              = ["AllMetrics"]
      log_analytics_destination_type = "Dedicated"
      workspace_resource_id          = "/subscriptions/00000/resourceGroups/my-rg/providers/Microsoft.OperationalInsights/workspaces/my-workspace"
    }
  }

  enable_telemetry = false
}
```

# Inputs and Outputs

## Required Inputs

| Name                  | Type   | Description                                                                                                                                    |
| --------------------- | ------ | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| `location`            | string | Specifies the supported Azure location where the Log Analytics Workspace should exist. Changing this forces a new resource to be created.      |
| `name`                | string | Specifies the name of the Log Analytics Workspace. Changing this forces a new resource to be created.                                          |
| `resource_group_name` | string | Specifies the name of the Resource Group in which the Log Analytics Workspace should exist. Changing this forces a new resource to be created. |

## Optional Inputs

| Name                                                         | Type        | Description                                                                                                                                                       | Default     |
| ------------------------------------------------------------ | ----------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| `customer_managed_key`                                       | object      | A map describing customer-managed keys to associate with the resource. Includes `key_vault_resource_id`, `key_name`, `key_version`, and `user_assigned_identity`. | `null`      |
| `diagnostic_settings`                                        | map(object) | A map of diagnostic settings to create on the Key Vault. Includes `log_categories`, `metric_categories`, and others.                                              | `{}`        |
| `enable_telemetry`                                           | bool        | Controls whether telemetry is enabled for the module.                                                                                                             | `true`      |
| `lock`                                                       | object      | Controls the Resource Lock configuration for this resource. Properties include `kind` and `name`.                                                                 | `null`      |
| `log_analytics_workspace_allow_resource_only_permissions`    | bool        | Allows users to access data associated with resources they have permission to view, without permission to the workspace.                                          | `null`      |
| `log_analytics_workspace_cmk_for_query_forced`               | bool        | Indicates if customer-managed storage is mandatory for query management.                                                                                          | `null`      |
| `log_analytics_workspace_daily_quota_gb`                     | number      | Specifies the workspace's daily quota for ingestion in GB. Defaults to `-1` (unlimited).                                                                          | `null`      |
| `log_analytics_workspace_identity`                           | object      | Specifies identity properties for the workspace, including `identity_ids` and `type`.                                                                             | `null`      |
| `log_analytics_workspace_internet_ingestion_enabled`         | bool        | Enables ingestion over the public internet.                                                                                                                       | `true`      |
| `log_analytics_workspace_internet_query_enabled`             | bool        | Enables querying over the public internet.                                                                                                                        | `true`      |
| `log_analytics_workspace_local_authentication_disabled`      | bool        | Disables authentication using Azure AD for the workspace.                                                                                                         | `false`     |
| `log_analytics_workspace_reservation_capacity_in_gb_per_day` | number      | Specifies the reservation capacity in GB for the workspace.                                                                                                       | `null`      |
| `log_analytics_workspace_retention_in_days`                  | number      | Sets the data retention period in days for the workspace.                                                                                                         | `null`      |
| `log_analytics_workspace_sku`                                | string      | Specifies the SKU for the workspace.                                                                                                                              | `PerGB2018` |
| `log_analytics_workspace_timeouts`                           | object      | Timeout configuration for the workspace (`create`, `delete`, `read`, `update`).                                                                                   | `null`      |
| `monitor_private_link_scope`                                 | map(object) | Configures the monitor private link scope with properties `name` and `resource_id`.                                                                               | `{}`        |
| `monitor_private_link_scoped_resource`                       | map(object) | Specifies the scoped resources with `name` and `resource_id`.                                                                                                     | `{}`        |
| `monitor_private_link_scoped_service_name`                   | string      | Specifies the service name to connect to the monitor private link scope.                                                                                          | `null`      |
| `private_endpoints`                                          | map(object) | Configures private endpoints for the Key Vault with multiple properties, including `subnet_resource_id`, `tags`, and `ip_configurations`.                         | `{}`        |
| `private_endpoints_manage_dns_zone_group`                    | bool        | Controls whether private DNS zone groups are managed by this module.                                                                                              | `true`      |
| `role_assignments`                                           | map(object) | Specifies role assignments for resources with properties `role_definition_id_or_name`, `principal_id`, and `condition`.                                           | `{}`        |
| `tags`                                                       | map(string) | Tags to assign to the resource.                                                                                                                                   | `null`      |

## Outputs

| Name                | Description                                                                                                          |
| ------------------- | -------------------------------------------------------------------------------------------------------------------- |
| `private_endpoints` | A map of the private endpoints created.                                                                              |
| `resource`          | Full output for the Log Analytics resource, following AVM standards. Example: `module.log_analytics.resource.id`.    |
| `resource_id`       | Full output for the Log Analytics resource ID, following AVM standards. Example: `module.log_analytics.resource_id`. |

---

## Conclusion

This Terraform module provides a robust solution for deploying and managing an Azure Log Analytics Workspace with customizable settings for security, telemetry, and performance. By configuring both required and optional inputs, you can tailor the deployment to meet your organization's needs. The module's outputs give you complete access to the created resources, making it easy to track and manage the workspace after deployment.

Whether you need to integrate customer-managed keys, configure private endpoints, or manage diagnostic settings, this module provides flexibility to handle these tasks seamlessly. By leveraging the power of Terraform, you can automate the deployment and maintenance of your Log Analytics Workspace in Azure.

## References

**Azure Log Analytics Workspace Documentation**:

- [Azure Log Analytics Documentation](https://learn.microsoft.com/en-us/azure/governance/policy/overview)
- [Azure Key Vault Documentation](https://learn.microsoft.com/en-us/azure/key-vault/general/)
- [Azure Resource Manager Documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/overview)

**Azure Verified Modules**:

- [Overview of Azure Verified Modules](https://azure.github.io/Azure-Verified-Modules/)
- [Terraform Resource Modules](https://azure.github.io/Azure-Verified-Modules/indexes/terraform/tf-resource-modules/)

**Log Analytics Workspace Azure Verified Module**:

- [Terraform Registry](https://registry.terraform.io/modules/Azure/avm-res-operationalinsights-workspace/azurerm/latest)
- [GitHub Repository](https://github.com/Azure/terraform-azurerm-avm-res-operationalinsights-workspace)

---
