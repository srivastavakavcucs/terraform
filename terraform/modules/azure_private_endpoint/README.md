# Azure Private Endpoint Terraform Module

This Terraform module creates and manages Azure Private Endpoints, allowing secure connectivity to Azure services over a private link.

**Features:**

- Create Private Endpoints in a specified Virtual Network and Subnet.
- Associate Private Endpoints with various Azure services (e.g., Storage Accounts, SQL Servers).
- Configure Private DNS Zones, even in a different subscription.
- Apply role assignments to the Private Endpoint.
- Enforce organization-wide tagging policies.

---

## Table of Contents

- [Azure Private Endpoint Terraform Module](#azure-private-endpoint-terraform-module)
  - [Table of Contents](#table-of-contents)
  - [Usage](#usage)
  - [Variables](#variables)
    - [Required Variables](#required-variables)
    - [Optional Variables](#optional-variables)
      - [IP Configurations](#ip-configurations)
      - [Lock](#lock)
      - [Role Assignments](#role-assignments)
  - [Outputs](#outputs)
  - [Example](#example)
    - [Main Terraform Configuration](#main-terraform-configuration)
    - [Example `terraform.tfvars`](#example-terraformtfvars)
  - [Valid Resource Types](#valid-resource-types)
  - [Valid Subresource Names](#valid-subresource-names)
  - [Additional Documentation](#additional-documentation)

---

## Usage

```hcl
# Configure the Azure providers
provider "azurerm" {
  features = {}
}

# Aliased provider for DNS zones in a different subscription
provider "azurerm" {
  alias           = "dns"
  features        = {}
  subscription_id = var.dns_zone_subscription_id
  tenant_id       = var.dns_zone_tenant_id
}

module "azure_private_endpoint" {
  source = "./path-to-your-module"

  # Required Variables
  location                               = var.location
  resource_group_name                    = var.resource_group_name
  name                                   = var.name
  private_connection_resource_name       = var.private_connection_resource_name
  private_connection_resource_group_name = var.private_connection_resource_group_name
  private_connection_resource_type       = var.private_connection_resource_type
  vnet_name                              = var.vnet_name
  subnet_name                            = var.subnet_name
  vnet_resource_group_name               = var.vnet_resource_group_name
  private_dns_zone_names                 = var.private_dns_zone_names
  private_dns_zone_resource_group_names  = var.private_dns_zone_resource_group_names
  dns_zone_subscription_id               = var.dns_zone_subscription_id
  dns_zone_tenant_id                     = var.dns_zone_tenant_id
  common_tags                            = var.common_tags

  # Optional Variables
  network_interface_name                        = var.network_interface_name
  application_security_group_names              = var.application_security_group_names
  application_security_group_resource_group_names = var.application_security_group_resource_group_names
  enable_telemetry                              = var.enable_telemetry
  ip_configurations                             = var.ip_configurations
  lock                                          = var.lock
  private_dns_zone_group_name                   = var.private_dns_zone_group_name
  private_service_connection_name               = var.private_service_connection_name
  role_assignments                              = var.role_assignments
  subresource_names                             = var.subresource_names
  tags                                          = var.tags

  providers = {
    azurerm     = azurerm
    azurerm.dns = azurerm.dns
  }
}
```

---

## Variables

### Required Variables

| Name                                     | Type           | Description                                                                                                                                                                    |
| ---------------------------------------- | -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `location`                               | `string`       | **(Required)** Azure region where the Private Endpoint will be deployed.                                                                                                       |
| `resource_group_name`                    | `string`       | **(Required)** The name of the resource group where the Private Endpoint will be deployed.                                                                                     |
| `name`                                   | `string`       | **(Required)** The name of the Private Endpoint resource.                                                                                                                      |
| `private_connection_resource_name`       | `string`       | **(Required)** The name of the Private Link Enabled Remote Resource to connect to (e.g., storage account name).                                                                |
| `private_connection_resource_group_name` | `string`       | **(Required)** The resource group name of the Private Link Enabled Remote Resource.                                                                                            |
| `private_connection_resource_type`       | `string`       | **(Required)** The resource type of the Private Link Enabled Remote Resource (e.g., `"Microsoft.Storage/storageAccounts"`). See [Valid Resource Types](#valid-resource-types). |
| `vnet_name`                              | `string`       | **(Required)** The name of the Virtual Network containing the subnet.                                                                                                          |
| `subnet_name`                            | `string`       | **(Required)** The name of the subnet within the Virtual Network.                                                                                                              |
| `vnet_resource_group_name`               | `string`       | **(Required)** The resource group name of the Virtual Network.                                                                                                                 |
| `private_dns_zone_names`                 | `list(string)` | **(Required)** List of Private DNS Zone names to include within the private DNS zone group.                                                                                    |
| `private_dns_zone_resource_group_names`  | `list(string)` | **(Required)** List of resource group names corresponding to the Private DNS Zone names. Must match the length of `private_dns_zone_names`.                                    |
| `dns_zone_subscription_id`               | `string`       | **(Required)** The subscription ID where the DNS zones reside.                                                                                                                 |
| `dns_zone_tenant_id`                     | `string`       | **(Required)** The tenant ID for the DNS zone subscription.                                                                                                                    |
| `common_tags`                            | `map(string)`  | **(Required)** A map of common tags to apply to all resources.                                                                                                                 |

### Optional Variables

| Name                                              | Type           | Description                                                                                                                                | Default |
| ------------------------------------------------- | -------------- | ------------------------------------------------------------------------------------------------------------------------------------------ | ------- |
| `tags`                                            | `map(string)`  | A map of tags to assign to the Private Endpoint. These tags are specific to the Private Endpoint and can override or add to `common_tags`. | `{}`    |
| `network_interface_name`                          | `string`       | The custom name of the network interface attached to the Private Endpoint.                                                                 | `null`  |
| `application_security_group_names`                | `set(string)`  | The names of application security groups to associate with the network interface.                                                          | `[]`    |
| `application_security_group_resource_group_names` | `map(string)`  | Map of ASG names to their resource group names. If not specified, defaults to the Private Endpoint's resource group.                       | `{}`    |
| `enable_telemetry`                                | `bool`         | Controls whether telemetry is enabled for the module.                                                                                      | `true`  |
| `ip_configurations`                               | `map(object)`  | A map of `ip_configuration` blocks. See [IP Configurations](#ip-configurations) below.                                                     | `{}`    |
| `lock`                                            | `object`       | An object to specify resource locking to prevent accidental deletion or modification. See [Lock](#lock) below.                             | `null`  |
| `private_dns_zone_group_name`                     | `string`       | Specifies the name of the Private DNS Zone Group.                                                                                          | `null`  |
| `private_service_connection_name`                 | `string`       | Specifies the name of the Private Service Connection.                                                                                      | `null`  |
| `role_assignments`                                | `map(object)`  | A map of role assignments to create on this resource. See [Role Assignments](#role-assignments) below.                                     | `{}`    |
| `subresource_names`                               | `list(string)` | A list of subresource names the Private Endpoint can connect to. See [Valid Subresource Names](#valid-subresource-names).                  | `[]`    |

#### IP Configurations

The `ip_configurations` variable is a map where each key is an identifier, and the value is an object with:

- `name` (string, required): The name of the IP configuration.
- `private_ip_address` (string, required): The static IP address within the subnet. Must be in the `10.x.y.z` range.
- `subresource_name` (string, required): The subresource this IP address applies to.
- `member_name` (string, optional): The member name this IP address applies to. Defaults to `"default"`.

**Example:**

```hcl
ip_configurations = {
  "config1" = {
    name               = "ipconfig1"
    private_ip_address = "10.1.2.3"
    subresource_name   = "blob"
  }
}
```

#### Lock

The `lock` variable is an object with:

- `name` (string, optional): The name of the lock.
- `kind` (string, required): The lock level. Possible values: `"CanNotDelete"`, `"ReadOnly"`.

**Example:**

```hcl
lock = {
  name = "ResourceLock"
  kind = "CanNotDelete"
}
```

#### Role Assignments

The `role_assignments` variable is a map where each key is an arbitrary identifier, and the value is an object with:

- `role_definition_id_or_name` (string, required): The ID or name of the role definition.
- `principal_id` (string, required): The ID of the principal to assign the role to.
- `description` (string, optional): The description of the role assignment.
- `skip_service_principal_aad_check` (bool, optional): Set to `true` to skip the AAD check for service principals. Defaults to `false`.
- `condition` (string, optional): The condition to scope the role assignment.
- `condition_version` (string, optional): The version of the condition syntax. Valid value: `"2.0"`.
- `delegated_managed_identity_resource_id` (string, optional): The delegated resource ID containing a Managed Identity (used in cross-tenant scenarios).
- `principal_type` (string, optional): The type of `principal_id`. Possible values: `"User"`, `"Group"`, `"ServicePrincipal"`.

**Note:** Only set `skip_service_principal_aad_check` to `true` if assigning a role to a service principal.

**Example:**

```hcl
role_assignments = {
  "assignment1" = {
    role_definition_id_or_name       = "Contributor"
    principal_id                     = "00000000-0000-0000-0000-000000000000"
    description                      = "Assignment to Service Principal"
    skip_service_principal_aad_check = true
    principal_type                   = "ServicePrincipal"
  }
}
```

---

## Outputs

| Name                          | Description                                        |
| ----------------------------- | -------------------------------------------------- |
| `private_endpoint_id`         | The ID of the Private Endpoint.                    |
| `private_endpoint_name`       | The name of the Private Endpoint.                  |
| `private_endpoint_ip_address` | The private IP address of the Private Endpoint.    |
| `private_endpoint_nic_id`     | The network interface ID of the Private Endpoint.  |
| `tags`                        | The combined tags applied to the Private Endpoint. |

---

## Example

### Main Terraform Configuration

```hcl
# providers.tf

provider "azurerm" {
  features = {}
}

provider "azurerm" {
  alias           = "dns"
  features        = {}
  subscription_id = var.dns_zone_subscription_id
  tenant_id       = var.dns_zone_tenant_id
}

# main.tf

module "azure_private_endpoint" {
  source = "./path-to-your-module"

  # Required Variables
  location                               = var.location
  resource_group_name                    = var.resource_group_name
  name                                   = var.name
  private_connection_resource_name       = var.private_connection_resource_name
  private_connection_resource_group_name = var.private_connection_resource_group_name
  private_connection_resource_type       = var.private_connection_resource_type
  vnet_name                              = var.vnet_name
  subnet_name                            = var.subnet_name
  vnet_resource_group_name               = var.vnet_resource_group_name
  private_dns_zone_names                 = var.private_dns_zone_names
  private_dns_zone_resource_group_names  = var.private_dns_zone_resource_group_names
  dns_zone_subscription_id               = var.dns_zone_subscription_id
  dns_zone_tenant_id                     = var.dns_zone_tenant_id
  common_tags                            = var.common_tags

  # Optional Variables
  network_interface_name                        = var.network_interface_name
  application_security_group_names              = var.application_security_group_names
  application_security_group_resource_group_names = var.application_security_group_resource_group_names
  enable_telemetry                              = var.enable_telemetry
  ip_configurations                             = var.ip_configurations
  lock                                          = var.lock
  private_dns_zone_group_name                   = var.private_dns_zone_group_name
  private_service_connection_name               = var.private_service_connection_name
  role_assignments                              = var.role_assignments
  subresource_names                             = var.subresource_names
  tags                                          = var.tags

  providers = {
    azurerm     = azurerm
    azurerm.dns = azurerm.dns
  }
}

# variables.tf

variable "location" {
  description = "(Required) Azure region where the resource should be deployed."
  type        = string
}

variable "resource_group_name" {
  description = "(Required) The resource group where the Private Endpoint will be deployed."
  type        = string
}

variable "name" {
  description = "(Required) The name of the Private Endpoint resource."
  type        = string
}

variable "private_connection_resource_name" {
  description = "(Required) The name of the Private Link Enabled Remote Resource."
  type        = string
}

variable "private_connection_resource_group_name" {
  description = "(Required) The resource group name of the Private Connection Resource."
  type        = string
}

variable "private_connection_resource_type" {
  description = "(Required) The resource type of the Private Connection Resource."
  type        = string
}

variable "vnet_name" {
  description = "(Required) The name of the Virtual Network."
  type        = string
}

variable "subnet_name" {
  description = "(Required) The name of the Subnet."
  type        = string
}

variable "vnet_resource_group_name" {
  description = "(Required) The resource group name of the Virtual Network."
  type        = string
}

variable "private_dns_zone_names" {
  description = "(Required) List of Private DNS Zone names."
  type        = list(string)
}

variable "private_dns_zone_resource_group_names" {
  description = "(Required) List of resource group names for the Private DNS Zones."
  type        = list(string)
}

variable "dns_zone_subscription_id" {
  description = "(Required) The subscription ID where the DNS zones reside."
  type        = string
}

variable "dns_zone_tenant_id" {
  description = "(Required) The tenant ID for the DNS zone subscription."
  type        = string
}

variable "common_tags" {
  description = "(Required) Common tags to be applied to resources."
  type        = map(string)
}

# Optional Variables

variable "network_interface_name" {
  description = "(Optional) The custom name of the network interface."
  type        = string
  default     = null
}

variable "application_security_group_names" {
  description = "(Optional) Names of the Application Security Groups."
  type        = set(string)
  default     = []
}

variable "application_security_group_resource_group_names" {
  description = "(Optional) Map of ASG names to their resource group names."
  type        = map(string)
  default     = {}
}

variable "enable_telemetry" {
  description = "(Optional) Enable telemetry."
  type        = bool
  default     = true
}

variable "ip_configurations" {
  description = "(Optional) IP configurations."
  type        = map(object({
    name               = string
    private_ip_address = string
    subresource_name   = string
    member_name        = optional(string, "default")
  }))
  default = {}
}

variable "lock" {
  description = "(Optional) Resource lock configuration."
  type = object({
    name = optional(string, null)
    kind = string
  })
  default = null
}

variable "private_dns_zone_group_name" {
  description = "(Optional) Private DNS Zone Group name."
  type        = string
  default     = null
}

variable "private_service_connection_name" {
  description = "(Optional) Private Service Connection name."
  type        = string
  default     = null
}

variable "role_assignments" {
  description = "(Optional) Role assignments."
  type = map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
    principal_type                         = optional(string, null)
  }))
  default = {}
}

variable "subresource_names" {
  description = "(Optional) Subresource names for the Private Endpoint."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "(Optional) Resource-specific tags."
  type        = map(string)
  default     = {}
}
```

### Example `terraform.tfvars`

```hcl
# Required Variables

location = "eastus"

resource_group_name = "my-pe-resource-group"

name = "my-private-endpoint"

private_connection_resource_name       = "mystorageaccount"
private_connection_resource_group_name = "my-storage-rg"
private_connection_resource_type       = "Microsoft.Storage/storageAccounts"

vnet_name                = "my-vnet"
subnet_name              = "my-subnet"
vnet_resource_group_name = "my-network-rg"

private_dns_zone_names                = ["privatelink.blob.core.windows.net"]
private_dns_zone_resource_group_names = ["my-dns-rg"]

dns_zone_subscription_id = "87654321-4321-4321-4321-cba987654321"
dns_zone_tenant_id       = "dcba4321-dcba-4321-dcba-4321dcba8765"

common_tags = {
  Environment = "Production"
  Project     = "MyProject"
}

# Optional Variables

network_interface_name = "my-pe-nic"

application_security_group_names = ["my-asg"]
application_security_group_resource_group_names = {
  "my-asg" = "my-asg-rg"
}

enable_telemetry = true

ip_configurations = {
  "config1" = {
    name               = "ipconfig1"
    private_ip_address = "10.1.2.3"
    subresource_name   = "blob"
  }
}

lock = {
  name = "ResourceLock"
  kind = "CanNotDelete"
}

private_dns_zone_group_name     = null
private_service_connection_name = null

role_assignments = {
  "assignment1" = {
    role_definition_id_or_name       = "Contributor"
    principal_id                     = "00000000-0000-0000-0000-000000000000"
    description                      = "Assignment to Service Principal"
    skip_service_principal_aad_check = true
    principal_type                   = "ServicePrincipal"
  }
}

subresource_names = ["blob"]

tags = {
  Owner = "TeamA"
}
```

---

## Valid Resource Types

The `private_connection_resource_type` variable must be one of the following supported resource types:

| Service                                         | Resource Type                                              |
| ----------------------------------------------- | ---------------------------------------------------------- |
| Application Gateway                             | `"Microsoft.Network/applicationGateways"`                  |
| Azure AI Search                                 | `"Microsoft.Search/searchServices"`                        |
| Azure AI services                               | `"Microsoft.CognitiveServices/accounts"`                   |
| Azure API for FHIR                              | `"Microsoft.HealthcareApis/services"`                      |
| Azure API Management                            | `"Microsoft.ApiManagement/service"`                        |
| Azure App Configuration                         | `"Microsoft.AppConfiguration/configurationStores"`         |
| Azure App Service (hosting environments)        | `"Microsoft.Web/hostingEnvironments"`                      |
| Azure App Service (sites)                       | `"Microsoft.Web/sites"`                                    |
| Azure Attestation Service                       | `"Microsoft.Attestation/attestationProviders"`             |
| Azure Automation                                | `"Microsoft.Automation/automationAccounts"`                |
| Azure Backup                                    | `"Microsoft.RecoveryServices/vaults"`                      |
| Azure Batch                                     | `"Microsoft.Batch/batchAccounts"`                          |
| Azure Cache for Redis                           | `"Microsoft.Cache/Redis"`                                  |
| Azure Cache for Redis Enterprise                | `"Microsoft.Cache/redisEnterprise"`                        |
| Azure Container Registry                        | `"Microsoft.ContainerRegistry/registries"`                 |
| Azure Cosmos DB                                 | `"Microsoft.AzureCosmosDB/databaseAccounts"`               |
| Azure Cosmos DB for MongoDB vCore               | `"Microsoft.DocumentDB/mongoClusters"`                     |
| Azure Cosmos DB for PostgreSQL                  | `"Microsoft.DBforPostgreSQL/serverGroupsv2"`               |
| Azure Data Explorer                             | `"Microsoft.Kusto/clusters"`                               |
| Azure Data Factory                              | `"Microsoft.DataFactory/factories"`                        |
| Azure Database for MariaDB                      | `"Microsoft.DBforMariaDB/servers"`                         |
| Azure Database for MySQL - Flexible Server      | `"Microsoft.DBforMySQL/flexibleServers"`                   |
| Azure Database for MySQL - Single Server        | `"Microsoft.DBforMySQL/servers"`                           |
| Azure Database for PostgreSQL - Flexible Server | `"Microsoft.DBforPostgreSQL/flexibleServers"`              |
| Azure Database for PostgreSQL - Single Server   | `"Microsoft.DBforPostgreSQL/servers"`                      |
| Azure Databricks                                | `"Microsoft.Databricks/workspaces"`                        |
| Azure Device Provisioning Service               | `"Microsoft.Devices/provisioningServices"`                 |
| Azure Digital Twins                             | `"Microsoft.DigitalTwins/digitalTwinsInstances"`           |
| Azure Event Grid (domains)                      | `"Microsoft.EventGrid/domains"`                            |
| Azure Event Grid (topics)                       | `"Microsoft.EventGrid/topics"`                             |
| Azure Event Hub                                 | `"Microsoft.EventHub/namespaces"`                          |
| Azure File Sync                                 | `"Microsoft.StorageSync/storageSyncServices"`              |
| Azure HDInsight                                 | `"Microsoft.HDInsight/clusters"`                           |
| Azure IoT Central                               | `"Microsoft.IoTCentral/IoTApps"`                           |
| Azure IoT Hub                                   | `"Microsoft.Devices/IotHubs"`                              |
| Azure Key Vault                                 | `"Microsoft.KeyVault/vaults"`                              |
| Azure Key Vault HSM                             | `"Microsoft.KeyVault/managedHSMs"`                         |
| Azure Kubernetes Service - Kubernetes API       | `"Microsoft.ContainerService/managedClusters"`             |
| Azure Machine Learning (registries)             | `"Microsoft.MachineLearningServices/registries"`           |
| Azure Machine Learning (workspaces)             | `"Microsoft.MachineLearningServices/workspaces"`           |
| Azure Managed Disks                             | `"Microsoft.Compute/diskAccesses"`                         |
| Azure Media Services                            | `"Microsoft.Media/mediaservices"`                          |
| Azure Migrate                                   | `"Microsoft.Migrate/assessmentProjects"`                   |
| Azure Monitor Private Link Scope                | `"Microsoft.Insights/privateLinkScopes"`                   |
| Azure Relay                                     | `"Microsoft.Relay/namespaces"`                             |
| Azure Service Bus                               | `"Microsoft.ServiceBus/namespaces"`                        |
| Azure SignalR Service                           | `"Microsoft.SignalRService/SignalR"`                       |
| Azure SignalR Service (Web PubSub)              | `"Microsoft.SignalRService/WebPubSub"`                     |
| Azure SQL Database                              | `"Microsoft.Sql/servers"`                                  |
| Azure SQL Managed Instance                      | `"Microsoft.Sql/managedInstances"`                         |
| Azure Static Web Apps                           | `"Microsoft.Web/staticSites"`                              |
| Azure Storage                                   | `"Microsoft.Storage/storageAccounts"`                      |
| Azure Synapse (privateLinkHubs)                 | `"Microsoft.Synapse/privateLinkHubs"`                      |
| Azure Synapse Analytics                         | `"Microsoft.Synapse/workspaces"`                           |
| Azure Virtual Desktop - host pools              | `"Microsoft.DesktopVirtualization/hostPools"`              |
| Azure Virtual Desktop - workspaces              | `"Microsoft.DesktopVirtualization/workspaces"`             |
| Device Update for IoT Hub                       | `"Microsoft.DeviceUpdate/accounts"`                        |
| Integration Account (Premium)                   | `"Microsoft.Logic/integrationAccounts"`                    |
| Microsoft Purview                               | `"Microsoft.Purview/accounts"`                             |
| Power BI                                        | `"Microsoft.PowerBI/privateLinkServicesForPowerBI"`        |
| Private Link service (your own service)         | `"Microsoft.Network/privateLinkServices"`                  |
| Resource Management Private Links               | `"Microsoft.Authorization/resourceManagementPrivateLinks"` |

---

## Valid Subresource Names

Valid `subresource_names` depend on the `private_connection_resource_type` provided.

**Example for Azure Storage (`Microsoft.Storage/storageAccounts`):**

| Subresource Name    | Description                  |
| ------------------- | ---------------------------- |
| `"blob"`            | Blob storage endpoint        |
| `"blob_secondary"`  | Secondary blob endpoint      |
| `"file"`            | File storage endpoint        |
| `"file_secondary"`  | Secondary file endpoint      |
| `"queue"`           | Queue storage endpoint       |
| `"queue_secondary"` | Secondary queue endpoint     |
| `"table"`           | Table storage endpoint       |
| `"table_secondary"` | Secondary table endpoint     |
| `"web"`             | Web endpoint                 |
| `"web_secondary"`   | Secondary web endpoint       |
| `"dfs"`             | Data Lake Storage endpoint   |
| `"dfs_secondary"`   | Secondary Data Lake endpoint |

**Refer to the [Azure Private Link documentation](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview#private-link-resource) for a complete list of valid subresource names for each resource type.**

---

## Additional Documentation

For more information on the `Azure/avm-res-network-privateendpoint/azurerm` Azure Verified Module and its available options, please refer to the [official Azure Verified Module documentation on the module](https://registry.terraform.io/modules/Azure/avm-res-network-privateendpoint/azurerm/latest).

- GitHub Repository: [Azure/terraform-azurerm-avm-res-network-privateendpoint](https://github.com/Azure/terraform-azurerm-avm-res-network-privateendpoint/tree/0.1.0)
- Azure Private Endpoint Overview: [Private Link Resource](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview#private-link-resource)
