# Azure Kubernetes Service (AKS) Terraform Module

---

## Table of Contents

- [Introduction](#introduction)
- [Basic Usage Example](#basic-usage-example)
- [Detailed Usage Example](#detailed-usage-example)
- [Variables](#variables)
  - [Required Variables](#required-variables)
  - [Optional Variables](#optional-variables)
- [Outputs](#outputs)
- [Additional Documentation](#additional-documentation)

---

## Introduction

This Terraform module provisions a private **Azure Kubernetes Service (AKS)** cluster with the following key features:

- User-Assigned Managed Identity
- Private DNS zone integration (cross-subscription)
- Azure CNI with user-defined routing
- Autoscaling and secure networking
- Role assignments and identity federation
- Optional telemetry integration
- Connectivity to existing resources: Azure Container Registry (ACR), PostgreSQL, Redis, Key Vault, and Azure Storage

### Data Sources Used

#### Managed Identity (`aks_identity`)
Retrieves an existing User Assigned Managed Identity for use with AKS or other Azure services.

#### Private DNS Zone - Cross-Subscription (`aks_private_dns`)
Looks up a Private DNS Zone from a different subscription using a provider alias.

#### Azure Container Registry (`acr`)
References an existing ACR for pulling container images.

#### PostgreSQL Flexible Server (`pgsql`)
Connects to an existing PostgreSQL server for persistent database storage.

#### Azure Storage Account
References an existing Storage Account for blob storage or file shares.

#### Azure Redis Cache
Retrieves an existing Redis Cache instance for caching and messaging.

#### Azure Key Vault
References an existing Key Vault to securely store secrets, certificates, and keys.

#### Ingress Private DNS Zone (`aks_ingress_dns_local`)
Looks up a DNS zone used for internal access to AKS ingress endpoints.

#### Shared Resource Group (`shared01`)
References the resource group containing the private DNS zone for ingress.

---

## Module Components Overview

### `main.base.tf`
Acts as a foundational Infrastructure-as-Code module that:

- Validates required input variables and applies tagging conventions
- Discovers and maps Virtual Networks, subnets, and DNS zones dynamically
- Optionally creates resource groups, locks, and IAM role assignments
- Outputs reusable references (VNet ID, subnet ID, resource group, etc.)

#### Key Features

1. **Input Validation**  
   Validates variables like `region`, `app_name`, `component_name`, and `common_tags` for completeness and correctness.

2. **Naming Standards**  
   Implements VyStar’s naming conventions:
   - Resource Group: `rg-{app_name}-{component_name}-{env}-{env_suffix}`
   - VNet: `vnet-{app_name}-{env}-{region}-{env_suffix}`
   - Private Endpoint: `pe-{component}-{app_name}-{env}-{env_suffix}`

3. **Resource Discovery**  
   Uses data sources to retrieve:
   - VNet and Subnets
   - Private DNS Zones
   - Azure Subscription details

4. **Subnet Resolution**  
   Maps subnet name segments (e.g., `aks`, `redis`) to actual subnet names and IDs using regex.

5. **Private Endpoint Configuration**  
   Creates private endpoints with:
   - Correct subnet association
   - Private DNS integration
   - Optional role assignments, tags, and locks

6. **Conditional Resource Group Creation**  
   Creates a new resource group if `deploy_resource_group` is `true`.

7. **Telemetry Support**  
   Sends optional telemetry data using the `modtm_telemetry` resource.

8. **Outputs**  
   Exports important references (e.g., `subnet_name_segments_to_subnet_id_map`, `private_endpoints`, etc.) for downstream modules.

---

### `main.lock.tf`, `main.telemetry.tf`, `main.tf`

Defines the AKS cluster with:

- Private cluster configuration
- OIDC and workload identity setup
- Key Vault integration
- Auto-scaling node pool
- Network profile and DNS

### `outputs.tf`
Declares and exports Terraform outputs such as AKS cluster name, ID, FQDNs, identity, and more.

### `providers.tf`
Declares required providers (`azurerm`, `random`, `modtm`).

### `service_integrations.tf`
Assigns necessary roles for AKS to access ACR, Redis, PostgreSQL, Key Vault, and Storage.

### `variables.tf`
Defines module input variables and applies validations.

---

## Basic Usage Example

```hcl
module "aks" {
  source = "./modules/aks"

  region                    = "eastus"
  app_name                  = "sample-app"
  environment               = "dev"
  environment_number_suffix = "001"

  min_node_count = 1
  max_node_count = 3
  vm_size        = "Standard_DS2_v2"
  service_cidr   = "10.0.0.0/16"
  dns_service_ip = "10.0.0.10"

  node_subnet_name_segment = "aks-main"
  pod_subnet_name_segment  = "aks-pods"

  aks_identity_name               = "mi-aks-dev-001"
  aks_identity_rg_name           = "rg-identities-dev"
  aks_private_dns_name           = "privatelink.eastus.azmk8s.io"
  aks_private_dns_shared_rg_name = "rg-dns-shared"

  connected_acr_name         = "myacr"
  connected_acr_rg_name      = "rg-acr"
  connected_pgsql_name       = "mypgsql"
  connected_pgsql_rg_name    = "rg-db"
  connected_redis_name       = "myredis"
  connected_redis_rg_name    = "rg-cache"
  connected_kv_name          = "mykv"
  connected_kv_rg_name       = "rg-kv"
  connected_storage_name     = "mystorage"
  connected_storage_rg_name  = "rg-storage"

  common_tags = {
    Project     = "AKSInfra"
    Environment = "Development"
  }
}
```

---

## **Variables**

### **Required Variables**

| Name                             | Type   | Description                                                                          |
|----------------------------------|--------|--------------------------------------------------------------------------------------|
| `region`                         | string | Azure region to deploy the AKS cluster.                                              |
| `app_name`                       | string | Name of the application.                                                             |
| `environment`                    | string | Target environment abbreviation (e.g., `dev`, `prod`).                               |
| `environment_number_suffix`      | string | Numerical suffix for environment-based resource naming.                              |
| `node_subnet_name_segment`       | string | Subnet name segment for node subnet.                                                 |
| `pod_subnet_name_segment`        | string | Subnet name segment for pod subnet.                                                  |
| `min_node_count`                 | number | Minimum node count for the AKS default node pool.                                    |
| `max_node_count`                 | number | Maximum node count for the AKS default node pool.                                    |
| `vm_size`                        | string | Virtual machine size for the default node pool.                                      |
| `service_cidr`                   | string | CIDR range for Kubernetes service IPs.                                               |
| `dns_service_ip`                 | string | Kubernetes DNS service IP address.                                                   |
| `aks_identity_name`              | string | Name of the user-assigned identity for AKS.                                          |
| `aks_identity_rg_name`           | string | Resource group of the user-assigned identity.                                        |
| `aks_private_dns_name`           | string | Name of the private DNS zone used by AKS.                                            |
| `aks_private_dns_shared_rg_name` | string | Resource group containing the AKS private DNS zone.                                  |
| `connected_acr_name`             | string | Name of the connected Azure Container Registry.                                      |
| `connected_acr_rg_name`          | string | Resource group of the connected ACR.                                                 |
| `connected_pgsql_name`           | string | Name of the PostgreSQL Flexible Server.                                              |
| `connected_pgsql_rg_name`        | string | Resource group of the PostgreSQL server.                                             |
| `connected_redis_name`           | string | Name of the connected Redis instance.                                                |
| `connected_redis_rg_name`        | string | Resource group of the Redis instance.                                                |
| `connected_kv_name`              | string | Name of the connected Azure Key Vault.                                               |
| `connected_kv_rg_name`           | string | Resource group of the Key Vault.                                                     |
| `connected_storage_name`         | string | Name of the connected Azure Storage account.                                         |
| `connected_storage_rg_name`      | string | Resource group of the Storage account.                                               |
| `common_tags`                    | map    | Tags applied to all resources.                                                       |

---

### **Optional Variables**

| Name | Type    | Description                                                       | Default |
|---|---------|-------------------------------------------------------------------|---------|
| `lock` | object  | Optional lock configuration. Format: `{ kind = "CanNotDelete" }`. | `null`  |
| `resource_tags` | map     | Optional additional tags applied to specific resources.           | `{}`    |
| `enable_telemetry`| bool    | Enables telemetry for module usage tracking.                      | `true`  |
| `enable_psa_support`| bool    | Enabless pod security admissions support for the cluster.         | `false` |

---

## **Outputs**

| Output Name                 | Description                                               |
|-----------------------------|-----------------------------------------------------------|
| `aks_id`                    | The ID of the AKS cluster.                                |
| `aks_cluster_name`          | The name of the AKS cluster.                              |
| `resource_group_name`       | Resource group where the AKS cluster is deployed.         |
| `aks_fqdn`                  | Public FQDN of the cluster (if available).                |
| `aks_private_fqdn`          | Private FQDN of the cluster.                              |
| `aks_node_rg`               | The node resource group name.                             |
| `aks_identity`              | Managed identity used by AKS.                             |
| `aks_workload_identity`     | ID of the workload identity.                              |
| `aks_pod_subnet_id`         | Subnet ID used for pods.                                  |
| `aks_kube_admin_config`     | Raw admin kubeconfig (sensitive).                         |
| `kube_config`               | Base64-decoded kubeconfig.                                |
| `aks_connected_acr`         | Name of connected ACR.                                    |
| `aks_connected_pgsql`       | Name of connected PostgreSQL.                             |
| `aks_connected_redis`       | Name of connected Redis.                                  |
| `aks_connected_kv`          | Name of connected Key Vault.                              |
| `aks_connected_azfs`        | Name of connected Azure Storage Account.                  |
| `aks_ingress_local`         | Object for the local ingress private DNS zone.            |
| `aks_ingress_local_id`      | ID of the local ingress private DNS zone.                 |

---

## **Additional Documentation**

1. [Azure AKS Documentation](https://learn.microsoft.com/en-us/azure/aks/)
2. [Azure Kubernetes Terraform Docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster)
3. [Azure CNI Networking in AKS](https://learn.microsoft.com/en-us/azure/aks/configure-azure-cni)
4. [Workload Identity in AKS](https://learn.microsoft.com/en-us/azure/aks/workload-identity-overview)
5. [Terraform Modules Documentation](https://developer.hashicorp.com/terraform/language/modules/develop)