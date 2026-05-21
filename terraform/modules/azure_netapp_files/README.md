# Azure NetApp Files

This Terraform module creates and manages Azure NetApp Accounts, Pools, and Volumes. This module deploys an Azure NetApp Files (ANF) account along with optional Active Directory integration, user-assigned identity, and tagging, using the Azure verified module for NetApp Files.

## Table of Contents

- [Azure NetApp Files Terraform Module](#azure-netapp-files-terraform-module)
  - [Table of Contents](#table-of-contents)
  - [Features](#features)
  - [Requirements](#requirements)
  - [Resources](#resources)
  - [Azure NetApp Account Terraform Module](#azure-netapp-account-terraform-module)
    - [Prerequisites](#prerequisites)
    - [Example Usage](#example-usage)
      - [Create a NetApp Account](#create-a-netapp-account)
  - [Input Variables](#input-variables)
    - [Required Inputs](#required-inputs)
    - [Optional Inputs](#optional-inputs)
  - [Outputs](#outputs)
  - [Usage](#usage)
  - [References](#references)

## Features

- Creates an Azure NetApp Account.
- Creates an Azure NetApp Pool.
- Configures and manages Azure NetApp Volumes with options for data protection and backup policies.

## Requirements

- **Terraform:** ~> 1.9
- **AzureRM Provider:** >= 3.71

## Resources

The following resources are created by this module:

- `azurerm_netapp_account.this`
- `azurerm_netapp_pool.this`
- `azurerm_netapp_volume.this`
- `azurerm_user_assigned_identity.this`
- `azurerm_management_lock.this`
- `azurerm_monitor_diagnostic_setting.this`

# Azure NetApp Account Terraform Module

This module manages an Azure NetApp Account using Terraform. Azure NetApp Files (ANF) is an Azure service that provides enterprise-grade file services that are simple to manage, highly available, and performant.

## Prerequisites

- An active Azure subscription.
- The [Terraform CLI](https://www.terraform.io/downloads.html) installed.
- The `azurerm` provider installed in your Terraform project.

## Example Usage

### Create a NetApp Account

The following example demonstrates how to create a NetApp account in Azure using Terraform.

```hcl
# Define the Resource Group
resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "West Europe"
}

# Define the Azure Client Configuration (e.g., for authentication)
data "azurerm_client_config" "current" {}

# Define a User-Assigned Identity
resource "azurerm_user_assigned_identity" "example" {
  name                = "anf-user-assigned-identity"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Create the NetApp Account
resource "azurerm_netapp_account" "example" {
  name                = "netappaccount"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  active_directory {
    username            = "aduser"
    password            = "aduserpwd"
    smb_server_name     = "SMBSERVER"
    dns_servers         = ["1.2.3.4"]
    domain              = "westcentralus.com"
    organizational_unit = "OU=FirstLevel"
  }

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.example.id
    ]
  }

  tags = {
    Environment = "Production"
    Department  = "IT"
  }
}
```
## Arguments

### `azurerm_netapp_account` Arguments

#### Required Arguments

- **`name`** (string):  
  The name of the NetApp account. Changing this forces a new resource to be created.

- **`resource_group_name`** (string):  
  The name of the resource group in which the NetApp account should be created. Changing this forces a new resource to be created.

- **`location`** (string):  
  The Azure location where the NetApp account should be created. Changing this forces a new resource to be created.

#### Optional Arguments

- **`active_directory`** (block):  
  Configures Active Directory integration for the NetApp account. The block supports the following sub-arguments:
  - **`username`** (string): The username of the Active Directory domain administrator.
  - **`password`** (string): The password associated with the username.
  - **`smb_server_name`** (string): The NetBIOS name used for the NetApp SMB server.
  - **`dns_servers`** (list of strings): A list of DNS server IP addresses for the Active Directory domain.
  - **`domain`** (string): The name of the Active Directory domain.
  - **`organizational_unit`** (string): (Optional) The Organizational Unit (OU) within Active Directory where machines will be created. Defaults to `CN=Computers` if blank.
  - **`site_name`** (string): (Optional) The Active Directory site for domain controller discovery. Defaults to `Default-First-Site-Name` if blank.
  - **`kerberos_ad_name`** (string): (Optional) The Kerberos AD machine name.
  - **`kerberos_kdc_ip`** (list of strings): (Optional) KDC server IP addresses for the Kerberos AD machine.
  - **`aes_encryption_enabled`** (bool): (Optional) Enables AES encryption for SMB communication. Defaults to `false`.
  - **`local_nfs_users_with_ldap_allowed`** (bool): (Optional) Allows NFS client local users in addition to LDAP users. Defaults to `false`.
  - **`ldap_over_tls_enabled`** (bool): (Optional) Secures LDAP traffic via TLS. Defaults to `false`.
  - **`server_root_ca_certificate`** (string): (Optional) Base64 encoded LDAP self-signed root CA certificate. Required if `ldap_over_tls_enabled` is set to `true`.
  - **`ldap_signing_enabled`** (bool): (Optional) Enables LDAP traffic signing. Defaults to `false`.

- **`identity`** (block):  
  Configures the identity of the NetApp account. The block supports the following sub-arguments:
  - **`type`** (string): The identity type. Valid values are `SystemAssigned` or `UserAssigned`. Only one type can be specified.
  - **`identity_ids`** (list of strings): (Optional) The identity IDs to use when the type is `UserAssigned`.

- **`tags`** (map of strings):  
  A map of tags to assign to the NetApp account.

#### Timeouts

You can configure timeouts for creating, updating, reading, and deleting the NetApp account:

```hcl
timeouts {
  create = "30m"
  update = "30m"
  read   = "5m"
  delete = "30m"
}
```

# Azure NetApp Pool Terraform Module

This module manages a pool within an Azure NetApp account using Terraform. It simplifies the creation, configuration, and management of a NetApp pool, which is essential for Azure NetApp Files to provide scalable and performant storage.

## NetApp Pool Usage

### Example Terraform Configuration:

```hcl
resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "West Europe"
}

resource "azurerm_netapp_account" "example" {
  name                = "example-netappaccount"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_netapp_pool" "example" {
  name                = "example-netapppool"
  account_name        = azurerm_netapp_account.example.name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  service_level       = "Premium"
  size_in_tb          = 4
}
```
## Arguments

### `azurerm_netapp_pool` Arguments

#### Required Arguments

- **`name`** (string):  
  The name of the NetApp Pool. Changing this forces a new resource to be created.

- **`resource_group_name`** (string):  
  The name of the resource group where the NetApp Pool should be created. Changing this forces a new resource to be created.

- **`account_name`** (string):  
  The name of the NetApp account in which the NetApp Pool should be created. Changing this forces a new resource to be created.

- **`location`** (string):  
  Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created.

- **`service_level`** (string):  
  The service level of the file system. Valid values include `Premium`, `Standard`, and `Ultra`. Changing this forces a new resource to be created.

- **`size_in_tb`** (number):  
  Provisioned size of the pool in TB. The value must be between 1 and 2048.

#### Optional Arguments

- **`qos_type`** (string):  
  QoS Type of the pool. Valid values include `Auto` or `Manual`. Defaults to `Auto`.

- **`encryption_type`** (string):  
  The encryption type of the pool. Valid values include `Single` and `Double`. Defaults to `Single`. Changing this forces a new resource to be created.

- **`tags`** (map of strings):  
  A map of tags to assign to the NetApp Pool.

#### Notes

- **`size_in_tb`**:  
  - 2 TB capacity pool sizing is currently in preview. You can only take advantage of the 2 TB minimum if all the volumes in the capacity pool are using Standard network features. If any volume is using Basic network features, the minimum size is 4 TB.
  - The maximum `size_in_tb` is governed by regional quotas. You may request additional capacity from Azure, currently up to 2048 TB.

## Attributes

In addition to the arguments listed above, the following attributes are exported:

- **`id`** (string):  
  The ID of the NetApp Pool.

## Timeouts

You can configure timeouts for creating, updating, reading, and deleting the NetApp Pool:

```hcl
timeouts {
  create = "30m"
  update = "30m"
  read   = "5m"
  delete = "30m"
}
```

# Terraform `azurerm_netapp_volume` Resource

## Overview

The `azurerm_netapp_volume` resource is used to manage Azure NetApp Volumes, which offer high-performance file storage on Azure NetApp Files. The resource supports features such as snapshot policies, backup policies, and data protection replication.

### Important Notes

- The `prevent_volume_destruction` attribute is enabled by default to prevent accidental deletion of the volume.
- This resource supports creating NetApp volumes with data protection, backup policies, and snapshot replication.

## Example Usage

### Provider Configuration

# Resource Configuration

```hcl
resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "West Europe"
}

resource "azurerm_virtual_network" "example" {
  name                = "example-virtualnetwork"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "example" {
  name                 = "example-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]

  delegation {
    name = "netapp"

    service_delegation {
      name    = "Microsoft.Netapp/volumes"
      actions = ["Microsoft.Network/networkinterfaces/*", "Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_netapp_account" "example" {
  name                = "example-netappaccount"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_netapp_backup_vault" "example" {
  name                = "example-netappbackupvault"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  account_name        = azurerm_netapp_account.example.name
}

resource "azurerm_netapp_backup_policy" "example" {
  name                    = "example-netappbackuppolicy"
  resource_group_name     = azurerm_resource_group.example.name
  location                = azurerm_resource_group.example.location
  account_name            = azurerm_netapp_account.example.name
  daily_backups_to_keep   = 2
  weekly_backups_to_keep  = 2
  monthly_backups_to_keep = 2
  enabled                 = true
}

resource "azurerm_netapp_pool" "example" {
  name                = "example-netapppool"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  account_name        = azurerm_netapp_account.example.name
  service_level       = "Premium"
  size_in_tb          = 4
}

resource "azurerm_netapp_volume" "example" {
  name                       = "example-netappvolume"
  location                   = azurerm_resource_group.example.location
  zone                       = "1"
  resource_group_name        = azurerm_resource_group.example.name
  account_name               = azurerm_netapp_account.example.name
  pool_name                  = azurerm_netapp_pool.example.name
  volume_path                = "my-unique-file-path"
  service_level              = "Premium"
  subnet_id                  = azurerm_subnet.example.id
  protocols                  = ["NFSv4.1"]
  security_style             = "unix"
  storage_quota_in_gb        = 100
  snapshot_directory_visible = false

  # When creating volume from a snapshot
  create_from_snapshot_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/group1/providers/Microsoft.NetApp/netAppAccounts/account1/capacityPools/pool1/volumes/volume1/snapshots/snapshot1"

  # Following section is only required if deploying a data protection volume (secondary)
  # to enable Cross-Region Replication feature
  data_protection_replication {
    endpoint_type             = "dst"
    remote_volume_location    = azurerm_resource_group.example.location
    remote_volume_resource_id = azurerm_netapp_volume.example.id
    replication_frequency     = "10minutes"
  }

  # Enabling Snapshot Policy for the volume
  data_protection_snapshot_policy {
    snapshot_policy_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/group1/providers/Microsoft.NetApp/netAppAccounts/account1/snapshotPolicies/snapshotpolicy1"
  }

  # Enabling backup policy
  data_protection_backup_policy {
    backup_vault_id  = azurerm_netapp_backup_vault.example.id
    backup_policy_id = azurerm_netapp_backup_policy.example.id
    policy_enabled   = true
  }

  # prevent the possibility of accidental data loss
  lifecycle {
    prevent_destroy = true
  }
}
```
## Argument Reference

The following arguments are supported:

- **name** (Required): The name of the NetApp Volume. Changing this forces a new resource to be created.
- **resource_group_name** (Required): The name of the resource group where the NetApp Volume should be created.
- **location** (Required): The supported Azure location where the resource exists.
- **zone** (Optional): Specifies the Availability Zone for the Volume. Possible values: 1, 2, 3.
- **account_name** (Required): The name of the NetApp account in which the NetApp Pool is located.
- **volume_path** (Required): A unique file path for the volume.
- **pool_name** (Required): The name of the NetApp pool in which the NetApp Volume should be created.
- **service_level** (Required): The target performance of the file system. Valid values: Premium, Standard, or Ultra.
- **azure_vmware_data_store_enabled** (Optional): Enables the NetApp Volume for Azure VMware Solution (AVS).
- **protocols** (Optional): The volume protocol list (CIFS, NFSv3, NFSv4.1).
- **security_style** (Optional): Volume security style (unix, ntfs).
- **subnet_id** (Required): The ID of the Subnet for the volume, must have the Microsoft.NetApp/volumes delegation.
- **network_features** (Optional): Network feature option (Basic or Standard).
- **storage_quota_in_gb** (Required): The storage quota for the volume in GB.
- **snapshot_directory_visible** (Optional): Whether the `.snapshot` directory is visible.
- **create_from_snapshot_resource_id** (Optional): Creates the volume from an existing snapshot.
- **data_protection_replication** (Optional): Data protection replication block.
- **data_protection_snapshot_policy** (Optional): Snapshot policy for data protection.
- **data_protection_backup_policy** (Optional): Backup policy for data protection.
- **export_policy_rule** (Optional): Defines export policy rules.
- **throughput_in_mibps** (Optional): Throughput for the volume in Mibps.
- **encryption_key_source** (Optional): The encryption key source (Microsoft.NetApp or Microsoft.KeyVault).
- **kerberos_enabled** (Optional): Enable Kerberos secured volumes.
- **key_vault_private_endpoint_id** (Optional): Private Endpoint ID for Key Vault, required with customer-managed keys.
- **smb_non_browsable_enabled** (Optional): Hides SMB shares from directory listings.
- **smb_access_based_enumeration_enabled** (Optional): Limits enumeration of files in SMB shares.
- **smb_continuous_availability_enabled** (Optional): Enables SMB Continuous Availability.
- **smb3_protocol_encryption_enabled** (Optional): Enables SMB encryption.
- **tags** (Optional): A map of tags to assign to the resource.

## Export Policy Rule Block

The `export_policy_rule` block supports the following:

- **rule_index** (Required): The index number of the rule.
- **allowed_clients** (Required): A list of allowed client IP addresses.
- **protocols_enabled** (Optional): List of allowed protocols (CIFS, NFSv3, NFSv4.1).
- **unix_read_only** (Optional): Whether the file system is read-only on Unix.
- **unix_read_write** (Optional): Whether the file system is read-write on Unix.
- **root_access_enabled** (Optional): Whether root access is permitted.
- **kerberos_5_read_only_enabled** (Optional): Kerberos 5 read-only access.
- **kerberos_5_read_write_enabled** (Optional): Kerberos 5 read-write access.
- **kerberos_5i_read_only_enabled** (Optional): Kerberos 5i read-only access.
- **kerberos_5i_read_write_enabled** (Optional): Kerberos 5i read-write access.
- **kerberos_5p_read_only_enabled** (Optional): Kerberos 5p read-only access.
- **kerberos_5p_read_write_enabled** (Optional): Kerberos 5p read-write access.

## Data Protection Replication Block

Used for enabling Cross-Region Replication (CRR):

- **endpoint_type** (Optional): Default is `dst` for destination.
- **remote_volume_location** (Required): Location of the primary volume.
- **remote_volume_resource_id** (Required): Resource ID of the primary volume.
- **replication_frequency** (Required): Replication frequency (10minutes, hourly, daily).

## Data Protection Snapshot Policy Block

For applying snapshot policies for data protection:

- **snapshot_policy_id** (Required): The Snapshot Policy ID.
- **policy_enabled** (Required): Whether the snapshot policy is enabled.

## Outputs

This resource can produce the following outputs:

- **id**: The ID of the NetApp Volume.
- **name**: The name of the NetApp Volume.
- **resource_group_name**: The resource group the NetApp Volume is in.
- **location**: The location of the NetApp Volume.
- **service_level**: The service level for the volume.
- **size_in_gb**: The size of the volume in GB.
- **subnet_id**: The ID of the subnet for the volume.

## References

- [AzureRM NetApp-Account Terraform registry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/netapp_account)
- [AzureRM NetApp-Pool Terraform registry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/netapp_pool)
- [AzureRM NetApp-Volume Terraform registry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/netapp_volume)


