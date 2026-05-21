# Azure Resource Group Terraform Module

This Terraform module wraps the Azure Verified Module for creating an Azure Resource Group. It leverages the `iac_common_variables` module from the IaC repository, providing a validated set of inputs for setting up Azure Resource Groups. This module is designed for consumption in projects such as OMB, which manage their infrastructure using environment-specific `.tfvars` files.

## Requirements

- **Terraform**: `>= 1.5.2`
- **Providers**:
  - **AzureRM**: `~> 3.71`
  - **modtm**: `~> 0.3`
  - **random**: `~> 3.5`

## Providers

The module uses the following providers:

- `azurerm`: For Azure Resource Manager integration.
- `modtm`: For telemetry and logging management.
- `random`: For generating random values.

## Usage

### Consuming the `azure_resource_group` Module in the OMB Project

The OMB project consumes the `azure_resource_group` module from the IaC repository, combining it with the `iac_common_variables` module for validated inputs and outputs.

### Using an Existing Resource Group

You can use the optional variable `custom_resource_group_name` to specify an existing resource group. If this variable is set in your `.tfvars` file, the module will use the specified resource group. If not set, the module will create a new resource group using the standard naming convention.

#### Example `.tfvars` entry:

```hcl
custom_resource_group_name = "rg-testing-omb-dev-001"
```

### Project Structure

A typical project structure for consuming the module might look like this:

```
omb_project/
├── main.tf
├── environments/
│   ├── dev.tfvars
│   ├── staging.tfvars
│   └── prod.tfvars
└── modules/
    ├── iac_common_variables/
    │   └── <common variable definitions>
    └── azure_resource_group/
        └── <azure_resource_group module files>
```

### main.tf (OMB Project)

Below is an example of the `main.tf` file for the OMB project:

```hcl
# Load common variables from the IaC repo
module "base" {
  source = "../modules/iac_common_variables"

  # Required inputs
  app_name                  = var.app_name
  region                    = var.region
  component_name            = var.component_name
  environment               = var.environment
  environment_number_suffix = var.environment_number_suffix
  subscription_id           = var.subscription_id
  common_tags               = var.common_tags

  # Optional inputs
  resource_tags = var.resource_tags
}

# Create Azure Resource Group using the IaC repo's azure_resource_group module
module "resource_group" {
  source = "../modules/azure_resource_group"

  location = module.base.location
  name     = module.base.resource_group_name
  tags     = module.base.tags
}

# Outputs
output "resource_group_name" {
  value = module.base.resource_group_name
}

output "resource_group_id" {
  value = module.resource_group.resource_id
}
```

### Environment-Specific `.tfvars` Files

The OMB project uses `.tfvars` files for environment-specific configurations.

#### Example: `dev.tfvars`

```hcl
region                    = "eastus"
app_name                  = "omb-app"
component_name            = "resource-group"
environment               = "Development"
environment_number_suffix = "01"
subscription_id           = "12345678-1234-1234-1234-123456789abc"

common_tags = {
  Business_Unit        = "Finance"
  Workload             = "Application"
  Business_Criticality = "Gold"
  Owner                = "Digital Team"
  Operations_Team      = "Cloud Engineering"
  Cost_Center          = "701"
}

resource_tags = {
  CustomTag = "CustomValue"
}
```

#### Applying the Configuration

To apply the OMB configuration for a specific environment, use the corresponding `.tfvars` file:

```bash
terraform apply -var-file="environments/dev.tfvars"
```

## Inputs

| Name                        | Description                                                               | Type          | Default    | Required |
| --------------------------- | ------------------------------------------------------------------------- | ------------- | ---------- | -------- |
| `subscription_id`           | The subscription ID where the resource group will be deployed.            | `string`      | N/A        | Yes      |
| `region`                    | Azure region for the resource group (e.g., `eastus`, `westus`).           | `string`      | `"eastus"` | Yes      |
| `app_name`                  | Name of the VyStar application being deployed.                            | `string`      | N/A        | Yes      |
| `component_name`            | Name of the Azure component being deployed.                               | `string`      | N/A        | Yes      |
| `environment`               | The target environment (e.g., `Dev`, `QA`, `Prod`).                       | `string`      | N/A        | Yes      |
| `environment_number_suffix` | Suffix for the environment, typically a number for unique identification. | `string`      | N/A        | Yes      |
| `common_tags`               | A map of default tags applied to all resources.                           | `map(string)` | N/A        | Yes      |
| `resource_tags`             | Additional resource-specific tags, merged with `common_tags`.             | `map(string)` | `{}`       | No       |
| `custom_resource_group_name`| (Optional) Name of an existing resource group to use. If provided, no new resource group will be created. | `string` | `null` | No |

## Outputs

| Name          | Description                                          |
| ------------- | ---------------------------------------------------- |
| `name`        | The name of the created Azure Resource Group.        |
| `resource`    | Full output of the created Azure Resource Group.     |
| `resource_id` | The resource ID of the created Azure Resource Group. |

## Additional Documentation References

For more details, refer to the following resources:

- [What is a Resource Group in Azure?](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal#what-is-a-resource-group)
- [Azure Verified Modules Documentation](https://azure.github.io/Azure-Verified-Modules/indexes/terraform/)
- [Azure Verified Modules - Resource Modules Index](https://azure.github.io/Azure-Verified-Modules/indexes/terraform/tf-resource-modules/)
- [Terraform Registry: Azure Resource Group Verified Module](https://registry.terraform.io/modules/Azure/avm-res-resources-resourcegroup/azurerm/latest)
- [GitHub Repository for Azure Resource Group Verified Module](https://github.com/Azure/terraform-azurerm-avm-res-resources-resourcegroup)
