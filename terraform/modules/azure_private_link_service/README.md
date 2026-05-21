# Azure Private Link Service Terraform Module

This Terraform module manages an **Azure Private Link Service**, allowing secure and private access to Azure services and customer-hosted applications.

---

## Table of Contents

- [Azure Private Link Service Terraform Module](#azure-private-link-service-terraform-module)
  - [Table of Contents](#table-of-contents)
  - [Features](#features)
  - [Usage](#usage)
  - [Inputs](#inputs)
  - [Outputs](#outputs)
  - [Argument Reference](#argument-reference)
    - [Required Arguments](#required-arguments)
    - [Optional Arguments](#optional-arguments)
  - [NAT IP Configuration Block](#nat-ip-configuration-block)
  - [Attributes Reference](#attributes-reference)
  - [Timeouts](#timeouts)
  - [Notes](#notes)

---

## Features

- **Private Connectivity**: Provides a secure connection between clients and the private endpoint.
- **Load Balancing**: Integrates with a standard load balancer for traffic routing.
- **Auto-Approval and Visibility**: Allows configuration of subscription-based access control.

---

## Usage

Below is an example configuration for setting up a Private Link Service:

```hcl
# Resource Group
resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "West Europe"
}

# Virtual Network
resource "azurerm_virtual_network" "example" {
  name                = "example-network"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.5.0.0/16"]
}

# Subnet with Private Link Policies Enabled
resource "azurerm_subnet" "example" {
  name                                          = "example-subnet"
  resource_group_name                           = azurerm_resource_group.example.name
  virtual_network_name                          = azurerm_virtual_network.example.name
  address_prefixes                              = ["10.5.1.0/24"]
  enforce_private_link_service_network_policies = true
}

# Public IP
resource "azurerm_public_ip" "example" {
  name                = "example-api"
  sku                 = "Standard"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Static"
}

# Load Balancer
resource "azurerm_lb" "example" {
  name                = "example-lb"
  sku                 = "Standard"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  frontend_ip_configuration {
    name                 = azurerm_public_ip.example.name
    public_ip_address_id = azurerm_public_ip.example.id
  }
}

# Private Link Service
resource "azurerm_private_link_service" "example" {
  name                = "example-privatelink"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  auto_approval_subscription_ids              = ["00000000-0000-0000-0000-000000000000"]
  visibility_subscription_ids                 = ["00000000-0000-0000-0000-000000000000"]
  load_balancer_frontend_ip_configuration_ids = [azurerm_lb.example.frontend_ip_configuration[0].id]

  nat_ip_configuration {
    name                       = "primary"
    private_ip_address         = "10.5.1.17"
    private_ip_address_version = "IPv4"
    subnet_id                  = azurerm_subnet.example.id
    primary                    = true
  }

  nat_ip_configuration {
    name                       = "secondary"
    private_ip_address         = "10.5.1.18"
    private_ip_address_version = "IPv4"
    subnet_id                  = azurerm_subnet.example.id
    primary                    = false
  }
}

```

## Inputs

| Name                                    | Description                                                             | Type     | Default | Required |
|-----------------------------------------|-------------------------------------------------------------------------|----------|---------|----------|
| `name`                                  | Specifies the name of the Private Link Service.                         | `string` | n/a     | Yes      |
| `resource_group_name`                   | Name of the Resource Group where the Private Link Service should exist. | `string` | n/a     | Yes      |
| `location`                              | Azure location where the Private Link Service is deployed.              | `string` | n/a     | Yes      |
| `load_balancer_frontend_ip_configuration_ids` | List of Frontend IP Configuration IDs for routing traffic.              | `list`   | n/a     | Yes      |
| `auto_approval_subscription_ids`        | List of subscription IDs auto-approved for private endpoint connections.| `list`   | `[]`    | No       |
| `visibility_subscription_ids`           | List of subscription IDs allowed to see the Private Link Service.       | `list`   | `[]`    | No       |
| `nat_ip_configuration`                  | NAT IP configuration blocks for the service.                            | `list`   | n/a     | Yes      |
| `enable_proxy_protocol`                 | Should the Private Link Service support the Proxy Protocol?             | `bool`   | `false` | No       |
| `tags`                                  | A mapping of tags to assign to the resource.                            | `map`    | `{}`    | No       |

---

## Outputs

| Name    | Description                                  |
|---------|----------------------------------------------|
| `alias` | Globally unique DNS alias for the service.   |
| `id`    | The ID of the Private Link Service resource. |

---

## Argument Reference

### Required Arguments

- `name`: Specifies the name of the Private Link Service.
- `resource_group_name`: The name of the Resource Group where the Private Link Service should exist.
- `location`: Specifies the supported Azure location where the resource exists.
- `nat_ip_configuration`: One or more (up to 8) NAT IP configurations.
- `load_balancer_frontend_ip_configuration_ids`: A list of frontend IP configuration IDs from a Standard Load Balancer.

### Optional Arguments

- `auto_approval_subscription_ids`: A list of subscription UUIDs for automatic approval.
- `visibility_subscription_ids`: A list of subscription UUIDs that can see the Private Link Service.
- `enable_proxy_protocol`: Indicates if the Proxy Protocol is enabled.
- `fqdns`: List of FQDNs for the Private Link Service.
- `tags`: A mapping of tags for the resource.

---

## NAT IP Configuration Block

- `name`: Specifies the name of the NAT IP configuration.
- `subnet_id`: Specifies the subnet ID for the Private Link Service.
- `primary`: Indicates if this is the primary IP configuration.
- `private_ip_address`: Specifies a private static IP address.
- `private_ip_address_version`: Specifies the IP protocol version (default: IPv4).

---

## Attributes Reference

- `alias`: A globally unique DNS name for the Private Link Service.

---

## Timeouts

| Action  | Default Timeout |
|---------|-----------------|
| `create`| 60 minutes      |
| `update`| 60 minutes      |
| `read`  | 5 minutes       |
| `delete`| 60 minutes      |

---

## Notes

1. Ensure the `enforce_private_link_service_network_policies` attribute is set to `true` for the subnet.
2. For `nat_ip_configuration`, you can configure up to 8 NAT IPs, with at least one being `primary`.
