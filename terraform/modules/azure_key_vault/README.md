# Azure Key Vault Terraform Module

This module deploys an Azure Key Vault along with associated keys, secrets, and access policies, utilizing the Azure verified module for Key Vault.

## Table of Contents

- [Azure Key Vault Terraform Module](#azure-key-vault-terraform-module)
  - [Table of Contents](#table-of-contents)
  - [Requirements](#requirements)
  - [Module Usage Example](#module-usage-example)
  - [Resources](#resources)
  - [Input Variables](#input-variables)
    - [Required Inputs](#required-inputs)
    - [Optional Inputs](#optional-inputs)
  - [Additional Details on Complex Optional Inputs](#additional-details-on-complex-optional-inputs)
    - [`managed_identities`](#managed_identities)
      - [Example](#example)
    - [`private_endpoints`](#private_endpoints)
      - [Example](#example-1)
    - [`role_assignments`](#role_assignments)
      - [Example](#example-2)
    - [`keys`](#keys)
      - [Basic Key Configuration](#basic-key-configuration)
      - [Rotation Policy (`rotation_policy` block)](#rotation-policy-rotation_policy-block)
      - [Example](#example-3)
    - [`legacy_access_policies`](#legacy_access_policies)
      - [Attributes:](#attributes)
      - [Role Assignments](#role-assignments)
      - [Example](#example-4)
    - [`secrets`](#secrets)
      - [Attributes:](#attributes-1)
      - [Role Assignments](#role-assignments-1)
      - [Example](#example-5)
  - [Outputs](#outputs)
  - [Important Notes](#important-notes)
  - [References](#references)

## Requirements

- **Terraform:** ~> 1.9
- **AzureRM Provider:** >= 3.71
- **ModTM Provider:** ~> 0.3
- **Random Provider:** ~> 3.5
- **Time Provider:** ~> 0.9

## Module Usage Example

Example usage of this module:

```hcl
module "keyvault" {
  source              = "github.com/Azure/terraform-azurerm-avm-res-keyvault-vault"
  location            = "eastus"
  name                = "my-keyvault"
  resource_group_name = "my-resource-group"
  tenant_id           = var.tenant_id

  # Optional configurations
  enable_telemetry    = false
  custom_resource_group_name      = "existing-rg"
  custom_vnet_name                = "custom-vnet"
  custom_vnet_resource_group_name = "custom-vnet-rg"

  keys = {
    my_key = {
      name         = "key1"
      key_type     = "RSA"
      key_size     = 2048
      key_opts     = ["encrypt", "decrypt"]
    }
  }

  secrets = {
    my_secret = {
      name         = "mySecret"
      content_type = "password"
    }
  }

  secrets_value = {
    my_secret = "superSecretValue"
  }
}
```

## Resources

The following resources are created by this module:

- `azurerm_key_vault.this`
- `azurerm_key_vault_access_policy.this`
- `azurerm_key_vault_certificate_contacts.this`
- `azurerm_management_lock.this`
- `azurerm_monitor_diagnostic_setting.this`
- `azurerm_private_endpoint.this`
- `azurerm_private_endpoint.this_unmanaged_dns_zone_groups`
- `azurerm_private_endpoint_application_security_group_association.this`
- `azurerm_role_assignment.this`
- `modtm_telemetry.telemetry`
- `random_uuid.telemetry`
- `time_sleep.wait_for_rbac_before_contact_operations`
- `time_sleep.wait_for_rbac_before_key_operations`
- `time_sleep.wait_for_rbac_before_secret_operations`
- `azurerm_client_config.telemetry`
- `modtm_module_source.telemetry`

## Input Variables

### Required Inputs

| Name                  | Description                                                                                             | Type   |
|-----------------------|---------------------------------------------------------------------------------------------------------|--------|
| `location`            | The Azure location where the resources will be deployed.                                               | string |
| `name`                | The name of the Key Vault.                                                                             | string |
| `resource_group_name` | The resource group where the resources will be deployed.                                               | string |
| `tenant_id`           | The Azure tenant ID used for authenticating requests to Key Vault.                                     | string |

### Optional Inputs

| Name                                    | Description                                                                                                                     | Type   | Default |
|-----------------------------------------|---------------------------------------------------------------------------------------------------------------------------------|--------|---------|
| `contacts`                              | A map of contacts for the Key Vault.                                                                                            | map(object) | {}      |
| `diagnostic_settings`                   | Diagnostic settings configuration for the Key Vault.                                                                            | map(object) | {}      |
| `enable_telemetry`                      | Enables or disables telemetry collection.                                                                                       | bool   | true    |
| `enabled_for_deployment`                | Enables VMs to retrieve certificates stored as secrets.                                                                         | bool   | false   |
| `enabled_for_disk_encryption`           | Enables Azure Disk Encryption to retrieve secrets and unwrap keys.                                                              | bool   | false   |
| `enabled_for_template_deployment`       | Enables Azure Resource Manager to retrieve secrets.                                                                             | bool   | false   |
| `keys`                                  | Map of keys to create in the Key Vault.                                                                                         | map(object) | {}      |
| `legacy_access_policies`                | Map of legacy access policies for Key Vault. Requires `legacy_access_policies_enabled` to be `true`.                            | map(object) | {}      |
| `legacy_access_policies_enabled`        | Enables legacy access policies, preventing use of Azure RBAC.                                                                   | bool   | false   |
| `lock`                                  | Lock level to apply to the Key Vault.                                                                                           | object | null    |
| `network_acls`                          | Network ACL configuration for the Key Vault firewall.                                                                           | object | null    |
| `private_endpoints`                     | Map of private endpoints to create on the Key Vault.                                                                            | map(object) | {}      |
| `private_endpoints_manage_dns_zone_group` | Manages private DNS zone groups if `true`; otherwise manage externally.                                                         | bool   | true    |
| `public_network_access_enabled`         | Enables public access to the Key Vault if `true`.                                                                               | bool   | true    |
| `purge_protection_enabled`              | Enables purge protection for the Key Vault. Cannot be disabled once enabled.                                                    | bool   | true    |
| `role_assignments`                      | Map of role assignments to create on the Key Vault.                                                                             | map(object) | {}      |
| `secrets`                               | Map of secrets to create on the Key Vault.                                                                                      | map(object) | {}      |
| `secrets_value`                         | Map of secret values. Must match keys in `secrets` map.                                                                         | map(string) | null    |
| `sku_name`                              | SKU for the Key Vault, either `standard` or `premium`.                                                                          | string | premium |
| `soft_delete_retention_days`            | Number of days to retain deleted items (7-90 days).                                                                             | number | null    |
| `tags`                                  | Tags to assign to the Key Vault.                                                                                                | map(string) | null    |
| `custom_resource_group_name`            | Name of an existing resource group to use. If provided, no new resource group will be created.                                  | string | null    |
| `custom_vnet_name`                      | Custom VNet name. If not set, the default naming convention will be used.                                                       | string | ""     |
| `custom_vnet_resource_group_name`       | Custom VNet resource group name. If not set, the default naming convention will be used.                                        | string | ""     |
| `wait_for_rbac_before_contact_operations` | Controls time to wait before performing contact operations based on RBAC roles.                                                 | number | 0       |

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

- **Description**: Map of private endpoints for the Keyvault.
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
  - **`resource_group_name`** (string, optional): Resource group for the private endpoint. Defaults to the keyvault resource group.
  - **`ip_configurations`** (map of objects, optional): IP configurations for the private endpoint.
    - **`name`** (string, required): Name of the IP configuration.
    - **`private_ip_address`** (string, required): Private IP address for the IP configuration.
- **Default**: `{}`

#### Example

```hcl
private_endpoints = {
  keyvault_private_endpoint = {
    name                          = "mykeyvaultPrivateEndpoint"
    subnet_resource_id            = "/subscriptions/your-subscription-id/resourceGroups/your-network-resource-group/providers/Microsoft.Network/virtualNetworks/your-vnet/subnets/your-subnet"
    private_dns_zone_group_name   = "keyvaultPrivateDNSZoneGroup"
    private_dns_zone_resource_ids = [
      "/subscriptions/your-subscription-id/resourceGroups/your-dns-resource-group/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net"
    ]
    role_assignments = {
      admin_role = {
        role_definition_id_or_name = "Contributor"
        principal_id               = "your-principal-id"
        description                = "Role assignment for keyvault private endpoint"
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

- **Description**: Role assignments to create on the keyvault.
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
  keyvault_admin = {
    role_definition_id_or_name = "keyvaultPush"
    principal_id               = "your-principal-id"
    description                = "keyvault push access for automation"
    skip_service_principal_aad_check = true
  }
}
```

### `keys`

**Description**:  
A map of keys to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys may be unknown at plan time.

Each key in the map supports the following fields:

#### Basic Key Configuration

- **`name`** – The name of the key. *(Required)*
- **`key_type`** – The type of the key. Possible values: `EC`, `RSA`. *(Required)*
- **`key_opts`** – A list of key options. Possible values:  
  `decrypt`, `encrypt`, `sign`, `unwrapKey`, `verify`, `wrapKey`.
- **`key_size`** – The size of the key. **Required for RSA** keys.
- **`curve`** – The curve of the key. **Required for EC** keys.  
  Possible values: `P-256`, `P-256K`, `P-384`, `P-521`.  
  If not specified, the API defaults to `P-256`.
- **`not_before_date`** – The "not before" date of the key.
- **`expiration_date`** – The expiration date of the key.
- **`tags`** – A mapping of tags to assign to the key.

#### Rotation Policy (`rotation_policy` block)

- **`automatic`** – The automatic rotation policy configuration.
  - **`time_after_creation`** – Duration after key creation before automatic rotation.
  - **`time_before_expiry`** – Duration before key expiry to automatically rotate.

- **`expire_after`** – Duration after which the key will expire.
- **`notify_before_expiry`** – Duration before key expiry when notification emails are sent.

#### Example

```hcl
keys = {
    sample_rsa_key = {
      name        = "rsa-key-sample"
      key_type    = "RSA"
      key_opts    = ["encrypt", "decrypt"]
      key_size    = 2048
      tags        = { environment = "dev" }

      role_assignments = {
        key_reader = {
          role_definition_id_or_name = "Key Vault Reader"
          principal_id               = "00000000-0000-0000-0000-000000000000"
        }
      }

      rotation_policy = {
        automatic = {
          time_after_creation = "P30D"
          time_before_expiry  = "P7D"
        }
        expire_after         = "P90D"
        notify_before_expiry = "P14D"
      }
    }

    sample_ec_key = {
      name        = "ec-key-sample"
      key_type    = "EC"
      key_opts    = ["sign", "verify"]
      curve       = "P-256"
      expiration_date = "2026-01-01T00:00:00Z"
    }
  }
```

### `legacy_access_policies`

**Description**:  
A map of legacy access policies to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys may be unknown at plan time.

> ⚠️ Requires `var.legacy_access_policies_enabled` to be `true`.

#### Attributes:

- **`object_id`** *(Required)*: The object ID of the principal to assign the access policy to.
- **`application_id`** *(Optional)*: The object ID of an Application in Azure Active Directory. Changing this forces a new resource to be created.
- **`certificate_permissions`** *(Optional)*: A list of certificate permissions.

  Possible values:
  - `Backup`, `Create`, `Delete`, `DeleteIssuers`, `Get`, `GetIssuers`, `Import`, `List`, `ListIssuers`, `ManageContacts`, `ManageIssuers`, `Purge`, `Recover`, `Restore`, `SetIssuers`, `Update`

- **`key_permissions`** *(Optional)*: A list of key permissions.

  Possible values:
  - `Backup`, `Create`, `Decrypt`, `Delete`, `Encrypt`, `Get`, `Import`, `List`, `Purge`, `Recover`, `Restore`, `Sign`, `UnwrapKey`, `Update`, `Verify`, `WrapKey`, `Release`, `Rotate`, `GetRotationPolicy`, `SetRotationPolicy`

- **`secret_permissions`** *(Optional)*: A list of secret permissions.

  Possible values:
  - `Backup`, `Delete`, `Get`, `List`, `Purge`, `Recover`, `Restore`, `Set`

- **`storage_permissions`** *(Optional)*: A list of storage permissions.

  Possible values:
  - `Backup`, `Delete`, `DeleteSAS`, `Get`, `GetSAS`, `List`, `ListSAS`, `Purge`, `Recover`, `RegenerateKey`, `Restore`, `Set`, `SetSAS`, `Update`

#### Role Assignments
- Supply role assignments using the same structure as for `var.role_assignments`.

**Default**: `{}`

#### Example

```hcl
legacy_access_policies = {
    user1 = {
      object_id               = "00000000-0000-0000-0000-000000000001"
      certificate_permissions = ["Get", "List", "Update"]
      key_permissions         = ["Get", "List", "Decrypt"]
      secret_permissions      = ["Get", "List"]
      storage_permissions     = ["Get", "List"]
    }

    user2 = {
      object_id      = "00000000-0000-0000-0000-000000000002"
      application_id = "11111111-1111-1111-1111-111111111111"
      key_permissions = ["Get", "Encrypt"]
    }
  }
```

### `secrets`

**Description**:  
A map of secrets to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys may be unknown at plan time.

#### Attributes:

- **`name`**: The name of the secret.
- **`content_type`**: The content type of the secret.
- **`tags`**: A mapping of tags to assign to the secret.
- **`not_before_date`**: The not before date of the secret.
- **`expiration_date`**: The expiration date of the secret.
#### Role Assignments

- Supply role assignments using the same structure as for `var.role_assignments`.
**Default**: `{}`

#### Example

```hcl
secrets = {
    secret1 = {
      name            = "example-secret-1"
      content_type    = "application/json"
      tags            = {"environment" = "prod"}
      not_before_date = "2025-01-01T00:00:00Z"
      expiration_date = "2025-12-31T23:59:59Z"
      role_assignments = {
        "role1" = {
          role_definition_id_or_name = "Contributor"
          principal_id               = "example-principal-id"
        }
      }
    }
    secret2 = {
      name            = "example-secret-2"
      content_type    = "text/plain"
      tags            = {"environment" = "dev"}
      not_before_date = "2025-06-01T00:00:00Z"
      expiration_date = "2025-11-30T23:59:59Z"
      role_assignments = {
        "role2" = {
          role_definition_id_or_name = "Reader"
          principal_id               = "another-principal-id"
        }
      }
    }
  }
```

## Outputs

| Name                     | Description                                                                 |
|--------------------------|-----------------------------------------------------------------------------|
| `key_vault_id`           | The resource ID of the Key Vault.                                          |
| `key_vault_name`         | The name of the Key Vault.                                                 |
| `key_vault_uri`          | The URI of the Key Vault.                                                  |
| `key_vault_primary_domain_name` | The primary domain name of the Key Vault.                            |
| `key_vault_resource_group` | The resource group in which the Key Vault was deployed.                  |

## Important Notes

- The `location` variable is restricted to `eastus` and `westus`.
- `lock` configuration only allows `kind` values of `"CanNotDelete"` and `"ReadOnly"`.
- This module relies on the Azure Verified Module for resource creation and management, ensuring robust configurations.

## References

- **Azure Verified Modules Documentation**: [Azure Verified Modules](https://azure.github.io/Azure-Verified-Modules/)
- **Azure Verified Resource Modules**: [Resource Modules Index](https://azure.github.io/Azure-Verified-Modules/indexes/terraform/tf-resource-modules/)
- **Azure Verified Module for Key Vault**:
  - Terraform Registry: [Azure AVM Key Vault](https://registry.terraform.io/modules/Azure/avm-res-keyvault-vault/azurerm/latest)
  - GitHub Repository: [GitHub - Azure AVN Key Vault](https://github.com/Azure/terraform-azurerm-avm-res-keyvault-vault)
- **Terraform Azure Provider Documentation**: [Terraform Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault)
