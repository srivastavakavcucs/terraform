# Azure App Configuration & Private Endpoint Terraform Module

This Terraform module deploys an **Azure App Configuration** along with necessary configurations and access control for **Azure Key Vault**, **User Assigned Identity**, and **Private Endpoints** for secure access.

---

## Table of Contents

- [Azure App Configuration \& Private Endpoint Terraform Module](#azure-app-configuration--private-endpoint-terraform-module)
  - [Table of Contents](#table-of-contents)
  - [Usage](#usage)
    - [Basic Usage Example](#basic-usage-example)
  - [Inputs](#inputs)
    - [Required Variables](#required-variables)
    - [Optional Variables](#optional-variables)
  - [Outputs](#outputs)
  - [Examples](#examples)
    - [Basic Example](#basic-example)
  - [Additional Documentation](#additional-documentation)

---

## Usage

To use this module, define the required variables in your Terraform configuration.

### Basic Usage Example

```hcl
module "app_config" {
  source = "./modules/app-config"

  # General Configuration
  app_name                  = "example-app"
  environment               = "dev"
  environment_number_suffix = "001"
  region                    = "eastus"

  # Key Vault and Identity Information
  tenant_id                 = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  key_type                 = "RSA"
  key_size                 = 2048
  key_opts                 = ["encrypt", "decrypt"]
  
  # App Configuration Settings
  sku_name                 = "standard"
  local_auth_enabled       = false
  public_network_access    = "Disabled"
  purge_protection_enabled = false
  soft_delete_retention_days = 7

  # Private Endpoint Configuration (Optional)
  private_endpoints = {
    "example_pe" = {
      private_endpoint_subnet_name_segment = "appconfig-pe-subnet"
      private_dns_zones = [
        {
          name                = "example-dns-zone"
          resource_group_name = "example-rg"
        }
      ]
    }
  }

  # Tags
  common_tags = {
    Business_Unit        = "Finance"
    Workload             = "Application"
    Business_Criticality = "Gold"
    Owner                = "Digital Team"
    Operations_Team      = "Cloud Engineering"
    Cost_Center          = "701"
  }

  resource_tags = {
    Department = "Engineering"
  }
}
```

---

## Inputs

### Required Variables

| Variable Name                            | Description                                                      | Type          | Required |
| ---------------------------------------- | ---------------------------------------------------------------- | ------------- | -------- |
| `tenant_id`                              | The Azure tenant ID used for authenticating requests to Key Vault | `string`      | Yes      |
| `app_name`                               | Name of the application being deployed                          | `string`      | Yes      |
| `environment`                            | Target environment abbreviation for naming                      | `string`      | Yes      |
| `environment_number_suffix`              | Environment number suffix for naming                            | `string`      | Yes      |
| `region`                                 | Azure region for resource deployment (e.g., `eastus`, `westus`)  | `string`      | Yes      |
| `key_type`                               | Key type for the Azure Key Vault (e.g., `RSA`, `EC`)            | `string`      | Yes      |
| `key_opts`                               | List of key operations for Key Vault (e.g., `encrypt`, `decrypt`) | `list(string)` | Yes      |
| `sku_name`                               | SKU name for the Azure App Configuration (`standard`, `premium`) | `string`      | Yes      |

### Optional Variables

| Variable Name                     | Description                                     | Type          | Default             |
| ---------------------------------- | ----------------------------------------------- | ------------- | ------------------- |
| `key_size`                        | Size of the RSA key (for `RSA` or `RSA-HSM`)    | `number`      | `2048`              |
| `local_auth_enabled`              | Enable local authentication on App Configuration | `bool`        | `false`             |
| `public_network_access`           | Public network access for the App Configuration | `string`      | `"Disabled"`        |
| `purge_protection_enabled`        | Enable purge protection for App Configuration   | `bool`        | `false`             |
| `soft_delete_retention_days`      | Retention days for soft deleted items           | `number`      | `7`                 |
| `private_endpoints`               | Private endpoint configurations for secure access | `map`        | `{}`                |

---

## Outputs

| Output Name            | Description                                  | Example                                      |
| ---------------------- | -------------------------------------------- | -------------------------------------------- |
| `app_configuration_id` | The ID of the Azure App Configuration        | `"/subscriptions/.../resourceGroups/.../providers/Microsoft.AppConfiguration/configurationStores/example-app-config"` |
| `key_vault_key_id`     | The ID of the Azure Key Vault Key            | `"/subscriptions/.../resourceGroups/.../providers/Microsoft.KeyVault/vaults/example-keyvault/keys/example-key"` |
| `private_endpoint_id`  | The ID of the Private Endpoint configuration | `"/subscriptions/.../resourceGroups/.../providers/Microsoft.Network/privateEndpoints/example-pe"` |

---

## Examples

### Basic Example

```hcl
module "app_config" {
  source = "./modules/app-config"

  app_name                  = "example-app"
  environment               = "dev"
  environment_number_suffix = "001"
  region                    = "eastus"
  tenant_id                 = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  key_type                 = "RSA"
  key_size                 = 2048
  key_opts                 = ["encrypt", "decrypt"]

  sku_name                 = "standard"
  local_auth_enabled       = false
  public_network_access    = "Disabled"
  purge_protection_enabled = false
  soft_delete_retention_days = 7

  private_endpoints = {
    "example_pe" = {
      private_endpoint_subnet_name_segment = "appconfig-pe-subnet"
      private_dns_zones = [
        {
          name                = "example-dns-zone"
          resource_group_name = "example-rg"
        }
      ]
    }
  }

  common_tags = {
    Business_Unit        = "Finance"
    Workload             = "Application"
    Business_Criticality = "Gold"
    Owner                = "Digital Team"
    Operations_Team      = "Cloud Engineering"
    Cost_Center          = "701"
  }

  resource_tags = {
    Department = "Engineering"
  }
}
```

---

## Additional Documentation

- [Azure App Configuration Documentation](https://learn.microsoft.com/en-us/azure/azure-app-configuration/)
- [Terraform AzureRM Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_configuration)
- [Azure Key Vault Documentation](https://learn.microsoft.com/en-us/azure/key-vault/)
- [Private Endpoint Documentation](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview)
