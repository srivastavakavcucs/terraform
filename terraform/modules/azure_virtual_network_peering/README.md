Here is the updated `ReadMe.md` file with the corrected usage example based on your provided details:

---

# Terraform Azure VNet Peering Module

This Terraform module manages **VNet Peering** between a **local** and **remote** Azure Virtual Network (VNet) across different subscriptions. It supports both **local-to-remote peering** and **reverse peering**, with optional features such as enabling/disabling forwarded traffic, gateway transit, virtual network access, and subnet peering.

---

## Table of Contents

- [Terraform Azure VNet Peering Module](#terraform-azure-vnet-peering-module)
  - [Table of Contents](#table-of-contents)
  - [Features](#features)
  - [Requirements](#requirements)
  - [Usage](#usage)
    - [Example: Basic VNet Peering Across Different Subscriptions](#example-basic-vnet-peering-across-different-subscriptions)
  - [Inputs](#inputs)
    - [Required Inputs](#required-inputs)
    - [Optional Inputs](#optional-inputs)
  - [Outputs](#outputs)
  - [Additional Documentation](#additional-documentation)

---

## Features

- **Peering between Azure VNets**: Create peering relationships between existing local and remote VNets.
- **Cross-Subscription Peering**: Supports peering between VNets that exist in different Azure subscriptions.
- **Reverse Peering Support**: Optionally create reverse peering from the remote VNet to the local VNet.
- **Gateway and Traffic Controls**: Fine-grained control over forwarded traffic, gateway transit, and virtual network access between peered VNets.
- **Dynamic Subnet Peering**: Supports local and remote subnet peering with optional configuration.

---

## Requirements

- **Terraform**: `>= 1.0.0`
- **Providers**:
  - AzureRM Provider (`>= 4.5.0`)

---

## Usage

### Example: Basic VNet Peering Across Different Subscriptions

In this example, we configure VNet peering between two VNets that reside in **different Azure subscriptions**. This example defines the necessary providers for each subscription and sets up the peering with all required variables.

```hcl
module "vnet_peering" {
  source = "../path-to-vnet-peering-module/azure_virtual_network_peering/"

  # Variables for the local VNet
  peering_name_prefix          = "vp"
  virtual_network_name         = "local-vnet"
  resource_group_name          = "local-rg"

  # Variables for the remote VNet
  remote_virtual_network_name  = "remote-vnet"
  remote_resource_group_name   = "remote-rg"

  # Azure subscription IDs for both local and remote VNets
  local_subscription_id        = "8897145f-1e24-42a2-9a1d-c1b7af13fd2c"
  remote_subscription_id       = "0c6c6ca3-664e-47c2-a484-b25bd6075fd4"

  # Peering behavior variables
  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
  allow_gateway_transit        = false
  use_remote_gateways          = false
}
```

---

## Inputs

### Required Inputs

| Name                          | Type   | Description                                                                 |
| ----------------------------- | ------ | --------------------------------------------------------------------------- |
| `peering_name`                | string | The name of the virtual network peering.                                    |
| `virtual_network_name`        | string | The name of the local virtual network.                                      |
| `resource_group_name`         | string | The name of the resource group where the local virtual network is located.  |
| `remote_virtual_network_name` | string | The name of the remote virtual network.                                     |
| `remote_resource_group_name`  | string | The name of the resource group where the remote virtual network is located. |
| `local_subscription_id`       | string | The subscription ID for the local Azure account.                            |
| `remote_subscription_id`      | string | The subscription ID for the remote Azure account.                           |

### Optional Inputs

| Name                           | Type | Default | Description                                                                                   |
| ------------------------------ | ---- | ------- | --------------------------------------------------------------------------------------------- |
| `allow_virtual_network_access` | bool | `true`  | Controls if traffic from the local virtual network can reach the remote virtual network.      |
| `allow_forwarded_traffic`      | bool | `false` | Controls if forwarded traffic from VMs in the remote virtual network is allowed.              |
| `allow_gateway_transit`        | bool | `false` | Controls if gateway links can be used in the remote virtual network’s link to the local VNet. |
| `use_remote_gateways`          | bool | `false` | Controls if remote gateways can be used on the local virtual network.                         |
| `enable_reverse_peering`       | bool | `false` | Enables reverse peering from the remote VNet back to the local VNet.                          |

---

## Outputs

| Name                     | Description                                                                 |
| ------------------------ | --------------------------------------------------------------------------- |
| `local_vnet_peering_id`  | The ID of the VNet peering created between the local and remote VNets.      |
| `remote_vnet_peering_id` | The ID of the reverse VNet peering created (if reverse peering is enabled). |

---

## Additional Documentation

For more information on the azurerm_virtual_network_peering resource and its available options, please refer to the [official Terraform documentation on the AzureRM provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering).

---

This updated `ReadMe.md` file includes the correct usage example and all required variables and options based on your provided Terraform code. Let me know if further modifications are needed!
