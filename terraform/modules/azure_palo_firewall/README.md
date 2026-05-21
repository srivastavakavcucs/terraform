
# Palo Alto Firewall Terraform Module

This Terraform module creates a Palo Alto VM-Series Firewall on Azure. It deploys a Linux virtual machine with the Palo Alto Networks VM-Series image along with the required network interfaces (management, untrust, and trust), public IP for management access, and supports both availability sets and availability zones for high availability.

## Recent Updates (November 2025)

- **Updated NIC Naming**: Network interfaces now use descriptive suffixes:
  - Management: `nic-{app_name}-{env}-{suffix}-eth0-mgmt`
  - Untrust: `nic-{app_name}-{env}-{suffix}-eth1-untrust`  
  - Trust: `nic-{app_name}-{env}-{suffix}-eth2-trust`
- **Availability Zones Support**: Added support for Azure Availability Zones as the default high availability option
- **VM Size Update**: Changed default VM size to `Standard_D4s_v5` (4 vCPUs, 16 GB memory)
- **Enhanced Flexibility**: Supports both availability sets and availability zones (mutually exclusive)

## Table of Contents


- [Palo Alto Firewall Terraform Module](#palo-alto-firewall-terraform-module)
  - [Table of Contents](#table-of-contents)
  - [Requirements](#requirements)
  - [Usage](#usage)
  - [Module Features](#module-features)
  - [Inputs](#inputs)
    - [Required Inputs](#required-inputs)
    - [Optional Inputs](#optional-inputs)
  - [Outputs](#outputs)
  - [Example Configurations](#example-configurations)
    - [Basic Setup](#basic-setup)
    - [Advanced Configuration](#advanced-configuration)
  - [Important Notes](#important-notes)
  - [References](#references)


## Requirements

- **Terraform**: `>= 1.9.2`
- **Provider**:
  - `azurerm`: `>= 4.0`

## Usage

### Basic Palo Alto Firewall Deployment

```hcl
module "palo_alto_firewall" {
  source = "path/to/modules/azure_palo_firewall"

  # Required inputs
  region                     = "eastus"
  app_name                   = "security"
  environment                = "dev"
  environment_number_suffix  = "001"
  
  # Network configuration
  custom_vnet_name                      = "vnet-security-dev-eastus-001"
  custom_vnet_resource_group_name       = "rg-network-security-dev-eastus-001"
  management_subnet_name                = "snet-pamgmt-10.182.6.128_27"
  untrust_subnet_name                   = "snet-untrust-10.182.6.64_27"
  trust_subnet_name                     = "snet-trust-10.182.6.96_27"
  
  # VM authentication
  admin_username             = var.admin_username
  admin_ssh_keys = [
    {
      username   = "infosec"
      public_key = "ssh-rsa 
      ---- public_key -----
    }
  ]

  # Required tags
  common_tags = {
    Environment = "dev"
    Owner       = "Network Security Team"
  }
}
```

## Module Features

This module deploys a complete Palo Alto VM-Series firewall with the following components:
- Linux Virtual Machine with Palo Alto VM-Series image (vmseries-flex)
- Three network interfaces with enhanced naming:
  - **Management** (eth0): `nic-{app_name}-{env}-{suffix}-eth0-mgmt`
  - **Untrust** (eth1): `nic-{app_name}-{env}-{suffix}-eth1-untrust`
  - **Trust** (eth2): `nic-{app_name}-{env}-{suffix}-eth2-trust`
- Public IP address for management access with configurable SKU and allocation method
- **High Availability Options**:
  - **Availability Zones** (default): Deploy VMs in specific Azure availability zones
  - **Availability Sets** (legacy): Traditional availability set deployment
- Optional Network Security Group associations for enhanced security
- Standardized naming conventions using IaC base module
- Comprehensive input validation and secure defaults
- Support for static or dynamic IP allocation on all interfaces
- Bootstrap configuration support via custom_data
- Configurable VM sizing with validation for supported SKUs (default: Standard_D4s_v5)


## Inputs

### Required Inputs

| Name                          | Description                                           | Type   | Example Values                        |
| ----------------------------- | ----------------------------------------------------- | ------ | ------------------------------------- |
| `region`                      | Azure region for deployment (eastus or westus)       | string | `"eastus"`, `"westus"`                |
| `app_name`                    | Name of the VyStar application that will be deployed | string | `"security"`, `"firewall"`            |
| `environment`                 | Target environment abbreviation for naming            | string | `"dev"`, `"test"`, `"prod"`           |
| `environment_number_suffix`   | Environment number suffix for naming                  | string | `"001"`, `"002"`                      |
| `management_subnet_name`      | Name of the management subnet for Palo Alto firewall | string | `"snet-pamgmt-10.182.6.128_27"`      |
| `untrust_subnet_name`         | Name of the untrust (external) subnet                | string | `"snet-untrust-10.182.6.64_27"`      |
| `trust_subnet_name`           | Name of the trust (internal) subnet                  | string | `"snet-trust-10.182.6.96_27"`        |
| `admin_ssh_keys`              | List of SSH public keys for VM authentication        | list(object) | See SSH Key Configuration section |
| `common_tags`                 | Default common tags for all resources                 | map(string) | `{"Environment": "prod", "Owner": "IT"}` |

### Optional Inputs

| Name                                         | Description                                                    | Type        | Default                 |
| -------------------------------------------- | -------------------------------------------------------------- | ----------- | ----------------------- |
| **Network Configuration**                    |                                                                |             |                         |
| `custom_vnet_name`                           | Custom VNet name (uses default naming if empty)               | string      | `""`                    |
| `custom_vnet_resource_group_name`            | Custom VNet resource group name                                | string      | `""`                    |
| `network_security_group_name`                | NSG name to associate with firewall interfaces                | string      | `null`                  |
| `network_security_group_resource_group_name` | Resource group name where NSG is located                       | string      | `null`                  |
| **VM Configuration**                         |                                                                |             |                         |
| `vm_size`                                    | Size of the Palo Alto VM (validated against supported SKUs)   | string      | `"Standard_D4s_v5"`     |
| `admin_username`                             | Admin username for the VM                                      | string      | `"infosec"`             |
| `admin_ssh_keys`                             | List of SSH public keys for VM authentication                 | list(object) | `[]`                    |
| `disable_password_authentication`            | Disable password authentication (enabled for SSH keys)        | bool        | `true`                  |
| `computer_name`                              | Computer name for the VM (1-15 chars)                         | string      | `null` (auto-generated) |
| **High Availability Configuration**          |                                                                |             |                         |
| `enable_availability_set`                    | Enable availability set for high availability                  | bool        | `false`                 |
| `availability_set_fault_domain_count`        | Number of fault domains for availability set (1-3)            | number      | `2`                     |
| `enable_availability_zones`                  | Enable availability zones (recommended over availability sets) | bool        | `true`                  |
| `availability_zone`                          | Availability zone for the VM (1, 2, or 3)                     | string      | `"1"`                   |
| **VM Agent and Extension Configuration**     |                                                                |             |                         |
| `provision_vm_agent`                         | Should the Azure VM Agent be provisioned                      | bool        | `true`                  |
| `allow_extension_operations`                 | Should Extension Operations be allowed                         | bool        | `true`                  |
| `patch_mode`                                 | Mode of in-guest patching                                      | string      | `"ImageDefault"`        |
| `patch_assessment_mode`                      | Mode of VM Guest Patching                                      | string      | `"ImageDefault"`        |
| `extensions_time_budget`                     | Duration allocated for all extensions to start                 | string      | `"PT1H30M"`             |
| **Public IP Configuration**              |                                                                |             |                         |
| `public_ip_allocation_method`             | Public IP allocation method (Static/Dynamic)                  | string      | `"Static"`              |
| `public_ip_sku`                           | Public IP SKU (Basic/Standard)                                 | string      | `"Standard"`            |
| `public_ip_sku_tier`                      | Public IP SKU tier (Regional/Global)                          | string      | `"Regional"`            |
| `public_ip_idle_timeout`                  | TCP idle connection timeout (4-30 minutes)                    | number      | `4`                     |
| **Palo Alto Image Configuration**         |                                                                |             |                         |
| `vm_image_publisher`                      | VM image publisher                                             | string      | `"paloaltonetworks"`    |
| `vm_image_offer`                          | VM image offer                                                 | string      | `"vmseries-flex"`       |
| `vm_image_sku`                            | VM image SKU                                                   | string      | `"byol"`                |
| `vm_image_version`                        | VM image version                                               | string      | `"11.1.407"`            |
| **Disk Configuration**                    |                                                                |             |                         |
| `os_disk_caching`                         | OS disk caching mode                                           | string      | `"ReadWrite"`           |
| `os_disk_storage_account_type`            | OS disk storage account type                                   | string      | `"Standard_LRS"`        |
| `os_disk_size_gb`                         | OS disk size in GB                                             | number      | `60`                    |
| **Network Interface Configuration**       |                                                                |             |                         |
| `mgmt_accelerated_networking_enabled`     | Enable accelerated networking on management interface          | bool        | `false`                 |
| `mgmt_ip_forwarding_enabled`              | Enable IP forwarding on management interface                   | bool        | `false`                 |
| `untrust_accelerated_networking_enabled`  | Enable accelerated networking on untrust interface             | bool        | `true`                  |
| `untrust_ip_forwarding_enabled`           | Enable IP forwarding on untrust interface                     | bool        | `true`                  |
| `trust_accelerated_networking_enabled`    | Enable accelerated networking on trust interface              | bool        | `true`                  |
| `trust_ip_forwarding_enabled`             | Enable IP forwarding on trust interface                       | bool        | `true`                  |
| **IP Configuration**                      |                                                                |             |                         |
| `mgmt_private_ip_allocation`              | Management interface private IP allocation method              | string      | `"Dynamic"`             |
| `mgmt_static_private_ip`                  | Static private IP for management interface                     | string      | `null`                  |
| `untrust_private_ip_allocation`           | Untrust interface private IP allocation method                 | string      | `"Dynamic"`             |
| `untrust_static_private_ip`               | Static private IP for untrust interface                        | string      | `null`                  |
| `trust_private_ip_allocation`             | Trust interface private IP allocation method                   | string      | `"Dynamic"`             |
| `trust_static_private_ip`                 | Static private IP for trust interface                          | string      | `null`                  |
| **Bootstrap and Other Configuration**     |                                                                |             |                         |
| `custom_data`                             | Custom data for VM bootstrap configuration                     | string      | `null`                  |
| `enable_telemetry`                        | Enable telemetry for the IaC base module                      | bool        | `true`                  |
| `resource_tags`                           | Resource-specific tags (additional to common_tags)            | map(string) | `{}`                    |
| `custom_resource_group_name`              | Name of existing resource group to use                         | string      | `null`                  |
| `lock`                                    | Resource lock configuration                                    | object      | `null`                  |
| `role_assignments`                        | Role assignments to create on resources                        | map(object) | `{}`                    |

## Additional Details on Complex Optional Inputs

### `admin_ssh_keys`

- **Description**: List of SSH public keys for VM authentication. This replaces password-based authentication for enhanced security.
- **Type**: `list(object)`
  - **`username`** (string, required): The username associated with the SSH key. Should match the `admin_username` variable.
  - **`public_key`** (string, required): The SSH public key in OpenSSH format (e.g., `ssh-rsa AAAAB3...`).
- **Default**: `[]`

#### Example

```hcl
admin_ssh_keys = [
  {
    username   = "infosec"
    public_key = "ssh-rsa 
    ---- public_key -----
  }
]
```

**Notes:**
- When using SSH keys, `disable_password_authentication` is automatically set to `true`
- The SSH public key should be in OpenSSH format
- Multiple SSH keys can be provided for different users or backup access
- For Azure DevOps pipelines, store the SSH public key as a secure pipeline variable

### `lock`

- **Description**: Resource lock configuration to prevent accidental deletion or modification.
- **Type**: `object`
  - **`kind`** (string, required): Type of lock. Allowed values are `"CanNotDelete"` or `"ReadOnly"`.
  - **`name`** (string, optional): Name of the lock. If not provided, a default name will be generated.
- **Default**: `null`

#### Example

```hcl
lock = {
  kind = "CanNotDelete"
  name = "palo-firewall-lock"
}
```

### `role_assignments`

- **Description**: Role assignments to create on the Palo Alto firewall resources.
- **Type**: `map(object)`
  - **`role_definition_id_or_name`** (string, required): The ID or name of the role definition to assign.
  - **`principal_id`** (string, required): The ID of the principal (user, group, or service principal) to assign the role to.
  - **`description`** (string, optional): Description of the role assignment.
  - **`skip_service_principal_aad_check`** (bool, optional): Whether to skip the Azure AD check for the service principal. Defaults to `false`.
  - **`condition`** (string, optional): The condition that limits the resources that the role can be assigned to.
  - **`condition_version`** (string, optional): The version of the condition syntax (e.g., `"2.0"`).
  - **`delegated_managed_identity_resource_id`** (string, optional): The resource ID of the delegated managed identity resource.
  - **`principal_type`** (string, optional): The type of principal (`User`, `Group`, `ServicePrincipal`).
- **Default**: `{}`

#### Example

```hcl
role_assignments = {
  "firewall_operator" = {
    role_definition_id_or_name = "Virtual Machine Contributor"
    principal_id               = "00000000-0000-0000-0000-000000000000"
    description                = "Allows management of Palo Alto firewall VM"
    skip_service_principal_aad_check = false
  }
}
```
## Outputs

| Name                     | Description                                                |
| ------------------------ | ---------------------------------------------------------- |
| `vm_name`                | Name of the Palo Alto Firewall VM                         |
| `vm_id`                  | Resource ID of the Palo Alto Firewall VM                  |
| `resource_group_name`    | Resource Group of the Palo Alto Firewall                  |
| `public_ip_address`      | Public IP address of the management interface             |
| `public_ip_fqdn`         | Fully qualified domain name of the management interface   |
| `management_private_ip`  | Private IP address of the management interface            |
| `untrust_private_ip`     | Private IP address of the untrust interface               |
| `trust_private_ip`       | Private IP address of the trust interface                 |
| `network_interface_ids`  | Map of network interface IDs (management, untrust, trust) |
| `availability_set_id`    | Resource ID of the availability set (if enabled)          |
| `vm_size`                | Size of the Palo Alto Firewall VM                         |
| `admin_username`         | Admin username for the VM (sensitive)                     |

## Example Configurations

### Basic Setup

```hcl
module "palo_alto_firewall" {
  source = "path/to/modules/azure_palo_firewall"

  # Required inputs
  region                     = "eastus"
  app_name                   = "security"
  environment                = "dev"
  environment_number_suffix  = "001"
  
  # Network configuration
  custom_vnet_name                      = "vnet-security-dev-eastus-001"
  custom_vnet_resource_group_name       = "rg-network-security-dev-eastus-001"
  management_subnet_name                = "snet-pamgmt-10.182.6.128_27"
  untrust_subnet_name                   = "snet-untrust-10.182.6.64_27"
  trust_subnet_name                     = "snet-trust-10.182.6.96_27"
  
  # VM authentication with SSH keys
  admin_ssh_keys = [
    {
      username   = "infosec"
      public_key = "ssh-rsa 
      ---- public_key -----
    }
  ]

  # Required tags
  common_tags = {
    Environment = "dev"
    Owner       = "Network Security Team"
  }
}
```

### Advanced Configuration

```hcl
module "palo_alto_firewall" {
  source = "path/to/modules/azure_palo_firewall"

  # Required inputs
  region                     = "eastus"
  app_name                   = "security"
  environment                = "prod"
  environment_number_suffix  = "001"
  
  # Network configuration
  custom_vnet_name                      = "vnet-security-prod-eastus-001"
  custom_vnet_resource_group_name       = "rg-network-security-prod-eastus-001"
  management_subnet_name                = "snet-pamgmt-10.182.6.128_27"
  untrust_subnet_name                   = "snet-untrust-10.182.6.64_27"
  trust_subnet_name                     = "snet-trust-10.182.6.96_27"
  
  # VM configuration
  vm_size                    = "Standard_D8_v4"
  computer_name              = "palo-prod-001"
  
  # SSH Key authentication
  admin_ssh_keys = [
    {
      username   = "infosec"
      public_key = "ssh-rsa 
      ---- public_key -----
    }
  ]
  
  # Network interface configuration with static IPs
  mgmt_private_ip_allocation    = "Static"
  mgmt_static_private_ip        = "10.182.6.132"
  untrust_private_ip_allocation = "Static"
  untrust_static_private_ip     = "10.182.6.68"
  trust_private_ip_allocation   = "Static"
  trust_static_private_ip       = "10.182.6.100"
  
  # Public IP configuration
  public_ip_sku               = "Standard"
  public_ip_allocation_method = "Static"
  public_ip_sku_tier          = "Regional"
  
  # High availability (Legacy - Availability Sets)
  enable_availability_zones            = false
  enable_availability_set              = true
  availability_set_fault_domain_count  = 2
  
  # Network Security Group (optional)
  network_security_group_name               = "nsg-palo-firewall-prod"
  network_security_group_resource_group_name = "rg-network-security-prod-eastus-001"
  
  # Bootstrap configuration (optional)
  custom_data = file("${path.module}/palo-bootstrap-config.txt")
  
  # Required tags
  common_tags = {
    Environment        = "production"
    Owner             = "Network Security Team"
    Business_Unit     = "IT"
    Cost_Center       = "701"
    Business_Criticality = "Gold"
  }
  
  # Additional resource-specific tags
  resource_tags = {
    Backup_Required    = "true"
    Maintenance_Window = "Sunday 02:00-04:00"
  }
}
```

### Availability Zones Configuration (Recommended)

#### Single VM in Zone 1
```hcl
module "palo_alto_firewall_vm1" {
  source = "path/to/modules/azure_palo_firewall"

  # Required inputs
  region                     = "eastus"
  app_name                   = "paloalto-omb"
  environment                = "dev"
  environment_number_suffix  = "001"
  
  # Network configuration
  custom_vnet_name                      = "vnet-hub01-shared01-eu-vy"
  custom_vnet_resource_group_name       = "rg-network01-shared01-eu-vy"
  management_subnet_name                = "snet-omb-nonprod-pamgmt-01-10.216.255.96_27"
  untrust_subnet_name                   = "snet-omb-nonprod-untrust-01-10.216.255.32_27"
  trust_subnet_name                     = "snet-omb-nonprod-trust-01-10.216.255.64_27"
  
  # VM Configuration with updated naming
  computer_name = "aef-omb-np01"
  vm_size      = "Standard_D4s_v5"
  
  # High availability with Availability Zones (VM001 = Zone 1)
  enable_availability_zones = true
  availability_zone        = "1"
  enable_availability_set  = false
  
  # Static IP configuration
  mgmt_private_ip_allocation    = "Static"
  mgmt_static_private_ip        = "10.216.255.100"
  untrust_private_ip_allocation = "Static"
  untrust_static_private_ip     = "10.216.255.37"
  trust_private_ip_allocation   = "Static"
  trust_static_private_ip       = "10.216.255.69"
  
  # Authentication
  admin_ssh_keys = [
    {
      username   = "infosec"
      public_key = "ssh-rsa AAAAB3NzaC1yc2E...your-key-here"
    }
  ]

  common_tags = {
    Business_Unit        = "IT"
    Workload             = "Information Security Infrastructure"
    Business_Criticality = "Gold"
    Owner                = "Information Security Infrastructure"
  }
}
```

#### Multiple VMs in Different Zones
```hcl
# VM002 in Zone 2
module "palo_alto_firewall_vm2" {
  source = "path/to/modules/azure_palo_firewall"

  # Same configuration as VM1 but different zone and naming
  region                     = "eastus"
  app_name                   = "paloalto-omb"
  environment                = "dev"
  environment_number_suffix  = "002"
  
  # VM Configuration
  computer_name = "aef-omb-np02"
  
  # High availability (VM002 = Zone 2)
  enable_availability_zones = true
  availability_zone        = "2"
  enable_availability_set  = false
  
  # Different static IPs for second VM
  mgmt_private_ip_allocation    = "Static"
  mgmt_static_private_ip        = "10.216.255.101"
  untrust_private_ip_allocation = "Static"
  untrust_static_private_ip     = "10.216.255.38"
  trust_private_ip_allocation   = "Static"
  trust_static_private_ip       = "10.216.255.70"
  
  # ... rest of configuration
}
```

## Important Notes

### High Availability Configuration
- **Availability Zones (Recommended)**: Use `enable_availability_zones = true` for better resiliency. Deploy VM001 in Zone 1, VM002 in Zone 2, etc.
- **Availability Sets (Legacy)**: Set `enable_availability_zones = false` and `enable_availability_set = true` for traditional high availability.
- **Mutual Exclusivity**: Availability zones and availability sets cannot be used together. Choose one approach.

### Network Interface Naming (Updated November 2025)
- **Management Interface**: `nic-{app_name}-{environment}-{suffix}-eth0-mgmt`
- **Untrust Interface**: `nic-{app_name}-{environment}-{suffix}-eth1-untrust` 
- **Trust Interface**: `nic-{app_name}-{environment}-{suffix}-eth2-trust`
- **Interface Order**: Network interfaces are attached in specific order - management (eth0), untrust (eth1), trust (eth2). This order is critical for proper firewall operation.

### VM Configuration Updates
- **Default VM Size**: Changed to `Standard_D4s_v5` (4 vCPUs, 16 GB memory) for better performance.
- **Computer Name**: Use descriptive names like `aef-omb-np01` for VM001, `aef-omb-np02` for VM002.
- **OS Disk Naming**: Automatically follows pattern `{computer_name}_OsDisk` (e.g., `aef-omb-np01_OsDisk`).

### General Requirements
- **Region Support**: The `region` variable only accepts `"eastus"` or `"westus"` as valid values.
- **VM Size Requirements**: Ensure the selected VM size meets Palo Alto VM-Series minimum requirements and is supported in your target region.
- **Licensing**: The default image SKU is `"byol"` (Bring Your Own License). Ensure you have appropriate Palo Alto licensing before deployment.
- **Bootstrap Configuration**: Use the `custom_data` variable for initial bootstrap configuration. This should contain base64-encoded bootstrap data.
- **Security**: Network Security Group associations are optional but can provide an additional security layer for compliance requirements.
- **Resource Lock**: When using `lock` configuration, only `"CanNotDelete"` and `"ReadOnly"` values are supported for the `kind` property.
- **Static IP Configuration**: When using static IP allocation, ensure the IP addresses are within the subnet range and not already in use.
- **SSH Key Authentication**: The module uses SSH key authentication by default instead of password authentication. Ensure your SSH public keys are properly formatted in OpenSSH format.
- **Security Enhancement**: Password authentication is disabled by default (`disable_password_authentication = true`) when using SSH keys for improved security.

## Changelog

### Version 1.1.0 (November 2025)
- **🎯 Enhanced NIC Naming**: Updated network interface names to include descriptive suffixes:
  - Management: `nic-{app}-{env}-{suffix}-eth0-mgmt`
  - Untrust: `nic-{app}-{env}-{suffix}-eth1-untrust`
  - Trust: `nic-{app}-{env}-{suffix}-eth2-trust`
- **⚡ VM Size Upgrade**: Changed default VM size from `Standard_D3_v2` to `Standard_D4s_v5`
  - Improved performance: 4 vCPUs, 16 GB memory (up from 14 GB)
  - Better price-performance ratio with v5 generation
- **🔄 Availability Zones Support**: Added Azure Availability Zones as the preferred high availability option
  - New variables: `enable_availability_zones`, `availability_zone`
  - Availability zones now default to `true`, availability sets default to `false`
  - Mutually exclusive configuration prevents conflicting settings
- **📝 Enhanced Documentation**: Updated examples and best practices for new features
- **🔒 Backward Compatibility**: Existing deployments continue to work with legacy availability set configuration

### Version 1.0.0 (Initial Release)
- Initial Palo Alto VM-Series firewall module
- Support for three network interfaces (management, untrust, trust)
- SSH key authentication
- Availability set support
- Configurable VM sizing and network configuration

## References

- **Palo Alto Networks Documentation**:
  - [VM-Series Deployment Guide](https://docs.paloaltonetworks.com/vm-series)
  - [VM-Series on Azure](https://docs.paloaltonetworks.com/vm-series/10-2/vm-series-deployment/set-up-the-vm-series-firewall-on-azure)
  - [Bootstrap Package](https://docs.paloaltonetworks.com/vm-series/10-2/vm-series-deployment/bootstrap-the-vm-series-firewall)

- **Azure Documentation**:
  - [Azure Virtual Machines](https://learn.microsoft.com/en-us/azure/virtual-machines/)
  - [Azure Virtual Networks](https://learn.microsoft.com/en-us/azure/virtual-network/)
  - [Azure Network Security Groups](https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview)

- **Terraform Azure Provider**:
  - [Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
  - [Azure Linux Virtual Machine Resource](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine)

This module provides a standardized approach to deploying Palo Alto VM-Series firewalls on Azure, following best practices for network security and infrastructure as code.
