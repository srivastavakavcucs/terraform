# Azure OpenAPI Spec Deployment Terraform Module

This Terraform module deploys an OpenAPI specification to an existing Azure API Management (APIM) service. It provisions the API from an OAS/Swagger spec, applies an XML policy, creates a product, associates the API with the product, and provisions a subscription scoped to that product.

## Table of Contents

- [Azure OpenAPI Spec Deployment Terraform Module](#azure-openapi-spec-deployment-terraform-module)
  - [Table of Contents](#table-of-contents)
  - [Requirements](#requirements)
  - [Providers](#providers)
  - [Resources Created](#resources-created)
  - [Module Usage Example](#module-usage-example)
  - [Input Variables](#input-variables)
    - [Required Inputs](#required-inputs)
    - [Optional Inputs](#optional-inputs)
  - [Additional Details on Complex Inputs](#additional-details-on-complex-inputs)
    - [`api_settings`](#api_settings)
      - [Attributes](#attributes)
      - [Example](#example)
    - [`product_settings`](#product_settings)
      - [Attributes](#attributes-1)
      - [Example](#example-1)
    - [`subscription_settings`](#subscription_settings)
      - [Attributes](#attributes-2)
      - [Example](#example-2)
  - [Outputs](#outputs)
  - [Module Architecture](#module-architecture)
  - [Important Notes](#important-notes)
  - [References](#references)

## Requirements

- **Terraform**: >= 1.9.2
- **Azure Provider (azurerm)**: >= 4.0

## Providers

The module uses the following provider:

- `azurerm`: For managing Azure API Management resources.

## Resources Created

The following resources are created by this module:

- `azurerm_api_management_api.this` - The API resource imported from the OpenAPI spec
- `azurerm_api_management_api_policy.this` - The XML policy applied to the API
- `azurerm_api_management_product.this` - The APIM product
- `azurerm_api_management_product_api.this` - Association between the product and the API
- `azurerm_api_management_subscription.this` - A subscription scoped to the product

## Module Usage Example

```hcl
module "openapi_spec_deployment" {
  source = "./modules/azure_openapi_spec_deployment"

  # APIM Core
  apim_name           = "apim-myservice-prod"
  resource_group_name = "rg-apim-prod"

  # API Spec and Policy (loaded from local files)
  api_spec_content    = file("../openapi/swagger.json")
  api_policy_content  = file("../policies/api-policy.prod.xml")

  # API Configuration
  api_settings = {
    name = "my-api"
    properties = {
      apiRevision          = "1"
      displayName          = "My API"
      description          = "API for My Service"
      path                 = "myservice"
      protocols            = ["https"]
      subscriptionRequired = true
      format               = "openapi+json"
      contact = {
        email = "api-team@example.com"
      }
    }
  }

  # Product Configuration
  product_settings = {
    name = "my-api-product"
    properties = {
      displayName          = "My API Product"
      description          = "Product for My API"
      subscriptionRequired = true
      approvalRequired     = false
      subscriptionsLimit   = 10
      state                = "published"
    }
  }

  # Subscription Configuration
  subscription_settings = {
    name = "my-api-subscription"
    properties = {
      displayName  = "My API Subscription"
      allowTracing = false
    }
  }

  # Subscription State
  subscription_state = "active"
}
```

## Input Variables

### Required Inputs

| Name                    | Description                                                                                   | Type     |
|-------------------------|-----------------------------------------------------------------------------------------------|----------|
| `apim_name`             | Name of the existing API Management service                                                   | string   |
| `resource_group_name`   | Resource group that contains the API Management service                                       | string   |
| `api_settings`          | API configuration object (see details below)                                                  | object   |
| `product_settings`      | Product configuration object (see details below)                                              | object   |
| `subscription_settings` | Subscription configuration object (see details below)                                         | object   |
| `api_spec_content`      | Full OAS/Swagger spec content. Caller uses: `file("../openapi/swagger.json")`                 | string   |
| `api_policy_content`    | Raw XML policy content. Caller uses: `file("../policies/api-policy.<env>.xml")`               | string   |

### Optional Inputs

| Name                 | Description                                    | Type   | Default    | Allowed Values                                                              |
|----------------------|------------------------------------------------|--------|------------|-----------------------------------------------------------------------------|
| `subscription_state` | Initial state of the APIM subscription         | string | `"active"` | `active`, `cancelled`, `expired`, `rejected`, `submitted`, `suspended`      |

## Additional Details on Complex Inputs

### `api_settings`

**Description**:
Mirrors the `api_settings` parameter block used in ARM/Bicep parameter files. Defines the API to be imported into APIM from the OpenAPI specification.

**Type**: `object`

#### Attributes

- **`name`** (string, required): The internal name of the API resource in APIM.

- **`properties`** (object, required):
  - **`apiRevision`** (string, required): The API revision identifier (e.g., `"1"`).
  - **`displayName`** (string, required): Human-readable name shown in the APIM developer portal.
  - **`path`** (string, required): The URL path suffix appended to the APIM gateway URL.
  - **`protocols`** (list(string), required): Protocols the API accepts (e.g., `["https"]`).
  - **`subscriptionRequired`** (bool, required): Whether a subscription key is required to call the API.
  - **`apiType`** (string, optional, default: `"http"`): The API type.
  - **`description`** (string, optional, default: `""`): Description shown in the developer portal.
  - **`format`** (string, optional, default: `"openapi"`): The format of the imported spec (e.g., `"openapi"`, `"openapi+json"`, `"swagger-json"`).
  - **`subscriptionKeyParameterNames`** (object, optional): Custom names for the subscription key parameters.
    - **`header`** (string, optional, default: `"Ocp-Apim-Subscription-Key"`): Header name for the subscription key.
    - **`query`** (string, optional, default: `"subscription-key"`): Query parameter name for the subscription key.
  - **`contact`** (object, optional): Contact information for the API.
    - **`email`** (string, optional, default: `""`): Contact email address displayed in the developer portal.

#### Example

```hcl
api_settings = {
  name = "my-api"
  properties = {
    apiRevision          = "1"
    displayName          = "My API"
    description          = "REST API for My Service"
    path                 = "myservice"
    protocols            = ["https"]
    subscriptionRequired = true
    format               = "openapi+json"
    subscriptionKeyParameterNames = {
      header = "Ocp-Apim-Subscription-Key"
      query  = "subscription-key"
    }
    contact = {
      email = "api-team@example.com"
    }
  }
}
```

---

### `product_settings`

**Description**:
Mirrors the `product_settings` parameter block used in ARM/Bicep parameter files. Defines the APIM product under which the API will be grouped and accessed.

**Type**: `object`

#### Attributes

- **`name`** (string, required): The internal product identifier used as `product_id` in APIM.

- **`properties`** (object, required):
  - **`displayName`** (string, required): Human-readable name of the product shown in the developer portal.
  - **`description`** (string, optional, default: `""`): Description of the product. Defaults to `"Product for {name}"` if empty.
  - **`subscriptionRequired`** (bool, optional, default: `true`): Whether a subscription is required to access the product. When `false`, `approvalRequired` and `subscriptionsLimit` are ignored.
  - **`approvalRequired`** (bool, optional, default: `false`): Whether subscription requests require admin approval. Only applied when `subscriptionRequired = true`.
  - **`subscriptionsLimit`** (number, optional, default: `null`): Maximum number of concurrent subscriptions. Only applied when `subscriptionRequired = true`.
  - **`state`** (string, optional, default: `"published"`): Publication state of the product (`"published"` or `"notPublished"`).
  - **`terms`** (string, optional, default: `null`): Terms of use displayed to subscribers.

#### Example

```hcl
product_settings = {
  name = "my-api-product"
  properties = {
    displayName          = "My API Product"
    description          = "Grants access to My Service API"
    subscriptionRequired = true
    approvalRequired     = false
    subscriptionsLimit   = 10
    state                = "published"
    terms                = "By subscribing, you agree to the terms of use."
  }
}
```

---

### `subscription_settings`

**Description**:
Mirrors the `subscription_settings` parameter block used in ARM/Bicep parameter files. Defines the APIM subscription that grants access to the product.

**Type**: `object`

#### Attributes

- **`name`** (string, required): The internal subscription identifier in APIM.

- **`properties`** (object, required):
  - **`displayName`** (string, required): Human-readable name of the subscription shown in the APIM portal.
  - **`allowTracing`** (bool, required): Whether request tracing is enabled for this subscription.

#### Example

```hcl
subscription_settings = {
  name = "my-api-subscription"
  properties = {
    displayName  = "My API Subscription"
    allowTracing = false
  }
}
```

## Outputs

| Name                        | Description                                                   | Sensitive |
|-----------------------------|---------------------------------------------------------------|-----------|
| `api_id`                    | The resource ID of the APIM API                               | No        |
| `api_name`                  | The name of the APIM API                                      | No        |
| `product_id`                | The resource ID of the APIM product                           | No        |
| `product_name`              | The product_id (name) of the APIM product                     | No        |
| `subscription_id`           | The resource ID of the APIM subscription                      | No        |
| `subscription_primary_key`  | The primary key of the APIM subscription                      | Yes       |
| `subscription_secondary_key`| The secondary key of the APIM subscription                    | Yes       |

## Module Architecture

### Resource Creation Flow

1. **API**: Imports the API into APIM using the provided OpenAPI/Swagger spec content and applies the configuration from `api_settings`.
2. **API Policy**: Attaches the raw XML policy to the API immediately after creation.
3. **Product**: Creates an APIM product using the configuration from `product_settings`. When `subscriptionRequired = false`, `approvalRequired` and `subscriptionsLimit` are automatically set to `null` to match APIM API constraints.
4. **Product-API Association**: Links the API to the product so the API is accessible through the product.
5. **Subscription**: Creates a subscription scoped to the product, providing the primary and secondary keys used by API consumers.

### Dependency Chain

```
azurerm_api_management_api
  └── azurerm_api_management_api_policy
  └── azurerm_api_management_product
        └── azurerm_api_management_product_api
              └── azurerm_api_management_subscription
```

## Important Notes

- **Pre-existing APIM required**: This module does not create the API Management service. The `apim_name` must reference an already-deployed APIM instance.
- **Spec content loaded by caller**: `api_spec_content` and `api_policy_content` are strings passed by the calling module. Use Terraform's `file()` function to load from local files (e.g., `file("../openapi/swagger.json")`).
- **Subscription keys are sensitive outputs**: `subscription_primary_key` and `subscription_secondary_key` are marked sensitive. Use `nonsensitive()` or reference them only in secure contexts.
- **Subscription state**: The `subscription_state` variable controls the initial state of the subscription and can be set independently from the `subscription_settings` object, making it easy to toggle per environment without changing the core settings block.
- **Product description fallback**: If `product_settings.properties.description` is an empty string, the module defaults the description to `"Product for {product_name}"`.
- **Approval and subscription limits**: `approvalRequired` and `subscriptionsLimit` on the product are conditionally null when `subscriptionRequired = false`, matching the behaviour of the equivalent Bicep `union()` logic.
- **Contact block**: The `contact` block on the API is only rendered when a non-empty email is provided, avoiding APIM validation errors on empty contact objects.

## References

- **Azure API Management Documentation**: [Azure API Management](https://learn.microsoft.com/en-us/azure/api-management/api-management-key-concepts)
- **Import API from OpenAPI Spec**: [Import an OpenAPI specification](https://learn.microsoft.com/en-us/azure/api-management/import-api-from-oas)
- **APIM Products**: [Create and publish a product](https://learn.microsoft.com/en-us/azure/api-management/api-management-howto-add-products)
- **APIM Subscriptions**: [Subscriptions in API Management](https://learn.microsoft.com/en-us/azure/api-management/api-management-subscriptions)
- **Terraform azurerm_api_management_api**: [Terraform Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/api_management_api)
- **Terraform azurerm_api_management_product**: [Terraform Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/api_management_product)
- **Terraform azurerm_api_management_subscription**: [Terraform Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/api_management_subscription)
