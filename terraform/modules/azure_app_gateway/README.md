# Azure Application Gateway Terraform Module

This Terraform module provisions an Azure Application Gateway resource using the [Azure Verified Module](https://registry.terraform.io/modules/Azure/avm-res-network-applicationgateway/azurerm/latest) for the Application Gateway. It supports extensive configuration options for the Application Gateway, including autoscaling, SSL certificates, diagnostics, WAF configuration, role assignments, and more.

---

## Table of Contents

- [Azure Application Gateway Terraform Module](#azure-application-gateway-terraform-module)
  - [Table of Contents](#table-of-contents)
  - [Module Overview](#module-overview)
    - [Supported App Gateway SKUs](#supported-app-gateway-skus)
  - [Requirements](#requirements)
  - [Providers](#providers)
  - [Input Variables](#input-variables)
    - [Required Inputs](#required-inputs)
    - [Optional Inputs](#optional-inputs)
  - [Module Outputs](#module-outputs)
  - [Complex Parameter Explanations](#complex-parameter-explanations)
    - [`frontend_ip_configuration`](#frontend_ip_configuration)
    - [`backend_address_pools`](#backend_address_pools)
    - [`backend_http_settings`](#backend_http_settings)
    - [`ssl_certificates`](#ssl_certificates)
    - [`url_path_maps`](#url_path_maps)
  - [Additional Information on Parameters](#additional-information-on-parameters)
  - [Usage Examples](#usage-examples)
    - [Basic Example](#basic-example)
    - [Example with Backend Pools and Routing Rules](#example-with-backend-pools-and-routing-rules)
    - [Example with SSL Termination](#example-with-ssl-termination)
    - [Example Using Custom Probes](#example-using-custom-probes)
  - [Additional Documentation](#additional-documentation)

---

## Module Overview

The Azure Application Gateway Terraform Module provisions an Application Gateway instance in Azure, which acts as a load balancer with advanced routing capabilities. The module [Azure Verified Module](https://registry.terraform.io/modules/Azure/avm-res-network-applicationgateway/azurerm/latest) provides flexibility in configuring the various settings associated with the Application Gateway, including frontend IP configurations, backend address pools, HTTP settings, and custom probes.

---

### Supported App Gateway SKUs

- **Standard_v2**
- **WAF_v2** (Web Application Firewall)

The module supports features such as SSL offloading, URL-based routing, Web Application Firewall (WAF), and custom probes, among others.

---

## Requirements

- **Terraform**: ~> 1.9
- **AzureRM Provider**: >= 3.71
- **ModTM Provider**: ~> 0.3
- **Random Provider**: ~> 3.5
- **Time Provider**: ~> 0.9

---

## Providers

| Provider | Source              | Version      |
| -------- | ------------------- | ------------ |
| azurerm  | hashicorp/azurerm    | `~> 3.0`     |
| random   | hashicorp/random     | `~> 3.0`   

---

## Input Variables

### Required Inputs

| Name                 | Description                                                                                  | Type   |
|----------------------|----------------------------------------------------------------------------------------------|--------|
| `location`           | The Azure location where the resources will be deployed.                                     | string |
| `name`               | The name of the Application Gateway.                                                         | string |
| `resource_group_name`| The resource group where the resources will be deployed.                                     | string |
| `backend_address_pools` | A list of backend address pools to configure for the Application Gateway.                  | list(object) |
| `backend_http_settings` | A list of backend HTTP settings to configure for the Application Gateway.                  | list(object) |
| `frontend_ports`     | A list of frontend ports for the Application Gateway.                                        | list(object) |
| `gateway_ip_configuration` | A list of gateway IP configurations for the Application Gateway.                         | list(object) |
| `http_listeners`     | A list of HTTP listeners for the Application Gateway.                                         | list(object) |
| `request_routing_rules` | A list of routing rules for the Application Gateway.                                        | list(object) |

---

### Optional Inputs

| Name                                 | Description                                                                                           | Type                                  | Default | Arguments |
|--------------------------------------|-------------------------------------------------------------------------------------------------------|---------------------------------------|---------|-----------|
| `gateway_subnet_name_segment`        | The subnet id of the App gateway frontend IP configuration.                                           | string                                | None    | - subnet_id: (string) The ID of the subnet for the frontend IP. |
| `app_gateway_waf_policy_resource_id` | The ID of the Web Application Firewall Policy.                                                         | string                                | `null`  | - resource_id: (string) The ID of the WAF policy. |
| `authentication_certificate`         | The contents of the Authentication Certificate to be used.                                            | map(object({ data = string, name = string })) | `null`  | - name: (string) The certificate's name. <br> - data: (string) The base64-encoded certificate data. |
| `autoscale_configuration`            | Maximum capacity for autoscaling. Accepted values range from 2 to 125.                                | object({ min_capacity = optional(number, 1), max_capacity = optional(number, 2) }) | `null`  | - min_capacity: (int) Minimum number of instances. <br> - max_capacity: (int) Maximum number of instances. |
| `create_public_ip`                   | Controls whether to automatically create a public IP.                                                  | bool                                  | `true`  | - enabled: (bool) Whether to create a public IP. |
| `custom_error_configuration`         | Custom error page URL configuration for the application gateway.                                      | map(object({ custom_error_page_url = string, status_code = string })) | `null`  | - custom_error_page_url: (string) The URL for the custom error page. <br> - status_code: (string) The HTTP status code. |
| `diagnostic_settings`                | A map of diagnostic settings to create on the Application Gateway.                                     | map(object({ ... }))                  | `{}`    | - enabled: (bool) Enable diagnostic logging. <br> - logs: (list(object)) Log categories. <br> - metrics: (list(object)) Metric categories. |
| `enable_telemetry`                   | Controls whether telemetry is enabled for the module.                                                  | bool                                  | `true`  | - enabled: (bool) Whether telemetry is enabled. |
| `fips_enabled`                       | Whether FIPS is enabled on the Application Gateway.                                                   | bool                                  | `null`  | - enabled: (bool) Whether to enable FIPS mode. |
| `frontend_ip_configuration_private`  | Configuration for a private frontend IP.                                                             | object({ name = optional(string), private_ip_address = optional(string), private_ip_address_allocation = optional(string), private_link_configuration_name = optional(string) }) | `{}`    | - name: (string) Name for the private IP configuration. <br> - private_ip_address: (string) The IP address for the frontend. |
| `frontend_ip_configuration_public_name` | The name of the public frontend IP configuration.                                                  | string                                | `null`  | - name: (string) The name for the public frontend IP configuration. |
| `global`                             | Whether the request buffer is enabled.                                                                 | object({ request_buffering_enabled = bool, response_buffering_enabled = bool }) | `null`  | - request_buffering_enabled: (bool) Whether to enable request buffering. <br> - response_buffering_enabled: (bool) Whether to enable response buffering. |
| `http2_enable`                       | Enables HTTP/2 protocol support for the Application Gateway.                                           | bool                                  | `true`  | - enabled: (bool) Whether to enable HTTP/2. |
| `lock`                               | Controls the Resource Lock configuration for this resource.                                           | object({ kind = string, name = optional(string, null) }) | `null`  | - kind: (string) The lock type (CanNotDelete, ReadOnly). |
| `managed_identities`                 | Controls the Managed Identity configuration.                                                           | object({ system_assigned = optional(bool, false), user_assigned_resource_ids = optional(set(string), []) }) | `{}`    | - system_assigned: (bool) Whether system-assigned managed identity is enabled. <br> - user_assigned_resource_ids: (list) The list of user-assigned managed identities. |
| `private_link_configuration`         | Configuration for private link settings.                                                               | set(object({ name = string, ip_configuration = list(object({ name = string, primary = bool, private_ip_address = optional(string), private_ip_address_allocation = string, subnet_id = string })) })) | `null`  | - name: (string) Name of the private link configuration. <br> - ip_configuration: (list) A list of IP configurations. |
| `probe_configurations`               | Configurations for probes, including hostname, interval, timeout, and other settings.                 | map(object({ ... }))                  | `null`  | - name: (string) Name of the probe. <br> - interval: (int) The probe interval. <br> - timeout: (int) Timeout for the probe. |
| `public_ip_name`                     | The name of the public IP configuration.                                                               | string                                | `null`  | - name: (string) Name of the public IP configuration. |
| `public_ip_resource_id`              | Public IP resource ID. If provided, a public IP will not be created.                                  | string                                | `null`  | - resource_id: (string) The resource ID of the public IP. |
| `redirect_configuration`             | URL redirection configuration.                                                                         | map(object({ ... }))                  | `null`  | - name: (string) Name of the redirect configuration. <br> - target_url: (string) The target URL for the redirection. |
| `rewrite_rule_set`                   | Rewrite rule set configurations.                                                                       | map(object({ ... }))                  | `null`  | - name: (string) Name of the rewrite rule set. <br> - rules: (list) A list of rewrite rules. |
| `role_assignments`                   | A map of role assignments to create.                                                                   | map(object({ ... }))                  | `{}`    | - role_definition_id_or_name: (string) The role definition ID or name. <br> - principal_id: (string) The principal ID. |
| `sku`                                | SKU settings for the Application Gateway.                                                             | object({ name = string, tier = string, capacity = optional(number, 2) }) | `{ name = "Standard_v2", tier = "Standard_v2", capacity = 2 }` | - name: (string) SKU name (e.g., Standard_v2). <br> - tier: (string) SKU tier (e.g., Standard_v2). |
| `ssl_certificates`                   | Base64-encoded PFX certificate data. Required if `key_vault_secret_id` is not set.                   | map(object({ ... }))                  | `null`  | - name: (string) The name of the certificate. <br> - data: (string) The base64-encoded certificate data. |
| `ssl_policy`                         | SSL policy with supported cipher suites and protocols.                                                | object({ ... })                       | `null`  | - cipher_suites: (list(string)) A list of cipher suites. <br> - disabled_protocols: (list(string)) A list of disabled protocols. |
| `ssl_profile`                        | The name of the SSL Profile that is unique within the Application Gateway.                             | map(object({ ... }))                  | `null`  | - name: (string) The name of the SSL profile. |
| `timeouts`                           | Timeouts for creating, deleting, reading, or updating the Application Gateway.                         | object({ create = optional(string), delete = optional(string), read = optional(string), update = optional(string) }) | `null`  | - create: (string) Timeout for create operation. <br> - delete: (string) Timeout for delete operation. |
| `trusted_client_certificate`         | Base64-encoded certificate for trusted client authentication.                                         | map(object({ data = string, name = string })) | `null`  | - data: (string) The certificate data. <br> - name: (string) The name of the certificate. |
| `trusted_root_certificate`           | Trusted Root Certificate data.                                                                         | map(object({ data = optional(string), key_vault_secret_id = optional(string), name = string })) | `null`  | - data: (string) The certificate data. <br> - key_vault_secret_id: (string) The Key Vault secret ID. |
| `url_path_map_configurations`        | URL Path Map configurations.                                                                           | map(object({ ... }))                  | `null`  | - name: (string) The name of the URL path map. <br> - path_rules: (list) A list of path rules. |
| `waf_configuration`                  | Configuration for the Web Application Firewall.                                                       | object({ ... })                       | `null`  | - enabled: (bool) Enable or disable WAF. <br> - firewall_mode: (string) The firewall mode (e.g., Detection, Prevention). |
| `zones`                              | List of Availability Zones where the Application Gateway should be located.                           | set(string)                           | `[]`    | - zones: (list) A list of Availability Zones. |

---

## Module Outputs

| Name                          | Description                                                                                             |
|-------------------------------|---------------------------------------------------------------------------------------------------------|
| `application_gateway_id`      | The ID of the Azure Application Gateway.                                                                |
| `application_gateway_name`    | The name of the Azure Application Gateway.                                                              |
| `backend_address_pools`       | Information about the backend address pools configured for the Application Gateway, including their names.|
| `backend_http_settings`       | Information about the backend HTTP settings for the Application Gateway, including settings like port and protocol.|
| `frontend_port`               | Information about the frontend ports used by the Application Gateway, including their names and port numbers.|
| `http_listeners`              | Information about the HTTP listeners configured for the Application Gateway, including their names and settings.|
| `probes`                      | Information about health probes configured for the Application Gateway, including their settings.       |
| `public_ip_address`           | The actual public IP address associated with the Public IP resource.                                    |
| `public_ip_id`                | The ID of the Azure Public IP address associated with the Application Gateway.                          |
| `request_routing_rules`       | Information about request routing rules defined for the Application Gateway, including their names and configurations.|
| `resource_id`                 | The resource ID of the Application Gateway.                                                             |
| `ssl_certificates`            | Information about SSL certificates used by the Application Gateway, including their names and other details.|
| `waf_configuration`           | Information about the Web Application Firewall (WAF) configuration, if applicable.                     |

---

## Complex Parameter Explanations

### `frontend_ip_configuration`

Configures the frontend IP for the Application Gateway, which can be public or private. Each frontend IP configuration requires:

- `name`: Name for the frontend IP configuration.
- `public_ip_address_id`: The ID of the public IP address (if public).
- `private_ip_address`: The private IP address (if private).
- `subnet_id`: The subnet ID where the private IP will be assigned.

### `backend_address_pools`

Defines the backend server pool for the Application Gateway. Each pool requires:

- `name`: Unique name for the backend pool.
- `backend_addresses`: List of IP addresses or FQDNs for the backend servers.

### `backend_http_settings`

Defines the backend HTTP settings for the Application Gateway. Each HTTP setting includes:

- `name`: Name of the backend HTTP setting.
- `port`: Port used to connect to the backend servers.
- `protocol`: Protocol (HTTP or HTTPS).
- `cookie_based_affinity`: Whether to enable cookie-based session affinity.

### `ssl_certificates`

Defines the SSL certificates used for SSL offloading at the Application Gateway. Each SSL certificate includes:

- `name`: Name for the SSL certificate.
- `data`: The base64-encoded certificate data.
- `password`: Password for the SSL certificate.

### `url_path_maps`

Defines the URL-based routing rules for the Application Gateway. Each rule includes:

- `name`: Name for the path map.
- `default_backend_address_pool`: Default backend pool for unmatched requests.
- `default_backend_http_settings`: Default HTTP settings for unmatched requests.
- `path_rules`: Specific routing rules based on URL paths.

---

## Additional Information on Parameters

For more detailed descriptions of each parameter and additional configuration options, consult the [Azure Verified Application Gateway Module Documentation on GitHub](https://github.com/Azure/terraform-azurerm-avm-res-network-applicationgateway?tab=readme-ov-file#optional-inputs).

---

## Usage Examples

### Basic Example

```hcl
module "app_gateway" {
  source                = "Azure/avm-app-gateway/azurerm"
  location              = "eastus"
  name                  = "myAppGateway"
  resource_group_name   = "myResourceGroup"
  sku                   = "Standard_v2"

  tags = {
    environment = "dev"
    owner       = "app-team"
  }
}
```

### Example with Backend Pools and Routing Rules

```hcl
module "app_gateway" {
  source                = "Azure/avm-app-gateway/azurerm"
  location              = "westus"
  name                  = "secureAppGateway"
  resource_group_name   = "prodResourceGroup"
  sku                   = "Standard_v2"

  backend_address_pools = [
    {
      name              = "backendPool1"
      backend_addresses = ["10.0.0.4", "10.0.0.5"]
    }
  ]

  url_path_maps = [
    {
      name                      = "pathMap1"
      default_backend_address_pool = "backendPool1"
      path_rules = [
        {
          paths = ["/images/*"]
          backend_address_pool = "imageBackendPool"
        }
      ]
    }
  ]

  tags = {
    environment = "production"
    owner       = "network-team"
  }
}
```

### Example with SSL Termination

```hcl
module "app_gateway_with_ssl" {
  source                = "Azure/avm-app-gateway/azurerm"
  location              = "eastus"
  name                  = "sslAppGateway"
  resource_group_name   = "secureResourceGroup"
  sku                   = "WAF_v2"

  ssl_certificates = [
    {
      name   = "mySSLCert"
      data   = "base64-encoded-cert-data"
      password = "certificate-password"
    }
  ]

  tags = {
    environment = "secure-prod"
    owner       = "security-team"
  }
}
```

### Example Using Custom Probes

```hcl
module "app_gateway_with_probes" {
  source                = "Azure/avm-app-gateway/azurerm"
  location              = "eastus"
  name                  = "appGatewayWithProbes"
  resource_group_name   = "myResourceGroup"
  sku                   = "Standard_v2"

  backend_http_settings = [
    {
      name      = "defaultHttpSetting"
      port      = 80
      protocol  = "HTTP"
      probe     = {
        name                   = "healthProbe"
        protocol               = "HTTP"
        path                   = "/healthcheck"
        interval_in_seconds    = 30
        timeout_in_seconds     = 30
        unhealthy_threshold    = 3
      }
    }
  ]

  tags = {
    environment = "prod"
    owner       = "app-team"
  }
}
```

## Additional Documentation

Explore additional documentation and resources related to this module:

- [Azure Verified Modules - Terraform Resource Modules](https://azure.github.io/Azure-Verified-Modules/indexes/terraform/tf-resource-modules/)
- [Azure Verified Modules - Terraform](https://azure.github.io/Azure-Verified-Modules/indexes/terraform/)
- [Azure Verified Application Gateway Module](https://registry.terraform.io/modules/Azure/avm-app-gateway/azurerm/latest)
- [GitHub Repository for Azure Verified Application Gateway Module](https://github.com/Azure/terraform-azurerm-avm-app-gateway)
- [Azure Application Gateway Documentation](https://learn.microsoft.com/en-us/azure/application-gateway/)
- [Azure Application Gateway Pricing](https://azure.microsoft.com/en-us/pricing/details/application-gateway/)
- [Azure Application Gateway WAF](https://learn.microsoft.com/en-us/azure/application-gateway/intro-waf)
- [How to Configure Azure Application Gateway](https://learn.microsoft.com/en-us/azure/application-gateway/configure-url-based-routing)
- [Azure Application Gateway SSL Termination](https://learn.microsoft.com/en-us/azure/application-gateway/ssl-termination)
- [Azure Application Gateway Diagnostics](https://learn.microsoft.com/en-us/azure/application-gateway/diagnostic-logs)

---