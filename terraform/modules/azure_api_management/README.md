# **Azure API Management Terraform Module**

---

## **Table of Contents**

- [**Azure API Management Terraform Module**](#azure-api-management-terraform-module)
  - [**Table of Contents**](#table-of-contents)
  - [**Introduction**](#introduction)
  - [**Basic Usage Example**](#basic-usage-example)
  - [**Detailed Usage Example**](#detailed-usage-example)
  - [**Variables**](#variables)
    - [**Required Variables**](#required-variables)
    - [**Optional Variables**](#optional-variables)
    - [**Complex Variable Explanations**](#complex-variable-explanations)
      - [**`identity`**](#identity)
      - [**`additional_locations`**](#additional_locations)
      - [**`certificate`**](#certificate)
      - [**`hostname_configuration`**](#hostname_configuration)
        - [**Sub-objects of `hostname_configuration`**](#sub-objects-of-hostname_configuration)
      - [**`protocols`**](#protocols)
      - [**`security`**](#security)
      - [**`sign_in`**](#sign_in)
      - [**`sign_up`**](#sign_up)
  - [**Outputs**](#outputs)
  - [**Additional Documentation**](#additional-documentation)

---

## **Introduction**

This Terraform module provisions an **Azure API Management** service. It supports a wide range of configuration options, including multiple deployment regions, network configurations, hostname settings, identity options, and security settings. This module is designed to simplify API Management setup by providing a reusable, consistent configuration that complies with Azure best practices.

---

## **Basic Usage Example**

```hcl
module "api_management" {
  source = "./modules/api_management"

  region                    = "eastus"
  app_name                  = "example-app"
  environment               = "prod"
  environment_number_suffix = "001"

  publisher_email = "admin@example.com"

  common_tags = {
    Project     = "MyAPI"
    Environment = "Production"
  }
}
```

---

## **Detailed Usage Example**

```hcl
module "api_management" {
  source = "./modules/api_management"

  region                    = "eastus"
  app_name                  = "my-api-app"
  environment               = "staging"
  environment_number_suffix = "002"

  publisher_email = "contact@mycompany.com"
  publisher_name  = "MyCompany"
  sku_name        = "Premium"
  sku_capacity    = 3

  identity = {
    type         = "SystemAssigned"
    identity_ids = []
  }

  additional_locations = {
    "westus" = {
      location                      = "westus"
      capacity                      = 1
      zones                         = ["1", "2"]
      public_ip_address_id          = "/subscriptions/xxx/resourceGroups/rg/providers/Microsoft.Network/publicIPAddresses/public-ip-westus"
      virtual_network_configuration = {
        subnet_id = "/subscriptions/xxx/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet-westus/subnets/subnet1"
      }
      gateway_disabled = false
    }
  }

  certificate = {
    encoded_certificate  = "Base64EncodedCertificateContent"
    store_name           = "Root"
    certificate_password = "mypassword"
  }

  delegation = {
    subscriptions_enabled     = true
    user_registration_enabled = true
    url                       = "https://my-auth-server.com/delegation"
    validation_key            = "Base64EncodedValidationKey"
  }

  hostname_configuration = {
    management = [{
      host_name                       = "management.api.mycompany.com"
      key_vault_id                    = null
      certificate                     = "Base64EncodedManagementCertificate"
      certificate_password            = "password123"
      negotiate_client_certificate    = false
      ssl_keyvault_identity_client_id = null
    }]
    portal = [{
      host_name                       = "portal.api.mycompany.com"
      key_vault_id                    = null
      certificate                     = "Base64EncodedPortalCertificate"
      certificate_password            = "portalpassword"
      negotiate_client_certificate    = false
      ssl_keyvault_identity_client_id = null
    }]
    developer_portal = [{
      host_name                       = "developer.api.mycompany.com"
      key_vault_id                    = null
      certificate                     = "Base64EncodedDeveloperPortalCertificate"
      certificate_password            = "developerpassword"
      negotiate_client_certificate    = false
      ssl_keyvault_identity_client_id = null
    }]
    proxy = [{
      host_name                       = "proxy.api.mycompany.com"
      key_vault_id                    = null
      certificate                     = "Base64EncodedProxyCertificate"
      certificate_password            = "proxypassword"
      negotiate_client_certificate    = false
      ssl_keyvault_identity_client_id = null
      default_ssl_binding             = true
    }]
    scm = [{
      host_name                       = "scm.api.mycompany.com"
      key_vault_id                    = null
      certificate                     = "Base64EncodedScmCertificate"
      certificate_password            = "scmpassword"
      negotiate_client_certificate    = false
      ssl_keyvault_identity_client_id = null
    }]
  }

  protocols = {
    enable_http2 = true
  }

  security = {
    enable_backend_ssl30  = false
    enable_backend_tls10  = false
    enable_backend_tls11  = false
    enable_frontend_ssl30 = false
    enable_frontend_tls10 = true
    enable_frontend_tls11 = false
  }

  sign_in = {
    enabled = true
  }

  sign_up = {
    enabled = true
    terms_of_service = {
      consent_required = true
      enabled          = true
      text             = "By signing up, you agree to our terms of service."
    }
  }

  tenant_access = {
    enabled = true
  }

  public_network_access_enabled = true

  virtual_network_type = "Internal"
  virtual_network_configuration = {
    subnet_id = "/subscriptions/xxx/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet-eastus/subnets/subnet1"
  }

  common_tags = {
    Project     = "MyAPIManagement"
    Environment = "Staging"
  }

  resource_tags = {
    Application = "API Management Service"
  }
}
```

---

## **Variables**

### **Required Variables**

| Name                     | Type   | Description                                                   |
|--------------------------|--------|---------------------------------------------------------------|
| `region`                 | string | Azure region where the resource should be deployed (`eastus`, `westus`). |
| `app_name`               | string | The name of the application that will be deployed.             |
| `environment`            | string | The target environment abbreviation for naming.                |
| `environment_number_suffix` | string | The environment number suffix for resource naming.             |
| `publisher_email`        | string | The email address for the publisher.                           |

---

### **Optional Variables**

| Name                       | Type   | Description                                                                                   | Default                      |
|----------------------------|--------|-----------------------------------------------------------------------------------------------|------------------------------|
| `publisher_name`           | string | Name of the API Management publisher.                                                         | `"VyStar Credit Union"`       |
| `sku_name`                 | string | SKU of the API Management service (`Consumption`, `Developer`, `Standard`, `Premium`).        | `"Premium"`                   |
| `sku_capacity`             | number | Number of units (must be `0` for `Consumption`).                                               | `12`                          |
| `additional_locations`     | map    | Additional API Management locations and configuration.                                         | `{}`                          |
| `certificate`              | object | Certificate block containing `encoded_certificate`, `store_name`, `certificate_password`.      | `null`                        |
| `client_certificate_enabled` | bool | Whether client certificates are enforced (`Consumption` SKU only).                            | `false`                       |
| `delegation`               | object | Delegation block for subscription and user registration delegation.                           | `null`                        |
| `hostname_configuration`   | object | Hostname configuration block for API Management service.                                       | `null`                        |
| `protocols`                | object | Specifies if HTTP/2 is enabled.                                                                | `{ enable_http2 = false }`    |
| `security`                 | object | Security protocol and cipher configurations for the API Management service.                    | `null`                        |
| `sign_in`                  | object | Sign-in block containing `enabled` to determine if users are redirected to the sign-in page.   | `{ enabled = true }`          |
| `sign_up`                  | object | Sign-up block containing `enabled` and `terms_of_service`.                                     | `null`                        |
| `tenant_access`            | object | Specifies if tenant access to the management API is enabled.                                   | `null`                        |
| `public_network_access_enabled` | bool | Specifies whether public access to the API Management service is allowed.                     | `true`                        |
| `virtual_network_type`     | string | Type of virtual network (`None`, `External`, `Internal`).                                      | `"None"`                      |
| `virtual_network_configuration` | object | Virtual network configuration block containing the `subnet_id`.                                | `null`                        |
| `notification_sender_email`| string | The email address from which notifications are sent.                                           | `null`                        |
| `common_tags`              | map    | Common tags applied to all resources.                                                          | N/A                           |
| `resource_tags`            | map    | Tags applied to specific resources.                                                            | `{}`                          |

---

### **Complex Variable Explanations**

#### **`identity`**

Defines the managed service identity (MSI) type:

| Name          | Type   | Required/Optional | Description                                                                 | Default Value                  |
|---------------|--------|------------------|-----------------------------------------------------------------------------|---------------------------------|
| `type`        | string | Required          | Specifies the type of identity (`SystemAssigned`, `UserAssigned`, or both). | N/A                             |
| `identity_ids`| list   | Optional          | List of user-assigned identity IDs (if `UserAssigned` is used).              | `[]`                            |

---

#### **`additional_locations`**

Specifies additional regions for API Management:

| Name                         | Type   | Required/Optional | Description                                                                                      | Default Value |
|------------------------------|--------|------------------|--------------------------------------------------------------------------------------------------|--------------|
| `location`                    | string | Required          | Specifies the Azure region for the additional location.                                           | N/A          |
| `capacity`                    | number | Optional          | Specifies the number of compute units in the additional location.                                 | `null`       |
| `zones`                       | list   | Optional          | A list of availability zones (only supported for the `Premium` SKU).                              | `[]`         |
| `public_ip_address_id`         | string | Optional          | Specifies the ID of the public IP address for the additional location.                            | `null`       |
| `virtual_network_configuration`| object | Optional          | Contains the `subnet_id` for the virtual network configuration.                                   | `null`       |
| `subnet_id`                    | string | Required when `virtual_network_type` is `External` or `Internal` | The ID of the subnet for the additional location. | N/A |
| `gateway_disabled`             | bool   | Optional          | Indicates whether the API gateway is disabled in this additional location.                        | `false`      |

---

#### **`certificate`**

Contains SSL certificate configuration:

| Name                 | Type   | Required/Optional | Description                                                  | Default Value |
|----------------------|--------|------------------|--------------------------------------------------------------|--------------|
| `encoded_certificate`| string | Required          | The Base64-encoded certificate content.                      | N/A          |
| `store_name`         | string | Required          | Specifies the store where the certificate is placed (`Root` or `CertificateAuthority`). | N/A          |
| `certificate_password`| string | Optional          | The password for the certificate, if applicable.              | `null`       |

---

#### **`hostname_configuration`**

This block configures custom hostnames for various endpoints of the API Management service.

##### **Sub-objects of `hostname_configuration`**

| Sub-object        | Description                                                       |
|-------------------|-------------------------------------------------------------------|
| `management`      | Specifies custom hostnames for the management API.                |
| `portal`          | Specifies custom hostnames for the publisher portal.              |
| `developer_portal`| Specifies custom hostnames for the developer portal.              |
| `proxy`           | Specifies custom hostnames for the API proxy.                     |
| `scm`             | Specifies custom hostnames for the source control management (SCM). |

---

Each sub-object supports the following attributes:

| Name                         | Type   | Required/Optional | Description                                                                                      | Default Value |
|------------------------------|--------|------------------|--------------------------------------------------------------------------------------------------|--------------|
| `host_name`                   | string | Required          | The custom hostname to be used for the API Management component (e.g., `api.mycompany.com`).      | N/A          |
| `key_vault_id`                | string | Optional          | The Azure Key Vault secret ID containing the SSL certificate.                                     | `null`       |
| `certificate`                 | string | Optional          | Base64-encoded SSL certificate (if not using Key Vault).                                          | `null`       |
| `certificate_password`        | string | Optional          | The password for the SSL certificate (if applicable).                                             | `null`       |
| `negotiate_client_certificate`| bool   | Optional          | Specifies whether client certificate negotiation should be enabled for this hostname.             | `false`      |
| `ssl_keyvault_identity_client_id` | string | Optional          | Specifies the client ID of the managed identity used to access the Key Vault containing the SSL certificate. | `null` |
| `default_ssl_binding`         | bool   | Optional (only for `proxy`) | Specifies whether this certificate is the default SSL binding for the proxy.                      | `false`      |

---

#### **`protocols`**

Defines communication protocols:

| Name         | Type   | Required/Optional | Description                          | Default Value |
|--------------|--------|------------------|--------------------------------------|--------------|
| `enable_http2`| bool  | Optional           | Indicates whether HTTP/2 is enabled. | `false`      |

---

#### **`security`**

Specifies security protocol and cipher configurations:

| Name                               | Type   | Required/Optional | Description                                      | Default Value |
|------------------------------------|--------|------------------|--------------------------------------------------|--------------|
| `enable_backend_ssl30`             | bool   | Optional          | Enable/disable SSL 3.0 on the backend.           | `false`      |
| `enable_backend_tls10`             | bool   | Optional          | Enable/disable TLS 1.0 on the backend.           | `false`      |
| `enable_backend_tls11`             | bool   | Optional          | Enable/disable TLS 1.1 on the backend.           | `false`      |
| `enable_frontend_ssl30`            | bool   | Optional          | Enable/disable SSL 3.0 on the frontend.          | `false`      |
| `enable_frontend_tls10`            | bool   | Optional          | Enable/disable TLS 1.0 on the frontend.          | `false`      |
| `enable_frontend_tls11`            | bool   | Optional          | Enable/disable TLS 1.1 on the frontend.          | `false`      |
| `triple_des_ciphers_enabled`       | bool   | Optional          | Enable/disable Triple DES cipher.                |`false`       |

---

#### **`sign_in`**

Configures the sign-in settings for the developer portal:

| Name     | Type   | Required/Optional | Description                                           | Default Value |
|----------|--------|------------------|------------------------------------------------------|--------------|
| `enabled`| bool   | Required          | Indicates if anonymous users should be redirected to the sign-in page. | `true` |

---

#### **`sign_up`**

Configures the sign-up page for the developer portal:

| Name             | Type   | Required/Optional | Description                           | Default Value |
|------------------|--------|------------------|---------------------------------------|--------------|
| `enabled`        | bool   | Required          | Indicates if user sign-up is allowed.  | N/A          |
| `terms_of_service`| object | Required          | Contains the terms of service that users must accept. | N/A |

**`terms_of_service` object attributes:**

| Name             | Type   | Required/Optional | Description                                       | Default Value |
|------------------|--------|------------------|--------------------------------------------------|--------------|
| `consent_required`| bool  | Required          | Indicates if consent is required.                 | N/A          |
| `enabled`        | bool   | Required          | Indicates if the terms of service are displayed. | N/A          |
| `text`           | string | Required          | The terms of service text.                       | N/A          |

---

## **Outputs**

| Output         | Description                                   |
|----------------|-----------------------------------------------|
| `id`           | The ID of the created API Management Service. |
| `gateway_url`  | The URL of the API Gateway.                    |
| `portal_url`   | The URL of the Developer Portal.               |

---

## **Additional Documentation**

1. [Azure API Management Documentation](https://learn.microsoft.com/en-us/azure/api-management/)  
   Overview of Azure API Management, including key features and use cases.

2. [API Management Key Concepts](https://learn.microsoft.com/en-us/azure/api-management/api-management-key-concepts)  
   Detailed descriptions of API Management terminology and components.

3. [Azure API Management Pricing](https://azure.microsoft.com/en-us/pricing/details/api-management/)  
   Azure API Management SKU pricing and details for all tiers.

4. [Terraform `azurerm_api_management` Resource Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/api_management)  
   Terraform documentation for the `azurerm_api_management` resource, including available options and configurations.
