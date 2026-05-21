# Azure Container Registry Terraform Module

This Terraform module creates an Azure Container Registry (ACR) using the Azure Verified Module (AVM) for Container Registry. This module wraps the [Azure Verified Module](https://github.com/Azure/terraform-azurerm-avm-res-containerregistry-registry) to expose all its functionality with additional validations and requirements for easier configuration and integration.

## Table of Contents

- [Azure Container Registry Terraform Module](#azure-container-registry-terraform-module)
  - [Table of Contents](#table-of-contents)
  - [Requirements](#requirements)
  - [Usage](#usage)
  - [Module Features](#module-features)
  - [Inputs](#inputs)
    - [Required Inputs](#required-inputs)
    - [Optional Inputs](#optional-inputs)
  - [Additional Details on Complex Optional Inputs](#additional-details-on-complex-optional-inputs)
    - [`customer_managed_key`](#customer_managed_key)
      - [Example](#example)
    - [`diagnostic_settings`](#diagnostic_settings)
      - [Example](#example-1)
    - [`georeplications`](#georeplications)
      - [Example](#example-2)
    - [`managed_identities`](#managed_identities)
      - [Example](#example-3)
    - [`network_rule_set`](#network_rule_set)
      - [Example](#example-4)
    - [`private_endpoints`](#private_endpoints)
      - [Example](#example-5)
    - [`role_assignments`](#role_assignments)
      - [Example](#example-6)
  - [Outputs](#outputs)
  - [Example Configurations](#example-configurations)
    - [Basic Setup](#basic-setup)
    - [Advanced Configuration with Replication and Custom Managed Key](#advanced-configuration-with-replication-and-custom-managed-key)
  - [Important Notes](#important-notes)
  - [References](#references)

## Requirements

- **Terraform**: `>= 1.3.0`
- **Provider**:
  - `azurerm`: `>= 4.0, < 5.0.0`
  - `random`: `>= 3.5.0, < 5.0.0`
  - `modtm`: `~> 0.3`

## Usage

### Using Existing Resource Group and VNet

You can use the optional variables `custom_resource_group_name`, `custom_vnet_name`, and `custom_vnet_resource_group_name` to specify existing resources. If these variables are set in your `.tfvars` file, the module will use the specified resource group and/or VNet. If not set, the module will create new resources using the standard naming convention.

#### Example `.tfvars` entry:

```hcl
custom_resource_group_name      = "rg-testing-omb-dev-001"
custom_vnet_name                = "vnet-hub01-shared01-eu-vy"
custom_vnet_resource_group_name = "rg-network01-shared01-eu-vy"
```

```hcl
module "acr_wrapper" {
  source = "git::https://dev.azure.com/vcuvs/IaC/_git/IaC//terraform/modules/azure_container_registry?ref=0.0.12"

  location            = "eastus"
  name                = "myACRRegistry"
  resource_group_name = "myResourceGroup"

  # Optional configurations
  sku                          = "Premium"
  admin_enabled                = true
  anonymous_pull_enabled       = false
  retention_policy_in_days     = 14
  georeplications = [
    {
      location                  = "westus"
      regional_endpoint_enabled = true
      zone_redundancy_enabled   = true
      tags                      = { environment = "production" }
    }
  ]
}
```

## Module Features

This module allows you to configure an Azure Container Registry with fine-grained settings for access control, replication, network rules, private endpoints, and diagnostic settings. It integrates directly with Azure's AVM ACR resource for seamless integration and reliability.

## Inputs

### Required Inputs

| Name                  | Description                                           | Type   | Example Values         |
| --------------------- | ----------------------------------------------------- | ------ | ---------------------- |
| `location`            | Azure region where the ACR will be deployed.          | string | `"eastus"`, `"westus"` |
| `name`                | Name of the Container Registry.                       | string | `"myRegistry"`         |
| `resource_group_name` | Name of the resource group where ACR will be created. | string | `"myResourceGroup"`    |

### Optional Inputs

| Name                                      | Description                                                                                                   | Type                                                                                                                           | Default     |
| ----------------------------------------- | ------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------ | ----------- |
| `sku`                                     | The SKU name of the Container Registry. Options are `"Basic"`, `"Standard"`, and `"Premium"`.                 | string                                                                                                                         | `"Premium"` |
| `admin_enabled`                           | Specifies whether the admin user is enabled.                                                                  | bool                                                                                                                           | `false`     |
| `anonymous_pull_enabled`                  | Enables anonymous pull access. Only applicable to `Standard` or `Premium` SKUs.                               | bool                                                                                                                           | `false`     |
| `customer_managed_key`                    | Configuration for customer-managed encryption keys.                                                           | object (key_vault_resource_id, key_name, key_version, user_assigned_identity)                                                  | `null`      |
| `data_endpoint_enabled`                   | Enables dedicated data endpoints. Only applicable to `Premium` SKU.                                           | bool                                                                                                                           | `false`     |
| `diagnostic_settings`                     | Diagnostic settings for logging and monitoring.                                                               | map(object) (name, log_categories, log_groups, metric_categories, log_analytics_destination_type, workspace_resource_id, etc.) | `{}`        |
| `enable_telemetry`                        | Controls whether telemetry is enabled for the module.                                                         | bool                                                                                                                           | `true`      |
| `enable_trust_policy`                     | Specifies if the trust policy is enabled.                                                                     | bool                                                                                                                           | `false`     |
| `export_policy_enabled`                   | Specifies if the export policy is enabled. Set to `false` if `public_network_access_enabled` is also `false`. | bool                                                                                                                           | `true`      |
| `georeplications`                         | List of geo-replication configurations for the ACR.                                                           | list(object) (location, regional_endpoint_enabled, zone_redundancy_enabled, tags)                                              | `[]`        |
| `lock`                                    | Controls the Resource Lock configuration for the ACR resource. `kind` accepts `CanNotDelete` or `ReadOnly`.   | object (kind, name)                                                                                                            | `null`      |
| `managed_identities`                      | Configuration for managed identities.                                                                         | object (system_assigned, user_assigned_resource_ids)                                                                           | `{}`        |
| `network_rule_bypass_option`              | Allows trusted Azure services access. Values can be `"None"` or `"AzureServices"`.                            | string                                                                                                                         | `"None"`    |
| `network_rule_set`                        | Network rules for the ACR. Only applicable to `Premium` SKU.                                                  | object (default_action, ip_rule)                                                                                               | `null`      |
| `private_endpoints`                       | Map of private endpoints for the ACR.                                                                         | map(object) (name, role_assignments, lock, tags, subnet_resource_id, private_dns_zone_group_name, etc.)                        | `{}`        |
| `private_endpoints_manage_dns_zone_group` | Manages private DNS zone groups.                                                                              | bool                                                                                                                           | `true`      |
| `public_network_access_enabled`           | Specifies if public access is allowed.                                                                        | bool                                                                                                                           | `false`     |
| `quarantine_policy_enabled`               | Enables the quarantine policy.                                                                                | bool                                                                                                                           | `false`     |
| `retention_policy_in_days`                | Sets retention policy for untagged manifests.                                                                 | number                                                                                                                         | `7`         |
| `role_assignments`                        | Role assignments to create on the ACR.                                                                        | map(object) (role_definition_id_or_name, principal_id, description, skip_service_principal_aad_check, condition, etc.)         | `{}`        |
| `tags`                                    | Tags for the resource.                                                                                        | map(string)                                                                                                                    | `null`      |
| `zone_redundancy_enabled`                 | Enables zone redundancy. Modifying forces a new resource creation.                                            | bool                                                                                                                           | `true`      |

## Additional Details on Complex Optional Inputs

### `customer_managed_key`

- **Description**: Configuration for customer-managed encryption keys.
- **Type**: `object`
  - **`key_vault_resource_id`** (string, required): Resource ID of the Key Vault that contains the encryption key.
  - **`key_name`** (string, required): Name of the encryption key in the Key Vault.
  - **`key_version`** (string, optional): Version of the encryption key.
  - **`user_assigned_identity`** (object, optional): Specifies the user-assigned managed identity with access to the Key Vault.
    - **`resource_id`** (string, required): Resource ID of the user-assigned managed identity.
- **Default**: `null`

#### Example

```hcl
customer_managed_key = {
  key_vault_resource_id = "/subscriptions/your-subscription-id/resourceGroups/your-resource-group/providers/Microsoft.KeyVault/vaults/your-key-vault"
  key_name              = "your-key-name"
  key_version           = "your-key-version"
  user_assigned_identity = {
    resource_id = "/subscriptions/your-subscription-id/resourceGroups/your-resource-group/providers/Microsoft.ManagedIdentity/userAssignedIdentities/your-identity"
  }
}
```

### `diagnostic_settings`

- **Description**: Diagnostic settings for logging and monitoring.
- **Type**: `map(object)`
  - **`name`** (string, optional): Name of the diagnostic setting.
  - **`log_categories`** (set of strings, optional): Log categories to send to Log Analytics. Defaults to `[]`.
  - **`log_groups`** (set of strings, optional): Log groups to send to Log Analytics. Defaults to `["allLogs"]`.
  - **`metric_categories`** (set of strings, optional): Metric categories to send to Log Analytics. Defaults to `["AllMetrics"]`.
  - **`log_analytics_destination_type`** (string, optional): Destination type for diagnostic settings. Options are `"Dedicated"` and `"AzureDiagnostics"`. Defaults to `"Dedicated"`.
  - **`workspace_resource_id`** (string, optional): Resource ID of the Log Analytics workspace.
  - **`storage_account_resource_id`** (string, optional): Resource ID of the storage account for logs.
  - **`event_hub_authorization_rule_resource_id`** (string, optional): Resource ID of the event hub authorization rule.
  - **`event_hub_name`** (string, optional): Name of the event hub.
  - **`marketplace_partner_resource_id`** (string, optional): Resource ID of the Marketplace resource for sending Diagnostic Logs.
- **Default**: `{}`

#### Example

```hcl
diagnostic_settings = {
  "acr_diagnostics" = {
    name                       = "ACR Diagnostic Settings"
    log_categories             = ["ContainerRegistryLoginEvents", "ContainerRegistryRepositoryEvents"]
    log_groups                 = ["allLogs"]
    metric_categories          = ["AllMetrics"]
    log_analytics_destination_type = "Dedicated"
    workspace_resource_id      = "/subscriptions/your-subscription-id/resourceGroups/your-resource-group/providers/Microsoft.OperationalInsights/workspaces/your-log-analytics-workspace"
    storage_account_resource_id = "/subscriptions/your-subscription-id/resourceGroups/your-resource-group/providers/Microsoft.Storage/storageAccounts/your-storage-account"
    event_hub_authorization_rule_resource_id = "/subscriptions/your-subscription-id/resourceGroups/your-resource-group/providers/Microsoft.EventHub/namespaces/your-eventhub-namespace/authorizationRules/RootManageSharedAccessKey"
    event_hub_name             = "your-event-hub-name"
  }
}
```

### `georeplications`

- **Description**: A list of geo-replication configurations for the Azure Container Registry (ACR). This setting allows the ACR to replicate across multiple Azure regions, providing high availability and faster access in different geographic locations. Each configuration in the list specifies details for a particular geo-replication location.

- **Type**: `list(object)`

  - **`location`** (string, required): The geographic location where the Container Registry should be replicated (e.g., `"eastus"`, `"westus"`, etc.).
  - **`regional_endpoint_enabled`** (bool, optional): Enables or disables the regional endpoint for the geo-replicated location. Defaults to `true`. When enabled, a dedicated regional endpoint is provided for faster access in that region.
  - **`zone_redundancy_enabled`** (bool, optional): Enables or disables zone redundancy in the specified geo-replication location. Defaults to `true`. Zone redundancy improves resilience by replicating data across availability zones within the region.
  - **`tags`** (map of strings, optional): A map of additional tags to assign to the geo-replication configuration. This can be used to add metadata or organizational information to each replication instance. Defaults to `null`.

- **Default**: `[]`

#### Example

```hcl
georeplications = [
  {
    location                  = "eastus"
    regional_endpoint_enabled = true
    zone_redundancy_enabled   = true
    tags                      = { environment = "production", department = "engineering" }
  },
  {
    location                  = "westus"
    regional_endpoint_enabled = true
    zone_redundancy_enabled   = false
    tags                      = { environment = "production", department = "engineering" }
  }
]
```

### `managed_identities`

- **Description**: Configuration for managed identities.
- **Type**: `object`
  - **`system_assigned`** (bool, optional): Enables System Assigned Managed Identity.
  - **`user_assigned_resource_ids`** (set of strings, optional): List of User Assigned Managed Identity resource IDs to assign.
- **Default**: `{}`

#### Example

```hcl
managed_identities = {
  system_assigned            = true
  user_assigned_resource_ids = [
    "/subscriptions/your-subscription-id/resourceGroups/your-resource-group/providers/Microsoft.ManagedIdentity/userAssignedIdentities/identity1",
    "/subscriptions/your-subscription-id/resourceGroups/your-resource-group/providers/Microsoft.ManagedIdentity/userAssignedIdentities/identity2"
  ]
}
```

### `network_rule_set`

- **Description**: Network rules for the ACR. Only applicable to `Premium` SKU.
- **Type**: `object`
  - **`default_action`** (string, optional): Default action when no rule matches. Possible values are `"Allow"` and `"Deny"`. Defaults to `"Deny"`.
  - **`ip_rule`** (list of objects, optional): List of IP rules in CIDR format with `Allow` as the only permitted action.
    - **`action`** (string, optional): Defaults to `"Allow"`.
    - **`ip_range`** (string, required): CIDR block for matching requests.
- **Default**: `null`

#### Example

```hcl
network_rule_set = {
  default_action = "Deny"
  ip_rule = [
    {
      action   = "Allow"
      ip_range = "192.168.1.0/24"
    },
    {
      action   = "Allow"
      ip_range = "10.0.0.0/16"
    }
  ]
}
```

### `private_endpoints`

- **Description**: Map of private endpoints for the ACR.
- **Type**: `map(object)`
  - **`name`** (string, optional): Name of the private endpoint. One will be generated if not set.
  - **`role_assignments`** (map of objects, optional): Role assignments to create on the private endpoint.
    - **`role_definition_id_or_name`** (string, required): Role definition ID or name.
    - **`principal_id`** (string, required): ID of the principal for the role.
    - **`description`** (string, optional): Description of the role assignment.
    - **`skip_service_principal_aad_check`** (bool, optional): Skips the Azure AD check for the service principal.
    - **`condition`** (string, optional): Condition for role assignment.
    - **`condition_version`** (string, optional): Version of condition syntax (e.g., `"2.0"`).
    - **`delegated_managed_identity_resource_id`** (string, optional): Managed Identity Resource ID for cross-tenant scenarios.
    - **`principal_type`** (string, optional): Type of principal (`User`, `Group`, `ServicePrincipal`).
  - **`lock`** (object, optional): Lock configuration for the private endpoint.
    - **`kind`** (string, required): Type of lock (`"CanNotDelete"` or `"ReadOnly"`).
    - **`name`** (string, optional): Lock name.
  - **`tags`** (map of strings, optional): Tags for the private endpoint.
  - **`subnet_resource_id`** (string, required): Resource ID of the subnet for the private endpoint.
  - **`private_dns_zone_group_name`** (string, optional): Name of the private DNS zone group.
  - **`private_dns_zone_resource_ids`** (set of strings, optional): Resource IDs of private DNS zones for the private endpoint.
  - **`application_security_group_associations`** (map of strings, optional): Application security groups for the private endpoint.
  - **`private_service_connection_name`** (string, optional): Name of the private service connection.
  - **`network_interface_name`** (string, optional): Network interface name.
  - **`location`** (string, optional): Azure location. Defaults to resource group’s location.
  - **`resource_group_name`** (string, optional): Resource group for the private endpoint. Defaults to the ACR’s resource group.
  - **`ip_configurations`** (map of objects, optional): IP configurations for the private endpoint.
    - **`name`** (string, required): Name of the IP configuration.
    - **`private_ip_address`** (string, required): Private IP address for the IP configuration.
- **Default**: `{}`

#### Example

```hcl
private_endpoints = {
  acr_private_endpoint = {
    name                          = "myACRPrivateEndpoint"
    subnet_resource_id            = "/subscriptions/your-subscription-id/resourceGroups/your-network-resource-group/providers/Microsoft.Network/virtualNetworks/your-vnet/subnets/your-subnet"
    private_dns_zone_group_name   = "acrPrivateDNSZoneGroup"
    private_dns_zone_resource_ids = [
      "/subscriptions/your-subscription-id/resourceGroups/your-dns-resource-group/providers/Microsoft.Network/privateDnsZones/privatelink.azurecr.io"
    ]
    role_assignments = {
      admin_role = {
        role_definition_id_or_name = "Contributor"
        principal_id               = "your-principal-id"
        description                = "Role assignment for ACR private endpoint"
      }
    }
    lock = {
      kind = "CanNotDelete"
    }
    tags = { environment = "production", department = "engineering" }
  }
}
```

### `role_assignments`

- **Description**: Role assignments to create on the ACR.
- **Type**: `map(object)`
  - **`role_definition_id_or_name`** (string, required): Role definition ID or name.
  - **`principal_id`** (string, required): ID of the principal for the role.
  - **`description`** (string, optional): Description of the role assignment.
  - **`skip_service_principal_aad_check`** (bool, optional): Skips the Azure AD check for the service principal.
  - **`condition`** (string, optional): Condition for role assignment.
  - **`condition_version`** (string, optional): Version of condition syntax.
  - **`delegated_managed_identity_resource_id`** (string, optional): Managed Identity Resource ID for cross-tenant scenarios.
  - **`principal_type`** (string, optional): Type of principal (`User`, `Group`, `ServicePrincipal`).
- **Default**: `{}`

#### Example

```hcl
role_assignments = {
  acr_admin = {
    role_definition_id_or_name = "AcrPush"
    principal_id               = "your-principal-id"
    description                = "ACR push access for automation"
    skip_service_principal_aad_check = true
  }
}
```

## Outputs

| Name                              | Description                                                                          |
| --------------------------------- | ------------------------------------------------------------------------------------ |
| `name`                            | The name of the Azure Container Registry.                                            |
| `private_endpoints`               | A map of private endpoints. Each entry provides details on its associated resources. |
| `resource`                        | Full output of the Azure Verified Module resource.                                   |
| `resource_id`                     | The resource ID for the Container Registry.                                          |
| `system_assigned_mi_principal_id` | System-assigned managed identity principal ID for the ACR.                           |

| `custom_resource_group_name`| (Optional) Name of an existing resource group to use. If provided, no new resource group will be created. | `string` | `null` | No |
| `custom_vnet_name`| (Optional) Custom VNet name. If not set, the default naming convention will be used. | `string` | "" | No |
| `custom_vnet_resource_group_name`| (Optional) Custom VNet resource group name. If not set, the default naming convention will be used. | `string` | "" | No |
## Example Configurations

### Basic Setup

```hcl
module "acr" {
  source = "git::https://dev.azure.com/vcuvs/IaC/_git/IaC//terraform/modules/azure_container_registry?ref=0.0.12"

  location            = "eastus"
  name                = "myBasicACRRegistry"
  resource_group_name = "exampleResourceGroup"
}
```

### Advanced Configuration with Replication and Custom Managed Key

```hcl
module "acr" {
  source = "git::https://dev.azure.com/vcuvs/IaC/_git/IaC//terraform/modules/azure_container_registry?ref=0.0.12"

  location            = "eastus"
  name                = "myAdvancedACRRegistry"
  resource_group_name = "exampleResourceGroup"
  sku                 = "Premium"
  admin_enabled       = true

  # Zone replciation setting
  zone_redundancy_enabled = true

  # Geo-replication settings
  georeplications = [
    {
      location                  = "westus"
      regional_endpoint_enabled = true
      zone_redundancy_enabled   = true
      tags                      = { environment = "production" }
    }
  ]

  # Customer managed key settings
  customer_managed_key = {
    key_vault_resource_id = "/subscriptions/{subscription-id}/resourceGroups/{resource-group}/providers/Microsoft.KeyVault/vaults/{key-vault-name}"
    key_name              = "myKeyName"
    key_version           = "myKeyVersion"
    user_assigned_identity = {
      resource_id = "/subscriptions/{subscription-id}/resourceGroups/{resource-group}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/{identity-name}"
    }
  }

  # Private endpoint configuration for ACR with DNS zone
  private_endpoints = {
    acr_private_endpoint = {
      name               = "myACRPrivateEndpoint"
      subnet_resource_id = "/subscriptions/{subscription-id}/resourceGroups/{network-resource-group}/providers/Microsoft.Network/virtualNetworks/{vnet-name}/subnets/{subnet-name}"
      private_dns_zone_group_name = "acrPrivateDNSZoneGroup"
      private_dns_zone_resource_ids = [
        "/subscriptions/{subscription-id}/resourceGroups/{dns-resource-group}/providers/Microsoft.Network/privateDnsZones/privatelink.azurecr.io"
      ]
      lock = {
        kind = "CanNotDelete"
      }
      tags = {
        environment = "production"
      }
    }
  }

  # Retention policy for untagged manifests
  retention_policy_in_days = 14
}

```

## Important Notes

- The `location` variable is restricted to `eastus` and `westus`.
- `lock` configuration only allows `kind` values of `"CanNotDelete"` and `"ReadOnly"`.
- This module relies on the Azure Verified Module for resource creation and management, ensuring robust configurations.
- Ensure that any managed identity provided in `customer_managed_key` has the necessary permissions on the key vault.

## References

- **Azure Verified Modules Documentation**: [Azure Verified Modules](https://azure.github.io/Azure-Verified-Modules/)
- **Azure Verified Resource Modules**: [Resource Modules Index](https://azure.github.io/Azure-Verified-Modules/indexes/terraform/tf-resource-modules/)
- **Azure Verified Module for Container Registry**:
  - Terraform Registry: [AVM Container Registry](https://registry.terraform.io/modules/Azure/avm-res-containerregistry-registry/azurerm/latest/)
  - GitHub Repository: [GitHub - AVM Container Registry Module](https://github.com/Azure/terraform-azurerm-avm-res-containerregistry-registry)
- **Azure Container Registry Documentation**: [Azure Container Registry](https://learn.microsoft.com/en-us/azure/container-registry/zone-redundancy#regional-support)

This module leverages the capabilities of the AVM Container Registry module, simplifying deployment and providing extensive configurability within the Azure environment.
