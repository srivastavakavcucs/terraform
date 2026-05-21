# Azure DDoS Protection Plan Terraform Module

This Terraform module provisions an Azure DDoS Protection Plan using the `Azure/avm-res-network-ddosprotectionplan/azurerm` module. The plan helps to secure your Azure resources against Distributed Denial of Service (DDoS) attacks and integrates easily into your infrastructure as code (IaC) workflows.

---

## Table of Contents

- [Azure DDoS Protection Plan Terraform Module](#azure-ddos-protection-plan-terraform-module)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Requirements](#requirements)
  - [Providers](#providers)
  - [Inputs](#inputs)
    - [Required Inputs](#required-inputs)
    - [Optional Inputs](#optional-inputs)
  - [Outputs](#outputs)
  - [Usage](#usage)
  - [Example](#example)
  - [References](#references)

---

## Overview

This Terraform configuration creates an Azure DDoS Protection Plan, which is an important step to safeguard your Azure resources from Distributed Denial of Service (DDoS) attacks. It uses the `Azure/avm-res-network-ddosprotectionplan/azurerm` module to configure the protection plan and includes the following features:

- **DDoS Protection Plan**: Protects your Azure resources.
- **Role Assignments**: Configurable Azure role-based access control (RBAC) roles.
- **Resource Locking**: Prevents accidental deletions by applying resource locks.
- **Optional Telemetry**: Configures telemetry collection for better monitoring.

---

## Requirements

The following requirements are needed by this module:

- **Terraform**: `>= 1.6.0`
- **Others**:
  - `azurerm` (>= `3.71.0`)
  - `random` (>= `3.5.0`)
  - `time` (>= `0.9.1`)

---

## Providers

The following providers are used by this module:

- `azurerm` (>= `3.71.0`)
- `random` (>= `3.5.0`)

---

## Inputs

### Required Inputs

These variables must be provided for the module to work:

- **`region`**  
  The Azure region where the resource will be deployed.  
  _Valid values_: `"eastus"` or `"westus"`

- **`app_name`**  
  The name of the VyStar application that will be deployed.

- **`environment`**  
  Target environment abbreviation for naming.

- **`environment_number_suffix`**  
  Environment number suffix for naming.

- **`subscription_id`**  
  The Azure Subscription ID of the Application subscription.

### Optional Inputs

These variables are optional but can be configured as needed:

- **`enable_telemetry`**  
  Controls whether telemetry is enabled for the module.  
  _Type_: `bool`  
  _Default_: `true`

- **`lock`**  
  Resource lock configuration for the protection plan.  
  _Type_: `object({ kind = string })`  
  _Default_: `null`

- **`role_assignments`**  
  A map of role assignments to create for the DDoS protection plan.  
  _Type_: `map(object({ role_definition_id_or_name = string, principal_id = string, ... }))`  
  _Default_: `{}`

- **`common_tags`**  
  Default tags for all resources.  
  _Type_: `map(string)`  
  _Required_: Yes

- **`resource_tags`**  
  Specific tags for the resource.  
  _Type_: `map(string)`  
  _Default_: `{}`

---

## Outputs

This module generates the following outputs:

- **`ddos_protection_plan_id`**  
  The ID of the created DDoS Protection Plan.

- **`ddos_protection_plan_name`**  
  The name of the created DDoS Protection Plan.

- **`resource_group_name`**  
  The resource group name where the DDoS Protection Plan is deployed.

- **`location`**  
  The location of the DDoS Protection Plan.

---

## Usage

To use this module, simply call it from your main Terraform configuration:

```hcl
module "ddos_protection_plan" {
  source              = "./path-to-this-module"
  name                = "MyDDoSProtectionPlan"
  location            = "eastus"
  resource_group_name = "my-resource-group"
  enable_telemetry    = true
  lock                = { kind = "CanNotDelete" }
  role_assignments    = {
    "role1" = {
      role_definition_id_or_name = "Contributor"
      principal_id               = "<principal_id>"
    }
  }
  tags = {
    Environment = "Production"
    Owner       = "Admin"
  }
}
```

---

## Example

Here’s an example of how you can use this module in a simple Terraform configuration:

```hcl
module "ddos_protection_plan" {
  source              = "./modules/azure_ddosprotectionplan"
  name                = "MyDDoSProtectionPlan"
  location            = "eastus"
  resource_group_name = "my-resource-group"
  enable_telemetry    = false
  lock                = { kind = "CanNotDelete" }
  tags                = {
    Environment = "Development"
  }
}
```

---

## References

- [Terraform Documentation](https://www.terraform.io/docs)
- [Azure DDOS Protection Documentation](https://www.terraform.io/docshttps://github.com/Azure/terraform-azurerm-avm-res-network-ddosprotectionplan)
- [Terraform Azure Verified Module: DDoS Protection Plan](https://github.com/Azure/terraform-azurerm-avm-res-network-ddosprotectionplan)
- [Microsoft Official Documentation: Azure DDoS Protection](https://learn.microsoft.com/en-us/azure/ddos-protection/)
- [Azure DDoS Protection Pricing](https://azure.microsoft.com/en-us/pricing/details/ddos-protection/)

---
