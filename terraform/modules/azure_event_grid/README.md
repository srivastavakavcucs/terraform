# Azure Event Grid Terraform Module

This Terraform module provisions an Azure Event Grid topic and subscription resource. It is designed to support configurable runtimes and integrates with VyStar's standard naming conventions and tagging requirements.

---

## Table of Contents

- [Azure Event Grid Terraform Module](#azure-event-grid-terraform-module)
  - [Table of Contents](#table-of-contents)
  - [Module Overview](#module-overview)
  - [Requirements](#requirements)
  - [Providers](#providers)
  - [Module Inputs](#module-inputs)
  - [Additional Details on Complex Optional Inputs](#additional-details-on-complex-optional-inputs)
  - [Module Outputs](#module-outputs)
  - [Usage Examples](#usage-examples)
  - [Additional Documentation](#additional-documentation)

---

## Module Overview

The Azure Event Grid Terraform Module provisions Azure Event Grid resources in Azure. This module supports configurable runtimes and follows VyStar's Pipeline 2.0 standards for naming, tagging, and resource group management via the shared `iac_base` module. 

---

## Requirements

- **Terraform**: `>= 1.9.2` — [Latest Releases](https://github.com/hashicorp/terraform/releases)
- **Providers**:
  - `azurerm`: `>= 4.69.0`

---

## Providers

| Provider | Source            | Version  |
| -------- | ----------------- | -------- |
| azurerm  | hashicorp/azurerm | `>= 4.69.0` |

> **Note:** This module requires `azurerm >= 4.69.0` and Terraform `>= 1.9.2`. See [AzureRM Provider Releases](https://github.com/hashicorp/terraform-provider-azurerm/releases) and [Terraform Releases](https://github.com/hashicorp/terraform/releases) for available versions.

---

## Module Inputs

### Required Variables

| Name                         | Type          | Description                                                                                              |
| ---------------------------- | ------------- | -------------------------------------------------------------------------------------------------------- |
| `system_topic_name`                     | `string`      | Name of the system topic.                               |
| `subscription_name`                   | `string`      | Name of Event Subscription.                                                    |
| `resource_group_name`                | `string`      | Azure Resource Group Name.                                                              |
| `location`  | `string`      | Azure Region.                                                                    |
| `source_resource_id`                | `string` | Source Azure Resource id.                                                              |
| `topic_type`                    | `string`      | Event grid topic type.                      |
| `webhook_url`            | `string`      | Webhook Endpoint URL.                        |

### Optional Variables

| Name | Type | Default | Description |
| ---- | ---- | ------- | ----------- |
| `included_event_types` | `list(string)` | `[]` | Event types to Subscribe. |
| `tags` | `map(string)` | `{}` | A map of Tags |

---

### Outputs

| Name | Type | Description |
| ---- | ---- | ----------- |
| `system_topic_id` | `string` | Event Grid system topic id. |
| `system_topic_name` | `string` | Event Grid system topic name. |
| `event_subscription_id` | `string` | Event Subscription id. |
| `event_subscription_name` | `string` | Event Subscription name. |

---

# Example Outputs

```hcl
output "system_topic_id" {
  value = module.eventgrid.system_topic_id
}
```

> **Provider alias requirement:** This module always passes `azurerm.private_dns_zone_subscription_provider` to `iac_base`. The root module must configure this provider alias and pass it to the module via a `providers` block. See [Terraform provider aliases](https://developer.hashicorp.com/terraform/language/providers/configuration#alias-multiple-provider-configurations).

# Usage 

#### Example

```hcl
module "eventgrid" {
  source = "./modules/azure_event_grid"

  system_topic_name = "storage-events-topic"
  subscription_name = "blob-created-sub"

  resource_group_name = "rg-demo"
  location = "Central India"

  source_resource_id = azurerm_storage_account.sa.id

  topic_type = "Microsoft.Storage.StorageAccounts"

  webhook_url = "Microsoft.Storage.BlobCreated"

  tags = {
    environment = "dev"
    application = "cloudods"
  }
}
```

## Additional Documentation

- [Azure Event Grid Documentation](https://learn.microsoft.com/en-us/azure/event-grid/overview/)
- [AzureRM Provider Releases](https://github.com/hashicorp/terraform-provider-azurerm/releases)
- [Terraform Releases](https://github.com/hashicorp/terraform/releases)
- [Terraform Modules Documentation](https://developer.hashicorp.com/terraform/language/modules/develop)
