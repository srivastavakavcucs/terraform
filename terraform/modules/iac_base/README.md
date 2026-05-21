# VyStar Infrastructure Common Variables Module Documentation

## Table of Contents

- [VyStar Infrastructure Common Variables Module Documentation](#vystar-infrastructure-common-variables-module-documentation)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Modules](#modules)
    - [Common Variables Module](#common-variables-module)
      - [Required Variables](#required-variables)
      - [Optional Variables](#optional-variables)
      - [Outputs](#outputs)
      - [Example Usage](#example-usage)
  - [Using the Common Variables Module in Other Modules](#using-the-common-variables-module-in-other-modules)
    - [Azure Virtual Network Module Integration](#azure-virtual-network-module-integration)
      - [`modules/azure_virtual_network/variables.tf`](#modulesazure_virtual_networkvariablestf)
      - [`modules/azure_virtual_network/main.tf`](#modulesazure_virtual_networkmaintf)
    - [Sample `terraform.tfvars` File](#sample-terraformtfvars-file)
  - [Best Practices](#best-practices)
  - [References](#references)
  - [FAQ](#faq)

---

## Overview

This Terraform module provides a centralized configuration for common variables such as `tags`, `location`, `resource_group_name`, and more. It ensures consistency across all infrastructure modules by defining shared variables with strict validation and naming conventions, including support for dynamically processed tags with spaces.

---

## Modules

### Common Variables Module

The **Common Variables Module** centralizes shared variables with strict validations, ensuring consistent resource naming and tagging standards across all resources.

#### Required Variables

| Variable Name               | Type          | Default    | Description                                                                                                                                                                       |
| --------------------------- | ------------- | ---------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `subscription_id`           | `string`      | None       | The Azure Subscription ID.                                                                                                                                                        |
| `region`                    | `string`      | `"eastus"` | Specifies the Azure region where resources are deployed. Allowed values are `"eastus"` or `"westus"`.                                                                             |
| `app_name`                  | `string`      | None       | The name of the VyStar application being deployed (e.g., `omb`).                                                                                                                  |
| `component_name`            | `string`      | None       | The name of the Azure component being deployed (e.g., `vnet`, `redis`, `keyvault`).                                                                                               |
| `environment`               | `string`      | `"dev"`    | The target environment for deployment. Allowed values: `dev`, `qa`, `test`, `uat`, `stage`, `staging`, `prod`.                                                                    |
| `environment_number_suffix` | `string`      | None       | The environment number suffix for resource naming (e.g., `001`, `002`).                                                                                                           |
| `tags`                      | `map(string)` | None       | A map of common tags to apply to all resources. Must include keys: `Business_Unit`, `Workload`, `Business_Criticality`, `Owner`, `Operations_Team`, `Cost_Center`, `Environment`. |

#### Optional Variables

| Variable Name                      | Type          | Default | Description                                                                                                                                                 |
| ---------------------------------- | ------------- | ------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `private_dns_zone_subscription_id` | `string`      | `null`  | Azure Subscription ID for Private DNS Zones. Must be a valid Subscription ID format if provided.                                                            |
| `diagnostic_settings`              | `map(object)` | `{}`    | Diagnostic settings map for additional configuration.                                                                                                       |
| `enable_telemetry`                 | `bool`        | `true`  | Enable telemetry for the module.                                                                                                                            |
| `lock`                             | `object`      | `null`  | Configures resource locks with a `kind` field. Allowed values: `CanNotDelete`, `ReadOnly`.                                                                  |
| `role_assignments`                 | `map(object)` | `{}`    | A map of role assignments for resources, including `role_definition_id_or_name`, `principal_id`, and optional `description`, `condition`, and `delegation`. |
| `private_endpoints`                | `map(object)` | `{}`    | A map of private endpoints configuration, supporting custom subnet association, DNS zones, and resource locking.                                            |
| `custom_resource_group_name`       | `string`      | `null`  | (Optional) Name of an existing resource group to use. If provided, no new resource group will be created.                                                   |
| `custom_vnet_name`                 | `string`      | `""`   | (Optional) Custom VNet name. If not set, the default naming convention will be used.                                                                        |
| `custom_vnet_resource_group_name`  | `string`      | `""`   | (Optional) Custom VNet resource group name. If not set, the default naming convention will be used.                                                         |

#### Outputs

| Output Name           | Description                                                                                                    |
| --------------------- | -------------------------------------------------------------------------------------------------------------- |
| `location`            | Outputs the Azure region used by the module.                                                                   |
| `resource_group_name` | Outputs the generated resource group name.                                                                     |
| `vnet_name`           | Outputs the generated virtual network name.                                                                    |
| `tags`                | Outputs the validated tags map for use in downstream modules with `Created` and `IaC Module Registry Version`. |
| `subscription_id`     | Outputs the subscription ID.                                                                                   |
| `enable_telemetry`    | Outputs whether telemetry is enabled.                                                                          |
| `lock`                | Outputs the lock configuration.                                                                                |
| `role_assignments`    | Outputs the role assignments map.                                                                              |
| `private_endpoints`   | Outputs private endpoint configurations with dynamically generated names and subnet associations.              |
| `version_number`      | Outputs the hardcoded version number of the module.                                                            |

#### Example Usage

```hcl
module "common_vars" {
  source = "./iac_common_variables"

  subscription_id          = "12345678-1234-5678-1234-567812345678"
  region                   = "eastus"
  app_name                 = "omb"
  component_name           = "vnet"
  environment              = "dev"
  environment_number_suffix = "001"
  tags = {
    Business_Unit       = "Finance"
    Workload            = "Application"
    Business_Criticality = "Gold"
    Owner               = "OMB Team"
    Operations_Team     = "Cloud Engineering"
    Cost_Center         = "701"
    Environment         = "Development"
  }
  # Optional: Use custom resource group, VNet, and VNet resource group names
  custom_resource_group_name      = "rg-existing-devops"
  custom_vnet_name                = "vnet-hub01-shared01-eu-vy"
  custom_vnet_resource_group_name = "rg-network01-shared01-eu-vy"
}
```

---

## Using the Common Variables Module in Other Modules

### Azure Virtual Network Module Integration

The following demonstrates how the `iac_common_variables` module integrates with an Azure Virtual Network module.

#### `modules/azure_virtual_network/variables.tf`

```hcl
#---------------------------------------------------------------------------------
# Subscription IDs retrieved from the Library variables.
# Note: Validation done using iac_common_variables module.
#---------------------------------------------------------------------------------

variable "subscription_id" {
  description = "The Azure Subscription ID of the Application subscription."
  type        = string
}

#--------------------------------------------------------
# Common Required Inputs
#--------------------------------------------------------

variable "region" {
  description = "Azure region where the resource should be deployed. Allowed values are 'eastus' or 'westus'."
  type        = string
}

variable "app_name" {
  type        = string
  description = "Name of the VyStar application that will be deployed."
}

variable "environment" {
  type        = string
  description = "Target environment abbreviation for naming."
}

variable "environment_number_suffix" {
  type        = string
  description = "Environment number suffix for naming."
}

#--------------------------------------------------------
# Module Required Inputs
#--------------------------------------------------------

variable "address_space" {
  description = "The address spaces applied to the virtual network."
  type        = list(string)
  validation {
    condition     = length(var.address_space) > 0
    error_message = "At least one address space must be provided."
  }
}

#--------------------------------------------------------
# Tags
#--------------------------------------------------------

variable "common_tags" {
  type        = map(string)
  description = "A map of tags to common resource tags assign to the virtual network."
}

variable "resource_tags" {
  type        = map(string)
  description = "(Optional) A map of tags to assign to the virtual network. These tags are specific to the virtual network."
  default     = {}
}
```

#### `modules/azure_virtual_network/main.tf`

```hcl
#-----------------------------------------------------------------------
# Use the IaC Common Variables Module for validations and outputs.
#------------------------------------------------------------------------

module "base" {
  source = "../iac_base"

  # Required Variables
  app_name                  = var.app_name
  region                    = var.region
  component_name            = "vnet"
  environment               = var.environment
  environment_number_suffix = var.environment_number_suffix
  subscription_id           = var.subscription_id

  # Optional Variables
  tags                = var.common_tags
}

#-----------------------------------------------------------
# Create the Azure Virtual Network Resource
#-----------------------------------------------------------

resource "azurerm_virtual_network" "example" {
  name                = module.common_vars.vnet_name
  address_space       = var.address_space
  location            = module.common_vars.location
  resource_group_name = module.common_vars.resource_group_name

  tags = merge(
    module.common_vars.tags,
    var.resource_tags
  )
}
```

### Sample `terraform.tfvars` File

```hcl
subscription_id          = "12345678-1234-5678-1234-567812345678"
region                   = "eastus"
app_name                 = "omb"
environment              = "dev"
environment_number_suffix = "001"
tags = {
  Business_Unit        = "Finance"
  Workload             = "Application"
  Business_Criticality = "Gold"
  Owner                = "OMB Team"
  Operations_Team      = "Cloud Engineering"
  Cost_Center          = "701"
}
custom_resource_group_name      = "rg-existing-devops"
custom_vnet_name                = "vnet-hub01-shared01-eu-vy"
custom_vnet_resource_group_name = "rg-network01-shared01-eu-vy"
```

---

## Best Practices

- **Centralized Variables**: Use `iac_common_variables` for consistent variable definitions across modules.
- **Tagging Standards**: Follow VyStar tagging standards for all resources.
- **Reusability**: Leverage outputs from `iac_common_variables` in downstream modules for seamless integration.
- **Date Tagging**: Use the `Created` tag for automated resource deployment date tracking.
- **Tag Formatting**: Use underscores in `tags` input keys and rely on the module to process them into space-separated keys for Azure resources.

---

## References

- **VyStar Naming Standards**: Refer to **Azure Naming and Tagging Standards v4.0.0.0_20241022.docx** for detailed naming conventions and examples for resource groups, virtual networks, and tags.

---

## FAQ

**Q: Can I override tags for a specific module?**  
A: Yes, use the `merge` function to combine common tags with module-specific tags.

**Q: How do I validate `Created`?**  
A: The `Created` tag is automatically set to the deployment date in `YYYYMMDD` format using Terraform's `timestamp()` and `formatdate()` functions.

**Q: What happens if a required variable is missing?**  
A: Terraform will raise an error with a detailed description of the missing variable.

**Q: How do I use an existing resource group or VNet?**  
A: Set `custom_resource_group_name`, `custom_vnet_name`, or `custom_vnet_resource_group_name` in your `.tfvars` file. If not set, the module will use the default naming convention and create new resources as needed.

---
