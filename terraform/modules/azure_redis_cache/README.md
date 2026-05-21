# Azure Redis Cache Terraform Module

This Terraform module provisions an Azure Redis Cache resource using the [Azure Verified Module](https://registry.terraform.io/modules/Azure/avm-res-cache-redis/azurerm/latest) for Redis Cache. It supports extensive configuration options for Redis Cache, including firewall rules, access policies, managed identities, diagnostics settings, private endpoints, and more.

---

## Table of Contents

- [Azure Redis Cache Terraform Module](#azure-redis-cache-terraform-module)
  - [Table of Contents](#table-of-contents)
  - [Module Overview](#module-overview)
    - [Supported Redis SKUs](#supported-redis-skus)
  - [Requirements](#requirements)
  - [Providers](#providers)
  - [Module Inputs](#module-inputs)
  - [Module Outputs](#module-outputs)
  - [Complex Parameter Explanations](#complex-parameter-explanations)
    - [`cache_access_policies`](#cache_access_policies)
    - [`cache_firewall_rules`](#cache_firewall_rules)
    - [`private_endpoints`](#private_endpoints)
    - [`redis_configuration`](#redis_configuration)
    - [`patch_schedule`](#patch_schedule)
  - [Additional Information on Parameters](#additional-information-on-parameters)
  - [Usage Examples](#usage-examples)
    - [Basic Example](#basic-example)
    - [Example with Cache Policies and Private Endpoints](#example-with-cache-policies-and-private-endpoints)
    - [Example with Advanced Redis Configuration](#example-with-advanced-redis-configuration)
    - [Example Using Private Endpoints](#example-using-private-endpoints)
  - [Additional Documentation](#additional-documentation)

---

## Module Overview

The Azure Redis Cache Terraform Module provisions a Redis Cache instance in Azure. This module leverages the [Azure Verified Module for Redis Cache](https://registry.terraform.io/modules/Azure/avm-res-cache-redis/azurerm/latest), which ensures compliance with best practices.

### Supported Redis SKUs

- **Basic**
- **Standard**
- **Premium**
- **Enterprise**

With this module, you can specify various settings such as access policies, firewall rules, diagnostics settings, and managed identities, along with configuring specific Redis Cache settings like backup, memory limits, and patch schedules.

---

## Requirements

- **Terraform**: `>= 1.7`
- **Providers**:
  - `azapi`: `~> 1.13, != 1.13.0`
  - `azurerm`: `~> 3.105`
  - `modtm`: `~> 0.3`
  - `random`: `~> 3.5`

---

## Providers

| Provider | Source            | Version              |
| -------- | ----------------- | -------------------- |
| azapi    | azure/azapi       | `~> 1.13, != 1.13.0` |
| azurerm  | hashicorp/azurerm | `~> 3.105`           |
| modtm    | azure/modtm       | `~> 0.3`             |
| random   | hashicorp/random  | `~> 3.5`             |

---

## Module Inputs

| Name                              | Description                                              | Type     | Default           | Possible Values                                                                              |
| --------------------------------- | -------------------------------------------------------- | -------- | ----------------- | -------------------------------------------------------------------------------------------- |
| `location`                        | Azure region for resource deployment.                    | `string` | `"eastus"`        | `"eastus"`, `"westus"`                                                                       |
| `name`                            | Name of the Redis Cache instance.                        | `string` | -                 | Any non-empty string                                                                         |
| `resource_group_name`             | Name of the resource group.                              | `string` | -                 | Any non-empty string                                                                         |
| `common_tags`                     | Common tags for all resources.                           | `map`    | -                 | At least one key-value pair                                                                  |
| `cache_access_policies`           | Map of Redis Cache access policies.                      | `map`    | `{}`              | Each policy must have `name` and `permissions`.                                              |
| `cache_access_policy_assignments` | Map of Redis Cache access policy assignments.            | `map`    | `{}`              | `name`, `access_policy_name`, `object_id`, `object_id_alias` required.                       |
| `cache_firewall_rules`            | Map of firewall rules for Redis Cache.                   | `map`    | `{}`              | IPs must be within `10.0.0.0/16` range.                                                      |
| `capacity`                        | Redis Cache size.                                        | `number` | `1`               | `0-6` (Basic/Standard), `1-5` (Premium), `1, 5, 10, 20, 50, 100, 200, 400` (Enterprise)      |
| `diagnostic_settings`             | Map of diagnostic settings.                              | `map`    | `{}`              | Various diagnostic settings                                                                  |
| `enable_non_ssl_port`             | Enable non-SSL port 6379.                                | `bool`   | `false`           | `true`, `false`                                                                              |
| `enable_telemetry`                | Enable telemetry.                                        | `bool`   | `true`            | `true`, `false`                                                                              |
| `linked_redis_caches`             | Map of linked Redis Cache instances.                     | `map`    | `{}`              | Must contain `linked_redis_cache_resource_id`, `linked_redis_cache_location`, `server_role`. |
| `lock`                            | Resource lock configuration.                             | `object` | `null`            | `CanNotDelete`, `ReadOnly`                                                                   |
| `managed_identities`              | Managed identity configuration.                          | `object` | `{}`              | Configure system/user-assigned identities                                                    |
| `minimum_tls_version`             | Minimum TLS version (1.2 or higher).                     | `string` | `"1.2"`           | `"1.2"`, `"1.3"`                                                                             |
| `patch_schedule`                  | Patch schedule for Redis Cache.                          | `set`    | `[]`              | Day of week, maintenance window, start hour (UTC)                                            |
| `private_endpoints`               | Map of private endpoints for Redis Cache.                | `map`    | `{}`              | Configure each endpoint's settings                                                           |
| `private_static_ip_address`       | Static IP address for Redis Cache, within `10.0.0.0/16`. | `string` | `null`            | Valid IPv4 in `10.0.0.0/16` CIDR range                                                       |
| `public_network_access_enabled`   | Enable public network access.                            | `bool`   | `false`           | `true`, `false`                                                                              |
| `redis_configuration`             | Redis-specific configuration settings.                   | `object` | `{}`              | Backup, max memory, data persistence                                                         |
| `redis_version`                   | Redis version (major version only).                      | `number` | `6`               | `4`, `6`                                                                                     |
| `replicas_per_master`             | Number of replicas per master.                           | `number` | `null`            | -                                                                                            |
| `replicas_per_primary`            | Number of replicas per primary.                          | `number` | `null`            | -                                                                                            |
| `role_assignments`                | Role assignments for Redis Cache.                        | `map`    | `{}`              | Role definition ID, principal ID                                                             |
| `shard_count`                     | Number of shards (Premium SKU only).                     | `number` | `null`            | `1-10`                                                                                       |
| `sku_name`                        | Redis SKU name.                                          | `string` | `"Enterprise"`    | `"Basic"`, `"Standard"`, `"Premium"`, `"Enterprise"`                                         |
| `subnet_resource_id`              | Subnet ID for Redis Cache deployment (Premium SKU only). | `string` | `null`            | -                                                                                            |
| `tags`                            | Custom tags for the Redis Cache resource.                | `map`    | `{}`              | Additional resource-specific tags                                                            |
| `tenant_settings`                 | Tenant settings for Redis Cache.                         | `map`    | `{}`              | Key-value map                                                                                |
| `zones`                           | Availability zones for Redis Cache.                      | `list`   | `["1", "2", "3"]` | `1`, `2`, `3`                                                                                |

---

## Module Outputs

| Name                              | Description                                                               |
| --------------------------------- | ------------------------------------------------------------------------- |
| `name`                            | Name of the Redis Cache resource.                                         |
| `private_endpoints`               | Map of private endpoints associated with the Redis Cache.                 |
| `resource`                        | The complete resource object for Redis Cache.                             |
| `resource_id`                     | Resource ID of the Redis Cache instance.                                  |
| `system_assigned_mi_principal_id` | Principal ID of the system-assigned managed identity for the Redis Cache. |
| `primary_connection_string`       | Primary connection string for Redis Cache access.                         |
| `secondary_connection_string`     | Secondary connection string for Redis Cache access.                       |
| `primary_key`                     | Primary access key for Redis Cache.                                       |
| `secondary_key`                   |

Secondary access key for Redis Cache. |

---

## Complex Parameter Explanations

### `cache_access_policies`

Defines Redis Cache access policies. Each policy must include:

- `name`: A unique name for the policy.
- `permissions`: A string defining permissions for the policy.

### `cache_firewall_rules`

Defines firewall rules for Redis Cache. Each rule requires:

- `name`: A unique rule name.
- `start_ip` and `end_ip`: Define IP range in `10.0.0.0/16`.

### `private_endpoints`

Configures private endpoints for Redis Cache, requiring:

- `subnet_resource_id`: Resource ID of the subnet.
- `private_dns_zone_group_name` (optional): Name of the private DNS zone group.

### `redis_configuration`

Allows configuration of Redis-specific settings, including:

- `maxmemory_policy`: Defines the memory eviction policy.
- `rdb_backup_enabled`: Enables RDB backup.
- `rdb_backup_frequency`: Frequency of backups in minutes.

### `patch_schedule`

Defines the maintenance schedule. Each entry in the set can include:

- `day_of_week`: Day for maintenance (e.g., "Monday").
- `start_hour_utc`: Hour (UTC) for maintenance start.

---

## Additional Information on Parameters

For detailed parameter definitions and optional inputs for this module, refer to the [Azure Verified Redis Cache Module Documentation on GitHub](https://github.com/Azure/terraform-azurerm-avm-res-cache-redis?tab=readme-ov-file#optional-inputs). This resource provides in-depth descriptions for each parameter, including complex options for telemetry, diagnostics, managed identities, and Redis configuration.

---

## Usage Examples

### Basic Example

```hcl
module "redis_cache" {
  source              = "Azure/avm-res-cache-redis/azurerm"
  location            = "eastus"
  name                = "myRedisCache"
  resource_group_name = "myResourceGroup"
  sku_name            = "Standard"
  capacity            = 1

  tags = {
    environment = "dev"
    department  = "engineering"
  }
}
```

### Example with Cache Policies and Private Endpoints

```hcl
module "redis_cache" {
  source              = "Azure/avm-res-cache-redis/azurerm"
  location            = "westus"
  name                = "secureRedisCache"
  resource_group_name = "prodResourceGroup"
  sku_name            = "Premium"
  capacity            = 3
  private_static_ip_address = "10.0.1.10"

  cache_access_policies = {
    policy1 = {
      name        = "access_policy_1"
      permissions = "+@all"
    }
  }

  private_endpoints = {
    endpoint1 = {
      subnet_resource_id = "/subscriptions/.../subnet/endpointSubnet"
      private_dns_zone_group_name = "private_dns"
    }
  }

  tags = {
    environment = "production"
    owner       = "security-team"
  }
}
```

### Example with Advanced Redis Configuration

```hcl
module "redis_cache" {
  source              = "Azure/avm-res-cache-redis/azurerm"
  location            = "eastus"
  name                = "advancedRedisCache"
  resource_group_name = "myResourceGroup"
  sku_name            = "Premium"
  capacity            = 2

  redis_configuration = {
    maxmemory_policy   = "allkeys-lru"
    rdb_backup_enabled = true
    rdb_backup_frequency = 60
  }

  patch_schedule = [
    {
      day_of_week = "Saturday"
      maintenance_window = "PT4H"
      start_hour_utc = 23
    }
  ]

  enable_telemetry = true

  tags = {
    project = "advanced-cache"
    owner   = "infra-team"
  }
}
```

### Example Using Private Endpoints

In this example, the Redis Cache instance is configured with private endpoints for secure access within a VNet.

```hcl
module "redis_cache_with_private_endpoints" {
  source              = "Azure/avm-res-cache-redis/azurerm"
  location            = "eastus"
  name                = "privateRedisCache"
  resource_group_name = "vnetResourceGroup"
  sku_name            = "Enterprise"
  capacity            = 10

  # Configure private endpoints
  private_endpoints = {
    primary_endpoint = {
      name                       = "primaryRedisEndpoint"
      subnet_resource_id         = "/subscriptions/<subscription_id>/resourceGroups/<rg_name>/providers/Microsoft.Network/virtualNetworks/<vnet_name>/subnets/<subnet_name>"
      private_dns_zone_group_name = "redis-private-dns"
      private_dns_zone_resource_ids = [
        "/subscriptions/<subscription_id>/resourceGroups/<rg_name>/providers/Microsoft.Network/privateDnsZones/privatelink.redis.cache.windows.net"
      ]
    }
  }

  tags = {
    environment = "production"
    owner       = "network-team"
  }
}
```

In this configuration:

- `private_endpoints` is defined with one endpoint named `primary_endpoint`.
- The `subnet_resource_id` points to a specific subnet within a VNet where the Redis Cache will connect privately.
- `private_dns_zone_group_name` and `private_dns_zone_resource_ids` specify DNS settings to integrate the Redis Cache into the private DNS zone.

---

## Additional Documentation

Explore additional documentation and resources related to this module:

- [Azure Verified Modules - Terraform Resource Modules](https://azure.github.io/Azure-Verified-Modules/indexes/terraform/tf-resource-modules/)
- [Azure Verified Modules - Terraform](https://azure.github.io/Azure-Verified-Modules/indexes/terraform/)
- [Azure Verified Redis Cache Module](https://registry.terraform.io/modules/Azure/avm-res-cache-redis/azurerm/latest)
- [GitHub Repository for Azure Verified Redis Cache Module](https://github.com/Azure/terraform-azurerm-avm-res-cache-redis)
- [Azure Cache for Redis Documentation](https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/)
- [Azure Cache Service Tiers](https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-overview#service-tiers)
- [Azure Cache Active Directory Authentication](https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-azure-active-directory-for-authentication)
- [Azure Cache Pricing Details](https://azure.microsoft.com/en-us/pricing/details/cache/)
- [How to Scale Azure Cache for Redis](https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-how-to-scale?tabs=scale-up-and-down-with-basic-standard-and-premium)
