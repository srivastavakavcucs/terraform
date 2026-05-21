# Azure Virtual Network Terraform Module

This Terraform module creates an Azure Virtual Network (`azurerm_virtual_network`) with support for optional features such as DDoS protection, custom BGP communities, edge zones, and connection tracking flow timeouts.

For more detailed information on the `azurerm_virtual_network` resource, see the [official documentation on the Terraform Registry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network).

## Table of Contents

- [Azure Virtual Network Terraform Module](#azure-virtual-network-terraform-module)
  - [Table of Contents](#table-of-contents)
  - [Usage](#usage)
  - [Inputs](#inputs)
    - [Variable Descriptions](#variable-descriptions)
  - [Outputs](#outputs)
  - [Outputs Example](#outputs-example)
  - [Requirements](#requirements)
  - [Providers](#providers)
  - [Additional Documentation](#additional-documentation)

## Usage

```hcl
module "vnet" {
  source              = "../terraform/modules/azure_virtual_network"
  name                = "example-vnet"
  location            = "East US"
  resource_group_name = "example-rg"
  address_space       = ["10.0.0.0/16"]

  dns_servers         = ["8.8.8.8", "8.8.4.4"]

  enable_ddos_protection = true
  ddos_protection_plan_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.Network/ddosProtectionPlans/example-ddos-plan"

  bgp_community        = "12076:100"
  enable_vm_protection = false
  edge_zone            = "EdgeZone1"
  flow_timeout_in_minutes = 10

  common_tags = {
    environment = "production"
    team        = "network"
  }

  resource_tags = {
    project = "vnet-deployment"
  }
}
```

This example creates a virtual network with an address space of `10.0.0.0/16`, custom DNS servers, DDoS protection, a custom BGP community, and a flow timeout of 10 minutes for intra-VM connections.

## Inputs

| Name                      | Description                                                                                    | Type           | Default | Required |
| ------------------------- | ---------------------------------------------------------------------------------------------- | -------------- | ------- | -------- |
| `vnet_name`                    | The name of the virtual network. Must be between 2 and 80 characters.                          | `string`       | n/a     | yes      |
| `location`                | The Azure location to deploy the virtual network. Allowed values: `East US`, `West US`.        | `string`       | n/a     | yes      |
| `rg_name`     | The name of the resource group in which to create the virtual network.                         | `string`       | n/a     | yes      |
| `address_space`           | A list of address spaces in CIDR notation for the virtual network.                             | `list(string)` | n/a     | yes      |
| `dns_servers`             | A list of DNS server IP addresses for the virtual network.                                     | `list(string)` | `[]`    | no       |
| `enable_ddos_protection`  | Enable DDoS protection for the virtual network.                                                | `bool`         | `false` | no       |
| `ddos_protection_plan_id` | The ID of the DDoS Protection Plan. Required if DDoS protection is enabled.                    | `string`       | `null`  | no       |
| `bgp_community`           | The BGP community associated with the virtual network in the format `12076:<community-value>`. | `string`       | `null`  | no       |
| `enable_vm_protection`    | Enable VM protection for all subnets within the virtual network.                               | `bool`         | `false` | no       |
| `edge_zone`               | Specifies the Edge Zone where this virtual network should exist.                               | `string`       | `null`  | no       |
| `flow_timeout_in_minutes` | The flow timeout in minutes for intra-VM connections. Valid values: 4-30.                      | `number`       | `null`  | no       |
| `resource_tags`           | A map of tags specific to the ARO cluster resources. Optional.                                 | `map(string)`  | `{}`    | no       |
| `common_tags`             | A map of common tags for all resources. Must contain at least one entry.                       | `map(string)`  | n/a     | yes      |

### Variable Descriptions

- **`vnet_name`**: Specifies the name of the virtual network.
- **`location`**: Defines the Azure region for the virtual network. Only `East US` and `West US` are allowed.
- **`rg_name`**: The resource group in which the virtual network is created.
- **`address_space`**: Defines the address space(s) for the virtual network in CIDR notation.
- **`dns_servers`**: Optional list of DNS server IPs.
- **`enable_ddos_protection`**: A boolean to enable or disable Azure DDoS protection.
- **`ddos_protection_plan_id`**: Specifies the ID for a custom DDoS protection plan. Required if `enable_ddos_protection` is `true`.
- **`bgp_community`**: Optional BGP community in the format `12076:<community-value>`.
- **`enable_vm_protection`**: Boolean to enable VM protection across all subnets.
- **`edge_zone`**: Defines the Edge Zone for the virtual network.
- **`flow_timeout_in_minutes`**: Defines the timeout for connection tracking of intra-VM flows (4 to 30 minutes).
- **`resource_tags`**: Optional resource-specific tags, defaulting to an empty map.
- **`common_tags`**: A required set of common tags that cannot be empty.

## Outputs

| Name                            | Description                                               |
| ------------------------------- | --------------------------------------------------------- |
| `virtual_network_id`            | The ID of the created virtual network.                    |
| `virtual_network_name`          | The name of the created virtual network.                  |
| `virtual_network_address_space` | The address space of the created virtual network.         |
| `combined_tags`                 | The combined tags from `common_tags` and `resource_tags`. |

## Outputs Example

```hcl
output "vnet_id" {
  value = module.vnet.virtual_network_id
}

output "combined_tags" {
  value = module.vnet.combined_tags
}
```

## Requirements

- Terraform 1.9+
- AzureRM Provider 4.5+

## Providers

| Name    | Version |
| ------- | ------- |
| azurerm | >= 4.5  |

---

## Additional Documentation

For more information on the `azurerm_virtual_network` resource and its available options, please refer to the [official Terraform documentation on the AzureRM provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network).
