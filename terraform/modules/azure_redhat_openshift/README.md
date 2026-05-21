# Azure Red Hat OpenShift (ARO) Terraform Module

This Terraform module deploys an **Azure Red Hat OpenShift (ARO)** cluster along with role assignments and necessary configurations in an existing Azure Virtual Network (VNet).

---

## Table of Contents

- [Azure Red Hat OpenShift (ARO) Terraform Module](#azure-red-hat-openshift-aro-terraform-module)
  - [Table of Contents](#table-of-contents)
  - [Usage](#usage)
    - [Basic Usage Example](#basic-usage-example)
  - [Inputs](#inputs)
    - [Required Variables](#required-variables)
    - [Optional Variables](#optional-variables)
  - [Outputs](#outputs)
  - [Examples](#examples)
    - [Basic Example](#basic-example)
  - [Additional Documentation](#additional-documentation)

---

## Usage

To use this module, define the required variables in your Terraform configuration.

### Basic Usage Example

```hcl
module "aro_cluster" {
  source = "./modules/aro-cluster"

  # General Configuration
  app_name                  = "example-app"
  environment               = "dev"
  environment_number_suffix = "001"
  region                    = "eastus"

  # Service Principal Information
  sp_client_id     = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  sp_client_secret = "supersecretpassword"

  # Network and Subnet Configuration
  vnet_name                  = "example-vnet"
  main_subnet_name_segment   = "aro-main"
  worker_subnet_name_segment = "aro-workers"

  # Cluster Configuration
  openshift_version = "4.15.27"
  domain            = "example.com"
  pod_cidr          = "10.128.0.0/14"
  service_cidr      = "172.30.0.0/16"
  worker_node_count = 3
  main_vm_size      = "Standard_D8s_v5"
  worker_node_vm_size = "Standard_D4s_v5"

  # Required Secrets
  rh_pull_secret = "YOUR_RED_HAT_PULL_SECRET"

  # Tags
  common_tags = {
    Business_Unit        = "Finance"
    Workload             = "Application"
    Business_Criticality = "Gold"
    Owner                = "Digital Team"
    Operations_Team      = "Cloud Engineering"
    Cost_Center          = "701"
  }

  resource_tags = {
    Department = "Engineering"
  }

  # Role Assignments
  aro_cluster_aad_sp_object_id         = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  aro_resource_provider_aad_sp_object_id = "yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy"
}
```

---

## Inputs

### Required Variables

| Variable Name                            | Description                                                      | Type          | Required |
| ---------------------------------------- | ---------------------------------------------------------------- | ------------- | -------- |
| `subscription_id`                        | Azure Subscription ID where resources will be deployed.          | `string`      | Yes      |
| `region`                                 | Azure region for resource deployment (e.g., `eastus`, `westus`). | `string`      | Yes      |
| `app_name`                               | Name of the VyStar application being deployed.                   | `string`      | Yes      |
| `environment`                            | Environment abbreviation for resource naming.                    | `string`      | Yes      |
| `environment_number_suffix`              | Number suffix for the environment.                               | `string`      | Yes      |
| `main_subnet_name_segment`               | Name segment for the main subnet (e.g., `aro-main`).             | `string`      | Yes      |
| `worker_subnet_name_segment`             | Name segment for the worker subnet (e.g., `aro-workers`).        | `string`      | Yes      |
| `sp_client_id`                           | Service Principal Client ID for cluster authentication.          | `string`      | Yes      |
| `sp_client_secret`                       | Service Principal Client Secret for cluster authentication.      | `string`      | Yes      |
| `rh_pull_secret`                         | Red Hat pull secret required for the OpenShift cluster.          | `string`      | Yes      |
| `aro_cluster_aad_sp_object_id`           | AAD Object ID for the ARO Cluster Service Principal.             | `string`      | Yes      |
| `aro_resource_provider_aad_sp_object_id` | AAD Object ID for the ARO Resource Provider Service Principal.   | `string`      | Yes      |
| `openshift_version`                      | OpenShift version to deploy (e.g., `4.15.27`).                   | `string`      | Yes      |
| `common_tags`                            | Tags applied to all resources.                                   | `map(string)` | Yes      |

### Optional Variables

| Variable Name           | Description                                     | Type          | Default             |
| ----------------------- | ----------------------------------------------- | ------------- | ------------------- |
| `worker_node_count`     | Number of worker nodes.                         | `number`      | `3`                 |
| `pod_cidr`              | CIDR block for the Pod network.                 | `string`      | `"10.128.0.0/14"`   |
| `service_cidr`          | CIDR block for the service network.             | `string`      | `"172.30.0.0/16"`   |
| `main_vm_size`          | VM size for control plane nodes.                | `string`      | `"Standard_D8s_v5"` |
| `worker_node_vm_size`   | VM size for worker nodes.                       | `string`      | `"Standard_D4s_v5"` |
| `api_server_visibility` | Visibility for the API server (Public/Private). | `string`      | `"Private"`         |
| `ingress_visibility`    | Visibility for the ingress controller.          | `string`      | `"Private"`         |
| `resource_tags`         | Optional tags specific to resources.            | `map(string)` | `{}`                |

---

## Outputs

| Output Name          | Description                                  | Example                                                                       |
| -------------------- | -------------------------------------------- | ----------------------------------------------------------------------------- |
| `name`               | Name of the ARO cluster.                     | `"example-aro-cluster"`                                                       |
| `console_url`        | URL of the ARO Console.                      | `"https://console-openshift-console.something.jaxnavy.org"`                   |
| `cluster_profile`    | Cluster profile details.                     | `{ "resource_group_id": "/subscriptions/.../rg" }`                            |
| `api_server_profile` | API server details including IP and URL.     | `{ "ip_address": "10.188.1.10", "url": "https://api.something.jaxnavy.org" }` |
| `ingress_profile`    | List of ingress profiles with names and IPs. | `[ { "name": "default", "ip_address": "10.188.1.254" }]`                      |

---

## Examples

### Basic Example

```hcl
module "aro_cluster" {
  source = "./modules/aro-cluster"

  app_name                  = "example-app"
  environment               = "dev"
  environment_number_suffix = "001"
  region                    = "eastus"

  sp_client_id     = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  sp_client_secret = "supersecretpassword"
  rh_pull_secret   = "YOUR_RED_HAT_PULL_SECRET"

  vnet_name                  = "example-vnet"
  main_subnet_name_segment   = "aro-main"
  worker_subnet_name_segment = "aro-workers"

  openshift_version = "4.15.27"
  domain            = "example.com"
  pod_cidr          = "10.128.0.0/14"
  service_cidr      = "172.30.0.0/16"
  worker_node_count = 3

  common_tags = {
    Business_Unit        = "Finance"
    Workload             = "Application"
    Business_Criticality = "Gold"
    Owner                = "Digital Team"
    Operations_Team      = "Cloud Engineering"
    Cost_Center          = "701"
  }

  resource_tags = {
    Department = "Engineering"
  }

  aro_cluster_aad_sp_object_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  aro_resource_provider_aad_sp_object_id = "yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy"
}
```

---

## Additional Documentation

- [Azure Red Hat OpenShift Documentation](https://learn.microsoft.com/en-us/azure/openshift/)
- [Terraform AzureRM Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/redhat_openshift_cluster)
- [Azure Red Hat OpenShift Support Policies and Supported VM Sizes](https://learn.microsoft.com/en-us/azure/openshift/support-policies-v4)
