# Azure Files (Storage Account) Terraform Module

This module provisions an Azure Storage Account with support for Azure Files using the [Azure Verified Module (AVM)](https://registry.terraform.io/modules/Azure/avm-res-storage-storageaccount/azurerm/latest) for storage accounts.

## Table of Contents
- [Azure Files (Storage Account) Terraform Module](#azure-files-storage-account-terraform-module)
  - [Table of Contents](#table-of-contents)
  - [Requirements](#requirements)
  - [Module Usage Example](#module-usage-example)
  - [Inputs](#inputs)
    - [Required Inputs](#required-inputs)
    - [Optional Inputs](#optional-inputs)
  - [Additional Details on Complex Optional Inputs](#additional-details-on-complex-optional-inputs)
    - [`managed_identities`](#managed_identities)
      - [Example](#example)
    - [`private_endpoints`](#private_endpoints)
      - [Example](#example-1)
    - [`role_assignments`](#role_assignments)
      - [Example](#example-2)
    - [`azure_files_authentication`](#azure_files_authentication)
    - [Description](#description)
      - [active\_directory block supports the following:](#active_directory-block-supports-the-following)
      - [Example](#example-3)
    - [`shares`](#shares)
      - [Description](#description-1)
      - [acl block supports the following:](#acl-block-supports-the-following)
      - [access\_policy block supports the following:](#access_policy-block-supports-the-following)
      - [timeouts block supports the following:](#timeouts-block-supports-the-following)
      - [Example](#example-4)
  - [Outputs](#outputs)
  - [Important Notes](#important-notes)
  - [References](#references)

## Requirements

The following requirements are needed by this module:

- **terraform** (>= 1.7.0)
- **azapi** (>= 1.14.0, < 3.0.0)
- **azurerm** (>= 3.116.0, < 5.0.0)
- **modtm** (~> 0.3)
- **random** (>= 3.5.0, < 4.0.0)

## Module Usage Example

```hcl
module "storage_account" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "0.5.0"

  location              = module.base.location
  name                  = "sa${module.base.app_name}${module.base.environment}${module.base.environment_number_suffix}"
  resource_group_name   = module.base.resource_group_name

  access_tier                           = var.access_tier
  account_kind                          = var.account_kind
  account_replication_type              = var.account_replication_type
  account_tier                          = var.account_tier
  enable_telemetry                      = module.base.enable_telemetry
  lock                                  = module.base.lock
  network_rules                         = var.network_rules
  role_assignments                      = module.base.role_assignments
  managed_identities                    = var.managed_identities
  public_network_access_enabled         = var.public_network_access_enabled
  tags                                  = module.base.tags
  is_hns_enabled                        = var.is_hns_enabled
  large_file_share_enabled              = var.large_file_share_enabled
  private_endpoints                     = module.base.private_endpoints
  private_endpoints_manage_dns_zone_group = var.private_endpoints_manage_dns_zone_group
  azure_files_authentication            = var.azure_files_authentication
  infrastructure_encryption_enabled     = var.infrastructure_encryption_enabled
  min_tls_version                       = var.min_tls_version
  shares                                = var.shares
  shared_access_key_enabled             = var.shared_access_key_enabled

  depends_on = [module.base]
}
```

---
## Inputs

### Required Inputs

| Name                | Description                                                                                                    | Type   | Default     |
|---------------------|----------------------------------------------------------------------------------------------------------------|--------|-------------|
| `location`          | Azure region where the resource should be deployed.                                                            | string | "eastus"    |
| `name`              | The name of the storage account.                                                                               | string | {}          |
| `resource_group_name` | The name of the resource group where resources will be deployed.                                             | string | ()          |
| `access_tier`         | Defines the access tier. Valid options: `Hot`, `Cool`.                                                       | string | "Hot"       |
| `account_replication_type`  | Type of replication. Valid options: `LRS`, `GRS`, `RAGRS`, `ZRS`, `GZRS`, `RAGZRS`.                    | string | "LRS"       |

---

### Optional Inputs

| Name                                  | Description                                                                                                    | Type   | Default     |
|---------------------------------------|----------------------------------------------------------------------------------------------------------------|--------|-------------|
| `account_kind`                        | Defines the Kind of account. Valid options: `BlobStorage`, `BlockBlobStorage`, `FileStorage`, `Storage`, `StorageV2`. | string | "StorageV2"|
| `account_tier`                        | Defines the Tier: `Standard`, `Premium`.                                                                       | string | "Standard" |
| `azure_files_authentication`         | Enables Azure Files authentication. Includes `directory_type`, `default_share_level_permission`, and optional `active_directory` block. | object | null        |
| `enable_telemetry`                   | Enable telemetry reporting.                                                                                   | bool   | false       |
| `lock`                                | Resource lock configuration.                                                                                  | object | null        |
| `network_rules`                      | Storage account network rule set.                                                                             | any    | {}          |
| `role_assignments`                   | Role assignments configuration.                                                                               | map    | {}          |
| `managed_identities`                 | Managed Identity configuration.                                                                               | object | {}          |
| `public_network_access_enabled`      | Specifies whether public access is permitted.                                                                 | bool   | false       |
| `is_hns_enabled`                     | Enable Hierarchical Namespace (for Data Lake Storage Gen2).                                                  | bool   | false       |
| `large_file_share_enabled`           | Enable large file share support.                                                                              | bool   | false       |
| `private_endpoints`                  | Private endpoint configurations for the storage account.                                                     | map    | {}          |
| `private_endpoints_manage_dns_zone_group` | Manage private DNS zone group automatically.                                                            | bool   | true        |
| `infrastructure_encryption_enabled`  | Enable infrastructure encryption.                                                                             | bool   | false       |
| `min_tls_version`                    | The minimum supported TLS version. Valid options: `TLS1_0`, `TLS1_1`, `TLS1_2`.                               | string | "TLS1_2"   |
| `shares`                              | Configuration map for Azure File Shares.                                                                      | map    | {}          |
| `shared_access_key_enabled`          | Allow shared access key based authorization.                                                                  | bool   | true        |
| `common_tags`                         | Common tags for all resources.                                                                                | map    | n/a         |
| `resource_tags`                       | Specific resource-level tags.                                                                                 | map    | {}          |

---

## Additional Details on Complex Optional Inputs

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

### `private_endpoints`

- **Description**: Map of private endpoints for the Azure Files.
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
  - **`resource_group_name`** (string, optional): Resource group for the private endpoint. Defaults to the Azure files resource group.
  - **`ip_configurations`** (map of objects, optional): IP configurations for the private endpoint.
    - **`name`** (string, required): Name of the IP configuration.
    - **`private_ip_address`** (string, required): Private IP address for the IP configuration.
- **Default**: `{}`

#### Example

```hcl
private_endpoints = {
  azfs_private_endpoint = {
    name                          = "myazfsPrivateEndpoint"
    subnet_resource_id            = "/subscriptions/your-subscription-id/resourceGroups/your-network-resource-group/providers/Microsoft.Network/virtualNetworks/your-vnet/subnets/your-subnet"
    private_dns_zone_group_name   = "azfsPrivateDNSZoneGroup"
    private_dns_zone_resource_ids = [
      "/subscriptions/your-subscription-id/resourceGroups/your-dns-resource-group/providers/Microsoft.Network/privateDnsZones/privatelink.file.core.windows.net"
    ]
    role_assignments = {
      admin_role = {
        role_definition_id_or_name = "Contributor"
        principal_id               = "your-principal-id"
        description                = "Role assignment for azure files private endpoint"
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

- **Description**: Role assignments to create on the Azure Files.
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
  azfs_admin = {
    role_definition_id_or_name = "AzfsPush"
    principal_id               = "your-principal-id"
    description                = "azure files push access for automation"
    skip_service_principal_aad_check = true
  }
}
```

### `azure_files_authentication`

### Description

- **directory_type** (Required): Specifies the directory service used. Possible values are `AADDS`, `AD`, and `AADKERB`.
  
- **default_share_level_permission** (Optional): Specifies the default share-level permissions applied to all users. Possible values are:
  - `StorageFileDataSmbShareReader`
  - `StorageFileDataSmbShareContributor`
  - `StorageFileDataSmbShareElevatedContributor`
  - `None`

#### active_directory block supports the following:

- **domain_guid** (Required): Specifies the domain GUID.
- **domain_name** (Required): Specifies the primary domain that the AD DNS server is authoritative for.
- **domain_sid** (Required): Specifies the security identifier (SID).
- **forest_name** (Required): Specifies the Active Directory forest.
- **netbios_domain_name** (Required): Specifies the NetBIOS domain name.
- **storage_sid** (Required): Specifies the security identifier (SID) for Azure Storage.
- **Default**: `{}`
#### Example

```hcl
azure_files_authentication = {
    directory_type                 = "AD"
    default_share_level_permission = "StorageFileDataSmbShareContributor"

    active_directory = {
      domain_guid         = "11111111-1111-1111-1111-111111111111"
      domain_name         = "vystar.example.com"
      domain_sid          = "S-1-5-21-1111111111-2222222222-3333333333"
      forest_name         = "vystar.example.com"
      netbios_domain_name = "VYSTAR"
      storage_sid         = "S-1-5-21-4444444444-5555555555-6666666666"
    }
  }


```
### `shares`

#### Description

- **access_tier** (Optional): The access tier of the File Share. Possible values are `Hot`, `Cool`, `TransactionOptimized`, and `Premium`.
  
- **enabled_protocol** (Optional): The protocol used for the share. Possible values are:
  - `SMB` (The share can be accessed by SMBv3.0, SMBv2.1, and REST).
  - `NFS` (The share can be accessed by NFSv4.1).  
  Defaults to `SMB`. Changing this forces a new resource to be created.

- **metadata** (Optional): A mapping of metadata for this File Share.

- **name** (Required): The name of the share. Must be unique within the storage account where the share is located. Changing this forces a new resource to be created.

- **quota** (Required): The maximum size of the share, in gigabytes. For Standard storage accounts, this must be between 1GB (or higher) and 5120 GB (5 TB). For Premium FileStorage storage accounts, this must be between 100 GB and 102400 GB (100 TB).

#### acl block supports the following:

- **id** (Required): The ID which should be used for this Shared Identifier.

#### access_policy block supports the following:

- **expiry** (Optional): The time at which this Access Policy should be valid until, in ISO8601 format.
- **permissions** (Required): The permissions associated with this Shared Identifier. Possible values are a combination of `r` (read), `w` (write), `d` (delete), and `l` (list).
- **start** (Optional): The time at which this Access Policy should be valid from, in ISO8601 format.

#### timeouts block supports the following:

- **create** (Defaults to 30 minutes): Used when creating the Storage Share.
- **delete** (Defaults to 30 minutes): Used when deleting the Storage Share.
- **read** (Defaults to 5 minutes): Used when retrieving the Storage Share.
- **update** (Defaults to 30 minutes): Used when updating the Storage Share.

Supply role assignments in the same way as for `var.role_assignments`.
- **Default**: `{}`

#### Example

```hcl
 shares = {
    share1 = {
      name             = "data-share"
      quota            = 100
      access_tier      = "Hot"
      enabled_protocol = "SMB"
      metadata = {
        environment = "dev"
        owner       = "team-storage"
      }
      signed_identifiers = [
        {
          id = "read-access"
          access_policy = {
            expiry_time = "2025-12-31T23:59:59Z"
            permission  = "r"
            start_time  = "2025-01-01T00:00:00Z"
          }
        }
      ]
      role_assignments = {
        "storage-file-reader" = {
          role_definition_id_or_name = "Storage File Data SMB Share Reader"
          principal_id               = "00000000-0000-0000-0000-000000000001"
        }
      }
      timeouts = {
        create = "40m"
        delete = "30m"
      }
    }

    share2 = {
      name             = "logs-share"
      quota            = 50
      enabled_protocol = "NFS"
      root_squash      = "RootSquash"
    }
  }
```

## Outputs

| Name                    | Description                                              |
|-------------------------|----------------------------------------------------------|
| `storage_account_name` | The name of the storage account.                        |
| `storage_account_rg`   | The resource group name of the storage account.         |
| `storage_account_location` | The Azure region of the storage account.              |
| `resource_id`           | The resource ID of the Azure Files storage account.     |
| `private_endpoints`     | The private endpoints created for Azure Files.          |

---

## Important Notes

- The `location` variable is restricted to `eastus` and `westus`.
- `lock` configuration only allows `kind` values of `"CanNotDelete"` and `"ReadOnly"`.
- This module relies on the Azure Verified Module for resource creation and management, ensuring robust configurations.

## References

- **Azure Verified Modules Documentation**: [Azure Verified Modules](https://azure.github.io/Azure-Verified-Modules/)
- **Azure Verified Resource Modules**: [Resource Modules Index](https://azure.github.io/Azure-Verified-Modules/indexes/terraform/tf-resource-modules/)
- **Azure Verified Module for Storage Account(Azure Files)**:
 - Terraform Registry: [Azure AVM Storage Account Module](https://registry.terraform.io/modules/Azure/avm-res-storage-storageaccount/azurerm)
 - GitHub Repository: [GitHub - Azure AVM Storage Account Module](https://github.com/Azure/terraform-azurerm-avm-res-storage-storageaccount)
- **Terraform Azure Provider Documentation**: [Terraform Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account)
- **Azure Files Overview**: [Azure Files Overview](https://learn.microsoft.com/en-us/azure/storage/files/storage-files-introduction)
