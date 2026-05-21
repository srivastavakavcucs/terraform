# Private DNS Zone Virtual Network Link Module

This Terraform module provisions an Azure Private DNS Zone Virtual Network Link, enabling a Virtual Network to resolve DNS records in a Private DNS Zone. This module allows the DNS Zone and the Virtual Network to reside in different Azure subscriptions if required.

## Table of Contents

- [Private DNS Zone Virtual Network Link Module](#private-dns-zone-virtual-network-link-module)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Usage](#usage)
  - [Parameters](#parameters)
    - [Variable Validations](#variable-validations)
  - [Outputs](#outputs)
  - [Examples](#examples)
    - [Basic Example](#basic-example)
    - [Cross-Subscription Example](#cross-subscription-example)
  - [Additional References](#additional-references)

---

## Overview

This module provisions an Azure Private DNS Zone Virtual Network Link using the [azurerm_private_dns_zone_virtual_network_link](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) resource. It supports linking a Virtual Network to a Private DNS Zone, with options for enabling auto-registration of virtual machine records and tagging resources.

## Usage

To use this module, include the following in your Terraform configuration:

```hcl
module "dns_zone_vnet_link" {
  source = "./path/to/azurerm_private_dns_zone_virtual_network_link_module"
  name = "example-dns-link"
  private_dns_zone_name = "example-zone"
  resource_group_name = "example-rg"
  virtual_network_name = "example-vnet"
  virtual_network_resource_group_name = "vnet-rg"
  private_dns_zone_subscription_id = "00000000-0000-0000-0000-000000000000"
  registration_enabled = true
  tags = {
    environment = "production"
    project     = "example"
  }
  common_tags = {
    owner = "admin"
    team  = "devops"
  }
}
```

## Parameters

The following table provides details about the parameters supported by the module.

| Name                                  | Type          | Description                                                                                         | Required | Default |
| ------------------------------------- | ------------- | --------------------------------------------------------------------------------------------------- | -------- | ------- |
| `name`                                | `string`      | The name of the Private DNS Zone Virtual Network Link.                                              | Yes      |         |
| `private_dns_zone_name`               | `string`      | The name of the Private DNS zone (without a terminating dot).                                       | Yes      |         |
| `resource_group_name`                 | `string`      | Specifies the resource group where the Private DNS Zone exists.                                     | Yes      |         |
| `virtual_network_name`                | `string`      | The name of the Virtual Network that should be linked to the DNS Zone.                              | Yes      |         |
| `virtual_network_resource_group_name` | `string`      | Specifies the resource group where the Virtual Network exists.                                      | Yes      |         |
| `private_dns_zone_subscription_id`    | `string`      | The subscription ID for the Azure subscription where the Private DNS Zone is deployed.              | Yes      |         |
| `registration_enabled`                | `bool`        | Enables auto-registration of virtual machine records in the Private DNS zone. Defaults to `true`.   | No       | `true`  |
| `tags`                                | `map(string)` | A mapping of tags to assign to the resource.                                                        | No       | `{}`    |
| `common_tags`                         | `map(string)` | A mapping of common tags to apply to all resources. This field is required and should not be empty. | Yes      |         |

### Variable Validations

- **name**: Cannot be empty.
- **private_dns_zone_name**: Cannot be empty.
- **resource_group_name**: Cannot be empty.
- **virtual_network_name**: Must be between 2 and 80 characters.
- **virtual_network_resource_group_name**: Cannot be empty.
- **private_dns_zone_subscription_id**: Must be a valid 32-character Azure Subscription ID in the format `XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX`.
- **common_tags**: Must contain at least one key-value pair.

## Outputs

| Name                                       | Description                                          |
| ------------------------------------------ | ---------------------------------------------------- |
| `private_dns_zone_virtual_network_link_id` | The ID of the Private DNS Zone Virtual Network Link. |

## Examples

### Basic Example

The following example demonstrates how to use this module to create a DNS Zone Virtual Network Link in the same subscription:

```hcl
module "dns_zone_vnet_link" {
  source                          = "./path/to/azurerm_private_dns_zone_virtual_network_link_module"
  name                            = "example-dns-link"
  private_dns_zone_name           = "example-zone"
  resource_group_name             = "example-rg"
  virtual_network_name            = "example-vnet"
  virtual_network_resource_group_name = "example-vnet-rg"
  private_dns_zone_subscription_id = "00000000-0000-0000-0000-000000000000"
  registration_enabled            = true
  tags = {
    environment = "production"
    team        = "devops"
  }
  common_tags = {
    cost_center = "1234"
  }
}
```

### Cross-Subscription Example

In scenarios where the Virtual Network and DNS Zone are in different subscriptions, specify the `private_dns_zone_subscription_id`:

```hcl
module "dns_zone_vnet_link" {
  source                          = "./path/to/azurerm_private_dns_zone_virtual_network_link_module"
  name                            = "example-cross-subscription-link"
  private_dns_zone_name           = "cross-zone"
  resource_group_name             = "cross-rg"
  virtual_network_name            = "cross-vnet"
  virtual_network_resource_group_name = "cross-vnet-rg"
  private_dns_zone_subscription_id = "11111111-2222-3333-4444-555555555555"
  registration_enabled            = false
  tags = {
    project = "cross-subscription"
  }
  common_tags = {
    owner = "network-team"
  }
}
```

Here’s the updated **Additional References** section with the additional links for further information:

---

## Additional References

For more details on the Azure Private DNS Zone Virtual Network Link and related concepts, refer to the following resources:

- [AzureRM Private DNS Zone Virtual Network Link Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link): Official documentation for the Terraform resource `azurerm_private_dns_zone_virtual_network_link`, covering supported arguments, attributes, and usage.

- [Azure Private DNS: Link the Virtual Network](https://learn.microsoft.com/en-us/azure/dns/private-dns-getstarted-portal#link-the-virtual-network): Microsoft’s guide on how to link a Virtual Network to a Private DNS Zone through the Azure portal.

- [Azure Private DNS Virtual Network Links](https://learn.microsoft.com/en-us/azure/dns/private-dns-virtual-network-links): Detailed documentation on Virtual Network links in Azure Private DNS, covering functionality, configuration, and best practices.

---
