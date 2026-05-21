# Azure Static Route Table Terraform Module

This Terraform module deploys an **Azure Static Route Table**. It is designed to deploy the route table, routes, and associate them with subnets as required.

---

## Table of Contents

- [Azure Static Route Table Terraform Module](#azure-static-route-table-terraform-module)
  - [Table of Contents](#table-of-contents)
  - [Important Notes](#important-notes)
  - [Features](#features)
  - [Requirements](#requirements)
  - [Resources Used](#resources-used)
  - [Inputs](#inputs)
    - [Required Inputs](#required-inputs)
    - [Optional Inputs](#optional-inputs)
  - [Outputs](#outputs)
  - [Example Usage](#example-usage)
  - [Additional Documentation](#additional-documentation)

---

## Important Notes

- The Azure Verified Module (AVM) framework is not **GA (Generally Available)** yet. Hence, breaking changes may occur as development progresses.
- Despite this, the module can still be used in all environments, including dev, test, and production.
- Users are encouraged to treat the module as any other Infrastructure-as-Code (IaC) module and provide feedback via GitHub issues or feature requests.
- Always refer to the **release notes** for updates or considerations before upgrading.

---

## Features

- Deploys an Azure Route Table.
- Optionally deploys:
  - Routes.
  - Associations with subnets.
- Supports custom configurations for BGP route propagation and resource locks.
- For more details:
  - [Azure Virtual Network Traffic Routing](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-traffic-routing)
  - [Azure Virtual Network Custom Routes](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-udr-overview)

---

## Requirements

| Requirement      | Version       |
|-------------------|---------------|
| **Terraform**    | >= 1.5.0      |
| **Provider**     | `azurerm` (>= 3.112.0, < 5.0) |
| **Other Modules**| `modtm` (~> 0.3), `random` (>= 3.5.0, < 4.0) |

---

## Resources Used

- **azurerm_management_lock.this**
- **azurerm_role_assignment.this**
- **azurerm_route.this**
- **azurerm_route_table.this**
- **azurerm_subnet_route_table_association.this**
- **modtm_telemetry.telemetry**
- **random_uuid.telemetry**
- **azurerm_client_config.telemetry**
- **modtm_module_source.telemetry**

---

## Inputs

### Required Inputs

| Name                   | Description                                                                                       | Type   |
|------------------------|---------------------------------------------------------------------------------------------------|--------|
| `location`             | Specifies the Azure region for the resource. Changing this forces a new resource to be created.  | `string` |
| `name`                 | The name of the Route Table. Changing this forces a new resource to be created.                  | `string` |
| `resource_group_name`  | The name of the resource group in which to create the resource. Changing this forces recreation.  | `string` |

### Optional Inputs

| Name                       | Description                                                                                           | Type | Default |
|----------------------------|-------------------------------------------------------------------------------------------------------|------|---------|
| `bgp_route_propagation_enabled` | Boolean flag for BGP route propagation.                                                          | `bool` | `true`    |
| `enable_telemetry`         | Enables/disables telemetry. For details, see [Telemetry Info](https://aka.ms/avm/telemetryinfo).     | `bool` | `true`    |
| `lock`                     | Configuration for resource lock. Includes `kind` and optional `name`.                                | `object` | `null`   |
| `role_assignments`         | Map of role assignments with details like role definition ID, principal ID, and optional description. | `map(object)` | `{}` |
| `routes`                   | Map of routes with properties like `name`, `address_prefix`, `next_hop_type`, and optional IP address.| `map(object)` | `{}` |
| `subnet_resource_ids`      | Map of subnet IDs to associate with the Route Table.                                                 | `map(string)` | `{}` |
| `tags`                     | Tags for the resource.                                                                               | `map(string)` | `null` |

---

## Outputs

| Name          | Description                     |
|---------------|---------------------------------|
| `name`        | The Route Table name.          |
| `resource`    | Full details of the Route Table.|
| `resource_id` | The ID of the Route Table.     |
| `routes`      | Full details of the routes.    |

---

## Example Usage

```hcl
module "route_table" {
  source              = "github.com/Azure/terraform-azurerm-avm-res-network-routetable"

  location            = "eastus"
  resource_group_name = "rg-example"
  name                = "example-route-table"

  bgp_route_propagation_enabled = true
  enable_telemetry              = false
  tags = {
    environment = "prod"
  }

  routes = {
    route1 = {
      name           = "route-to-vnet"
      address_prefix = "10.1.0.0/16"
      next_hop_type  = "VirtualNetworkGateway"
    }
  }

  subnet_resource_ids = {
    subnet1 = "/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Network/virtualNetworks/{vnetName}/subnets/{subnetName}"
  }
}
```

## Additional Documentation

- [Azure Route Tables Documentation](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-udr-overview)
- [Azure Virtual Network Traffic Routing](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-traffic-routing)
- [Telemetry Information](https://aka.ms/avm/telemetryinfo)

---
