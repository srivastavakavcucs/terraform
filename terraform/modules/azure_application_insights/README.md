# Azure Application Insights Terraform Module

This Terraform module deploys an Azure Application Insights resource using the Azure Verified Module, `terraform-azurerm-avm-res-insights-component`. It provides comprehensive control over Application Insights configuration, supporting telemetry, data caps, IP masking, identity management, and more.

## Table of Contents

- [Azure Application Insights Terraform Module](#azure-application-insights-terraform-module)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Prerequisites](#prerequisites)
  - [Example Usage](#example-usage)
  - [Module Inputs](#module-inputs)
    - [Required Inputs](#required-inputs)
    - [Optional Inputs](#optional-inputs)
  - [Detailed Variable Configuration](#detailed-variable-configuration)
    - [Managed Identities](#managed-identities)
    - [Lock Configuration](#lock-configuration)
  - [Module Outputs](#module-outputs)
  - [Validation Rules](#validation-rules)
  - [Additional Information](#additional-information)
  - [Additional Documentation](#additional-documentation)

## Overview

Application Insights is an Azure service for monitoring live applications. This module enables streamlined deployment of Application Insights, allowing telemetry data to be sent to Azure Log Analytics for detailed insights.

## Prerequisites

- Azure Log Analytics workspace must be available for telemetry data ingestion.
- Terraform version 1.5.0 or higher.
- AzureRM Provider version 3.71.0 or higher.
- `random` provider version 3.5.0 or higher.

## Example Usage

Here's an example of how to use this module in your Terraform configuration:

```hcl
module "app_insights" {
  source                = "./my-app-insights-module"
  location              = "eastus"
  name                  = "my-app-insights"
  resource_group_name   = "my-resource-group"
  workspace_id          = "workspace-id"

  # Optional variables with default values
  application_type                     = "web"
  daily_data_cap_in_gb                 = 200
  disable_ip_masking                   = false
  enable_telemetry                     = true
  internet_ingestion_enabled           = true
  internet_query_enabled               = true
  local_authentication_disabled        = false
  retention_in_days                    = 90
  sampling_percentage                  = 100

  # Managed identity and resource lock configurations
  managed_identities = {
    system_assigned            = true
    user_assigned_resource_ids = []
  }

  lock = {
    kind = "CanNotDelete"
    name = "appInsightsLock"
  }

  tags = {
    environment = "dev"
    department  = "IT"
  }
}
```

## Module Inputs

### Required Inputs

| Name                  | Type   | Description                                                         |
| --------------------- | ------ | ------------------------------------------------------------------- |
| `location`            | string | Azure region for resource deployment. Must be `eastus` or `westus`. |
| `name`                | string | Name of the Application Insights resource.                          |
| `resource_group_name` | string | Resource group for deployment.                                      |
| `workspace_id`        | string | Log Analytics workspace ID for data ingestion.                      |

### Optional Inputs

| Name                                    | Type   | Description                                                                               | Default                     |
| --------------------------------------- | ------ | ----------------------------------------------------------------------------------------- | --------------------------- |
| `application_type`                      | string | Application type: `web`, `ios`, `java`, `phone`, `MobileCenter`, `other`, `store`.        | `web`                       |
| `daily_data_cap_in_gb`                  | number | Daily data cap in GB; 0 for unlimited.                                                    | `100`                       |
| `daily_data_cap_notifications_disabled` | bool   | Disables daily data cap notifications.                                                    | `false`                     |
| `disable_ip_masking`                    | bool   | Disables IP masking in telemetry data.                                                    | `false`                     |
| `enable_telemetry`                      | bool   | Enables or disables telemetry.                                                            | `true`                      |
| `internet_ingestion_enabled`            | bool   | Enables telemetry ingestion from the internet.                                            | `true`                      |
| `internet_query_enabled`                | bool   | Enables querying telemetry from the internet.                                             | `true`                      |
| `local_authentication_disabled`         | bool   | Disables local authentication for the resource.                                           | `false`                     |
| `lock`                                  | object | Configures resource locks with `kind` (`CanNotDelete` or `ReadOnly`) and optional `name`. | `{ kind = "CanNotDelete" }` |
| `managed_identities`                    | object | Manages identities with `system_assigned` and `user_assigned_resource_ids`.               | `{}`                        |
| `retention_in_days`                     | number | Retention period for telemetry in days; 0 for unlimited.                                  | `90`                        |
| `sampling_percentage`                   | number | Sampling percentage for telemetry; 100 means all data is sampled.                         | `100`                       |
| `tags`                                  | map    | Map of tags to apply to the resource.                                                     | `{}`                        |

## Detailed Variable Configuration

### Managed Identities

The `managed_identities` variable allows configuration of managed identities attached to the Application Insights resource, supporting:

- `system_assigned`: Boolean for enabling a system-assigned identity.
- `user_assigned_resource_ids`: Set of strings specifying user-assigned managed identity resource IDs.

### Lock Configuration

The `lock` variable configures resource locks to control resource deletion and modification:

- `kind`: Type of lock, either `CanNotDelete` or `ReadOnly`.
- `name`: Optional lock name; if omitted, a name is autogenerated.

## Module Outputs

| Name                  | Description                                           |
| --------------------- | ----------------------------------------------------- |
| `app_id`              | Application Insights App ID.                          |
| `connection_string`   | Connection string for accessing Application Insights. |
| `instrumentation_key` | Instrumentation key for telemetry.                    |
| `name`                | Name of the Application Insights resource.            |
| `resource`            | Full output for the Application Insights resource.    |
| `resource_id`         | Resource ID for the Application Insights instance.    |

## Validation Rules

Validation rules are specified in `variables.tf`:

- `location`, `name`, `resource_group_name`, and `workspace_id` are mandatory and must be non-empty.
- `application_type` must be one of `web`, `ios`, `java`, `phone`, `MobileCenter`, `other`, or `store`.
- `lock.kind` must be `CanNotDelete` or `ReadOnly`.

## Additional Information

- **Telemetry**: Enable or disable telemetry by setting `enable_telemetry` to `true` or `false`.
- **IP Masking**: Enable IP masking by setting `disable_ip_masking` to `true` for privacy compliance.
- **Retention and Sampling**: Control data retention with `retention_in_days` and data volume with `sampling_percentage`.

## Additional Documentation

For further reference, explore the following resources:

- **Azure Verified Modules**:

  - [Overview of Azure Verified Modules](https://azure.github.io/Azure-Verified-Modules/)
  - [Terraform Resource Modules](https://azure.github.io/Azure-Verified-Modules/indexes/terraform/tf-resource-modules/)

- **Azure Application Insights Verified Module**:
  - [Terraform Registry](https://registry.terraform.io/modules/Azure/avm-res-insights-component/azurerm/latest)
  - [GitHub Repository](https://github.com/Azure/terraform-azurerm-avm-res-insights-component)
- **Azure Application Insights Documentation**:
  - [Overview of Application Insights](https://learn.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview)
  - [AzureRM Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest)

```
