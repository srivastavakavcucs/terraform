# Azure Service Fabric Managed Cluster Application Terraform Module

This Terraform module deploys applications to an Azure Service Fabric Managed Cluster (SFMC). It provides a streamlined way to manage application types, versions, and stateless services within a Service Fabric Managed Cluster environment using the Azure API provider.

## Table of Contents

- [Azure Service Fabric Managed Cluster Application Terraform Module](#azure-service-fabric-managed-cluster-application-terraform-module)
  - [Table of Contents](#table-of-contents)
  - [Requirements](#requirements)
  - [Providers](#providers)
  - [Resources Created](#resources-created)
  - [Data Sources Used](#data-sources-used)
  - [Module Usage Example](#module-usage-example)
  - [Input Variables](#input-variables)
    - [Required Inputs](#required-inputs)
  - [Additional Details on Complex Inputs](#additional-details-on-complex-inputs)
    - [`upgrade_policy`](#upgrade_policy)
      - [Attributes](#attributes)
      - [Example](#example)
    - [`application_parameters`](#application_parameters)
      - [Example](#example-1)
  - [Outputs](#outputs)
  - [Module Architecture](#module-architecture)
  - [Important Notes](#important-notes)
  - [References](#references)

## Requirements

- **Terraform**: >= 1.92
- **Azure API Provider (azapi)**: ~> 1.0

## Providers

The module uses the following provider:

- `azapi`: For Azure API integration to manage Service Fabric Managed Cluster resources.

## Resources Created

The following resources are created by this module:

- `azapi_resource.sfmc_app_type` - Service Fabric Application Type
- `azapi_resource.sfmc_app_type_version` - Service Fabric Application Type Version
- `azapi_resource.sfmc_application` - Service Fabric Application
- `azapi_resource.sfmc_services` - Service Fabric Services (one or more stateless services)

## Data Sources Used

### Service Fabric Managed Cluster (`sfmc`)
References an existing Service Fabric Managed Cluster where the application will be deployed.

### Managed Identity (`sfmc_managed_identity`)
Retrieves an existing User Assigned Managed Identity used for application deployment and runtime operations.

### Azure Client Configuration (`current`)
Gets current Azure subscription details for resource ID construction.

## Module Usage Example

Example usage of this module:

```hcl
module "sfmc_application" {
  source = "./modules/azure_sfmc_app"

  # Cluster Configuration
  cluster_name                     = "mysfcluster"
  location                         = "eastus"
  sfmc_cluster_resource_group_name = "rg-sfmc-cluster-prod"

  # Application Type Configuration
  application_type_name    = "MyApplicationType"
  application_type_version = "1.0.0"
  app_package_url          = "https://mystorageaccount.blob.core.windows.net/packages/MyApp_1.0.0.sfpkg"

  # Application Configuration
  application_name = "MyApplication"

  # Service Configuration
  service_names = [
    "MyWebService",
    "MyApiService",
    "MyBackgroundService"
  ]
  instance_count        = 3
  placement_constraints = "(NodeType==Frontend)"

  # Identity Configuration
  sfmc_resource_group_name   = "rg-sfmc-identities-prod"
  sfmc_managed_identity_name = "mi-sfmc-app-deployer"

  # Application Parameters
  application_parameters = {
    "WebService_InstanceCount"  = "3"
    "ApiService_Port"           = "8080"
    "BackgroundService_Enabled" = "true"
    "LogLevel"                  = "Information"
  }

  # Upgrade Policy
  upgrade_policy = {
    applicationHealthPolicy = {
      considerWarningAsError                  = false
      maxPercentUnhealthyDeployedApplications = 90
    }
    forceRestart               = false
    instanceCloseDelayDuration = 10
    recreateApplication        = false
    rollingUpgradeMonitoringPolicy = {
      failureAction             = "Rollback"
      healthCheckRetryTimeout   = "01:00:00"
      healthCheckStableDuration = "00:01:00"
      healthCheckWaitDuration   = "00:01:00"
      upgradeDomainTimeout      = "02:00:00"
      upgradeTimeout            = "02:00:00"
    }
    upgradeReplicaSetCheckTimeout = 10
    upgradeMode                   = "Monitored"
  }
}
```

## Input Variables

### Required Inputs

| Name                                | Description                                                                                 | Type         |
|-------------------------------------|---------------------------------------------------------------------------------------------|--------------|
| `cluster_name`                      | Name of the Service Fabric Managed Cluster (3-23 characters, letters and numbers only)     | string       |
| `location`                          | Azure region where resources will be deployed                                               | string       |
| `application_type_name`             | The application type name                                                                   | string       |
| `application_type_version`          | The application type version (e.g., "1.0.0")                                                | string       |
| `app_package_url`                   | The URL to the application package sfpkg file (must be accessible from Azure)               | string       |
| `application_name`                  | The name of the application resource                                                        | string       |
| `service_names`                     | An array of service names to deploy                                                         | list(string) |
| `instance_count`                    | The number of instances for each service                                                    | number       |
| `placement_constraints`             | The placement constraints for service instances (e.g., "(NodeType==Frontend)")                | string       |
| `sfmc_resource_group_name`          | The name of the resource group containing the SFMC user-assigned managed identity           | string       |
| `sfmc_cluster_resource_group_name`  | The name of the resource group containing the SFMC cluster                                  | string       |
| `sfmc_managed_identity_name`        | SFMC User-assigned managed identity name                                                    | string       |
| `application_parameters`            | A map of application parameters to configure the application                                | map(string)  |
| `upgrade_policy`                    | The upgrade policy configuration (see details below)                                        | object       |

## Additional Details on Complex Inputs

### `upgrade_policy`

**Description**:
Defines the upgrade policy for the Service Fabric application, including health policies and monitoring settings for rolling upgrades.

**Type**: `object`

#### Attributes

- **`applicationHealthPolicy`** (object, required): Health policy for the application during upgrades
  - **`considerWarningAsError`** (bool): Whether to treat warnings as errors during health evaluation
  - **`maxPercentUnhealthyDeployedApplications`** (number): Maximum percentage of unhealthy deployed applications allowed (0-100)

- **`forceRestart`** (bool, required): Whether to force restart of services during upgrade

- **`instanceCloseDelayDuration`** (number, required): Duration in seconds to wait before closing instances during upgrade

- **`recreateApplication`** (bool, required): Whether to recreate the application during upgrade

- **`rollingUpgradeMonitoringPolicy`** (object, required): Monitoring policy for rolling upgrades
  - **`failureAction`** (string): Action to take on failure (e.g., "Rollback", "Manual")
  - **`healthCheckRetryTimeout`** (string): Health check retry timeout duration (format: "HH:MM:SS")
  - **`healthCheckStableDuration`** (string): Duration for health check stability (format: "HH:MM:SS")
  - **`healthCheckWaitDuration`** (string): Duration to wait before health checks (format: "HH:MM:SS")
  - **`upgradeDomainTimeout`** (string): Timeout for upgrade domain (format: "HH:MM:SS")
  - **`upgradeTimeout`** (string): Overall upgrade timeout (format: "HH:MM:SS")

- **`upgradeReplicaSetCheckTimeout`** (number, required): Timeout in seconds for replica set check

- **`upgradeMode`** (string, required): The upgrade mode (e.g., "Monitored", "UnmonitoredAuto")

#### Example

```hcl
upgrade_policy = {
  applicationHealthPolicy = {
    considerWarningAsError                  = false
    maxPercentUnhealthyDeployedApplications = 90
  }
  forceRestart               = false
  instanceCloseDelayDuration = 10
  recreateApplication        = false
  rollingUpgradeMonitoringPolicy = {
    failureAction             = "Rollback"
    healthCheckRetryTimeout   = "01:00:00"
    healthCheckStableDuration = "00:01:00"
    healthCheckWaitDuration   = "00:01:00"
    upgradeDomainTimeout      = "02:00:00"
    upgradeTimeout            = "02:00:00"
  }
  upgradeReplicaSetCheckTimeout = 10
  upgradeMode                   = "Monitored"
}
```

### `application_parameters`

**Description**:
A map of application parameters used to configure the Service Fabric application at deployment time. These parameters override default values defined in the application manifest.

**Type**: `map(string)`

#### Example

```hcl
application_parameters = {
  "WebService_InstanceCount"      = "5"
  "ApiService_Port"               = "8080"
  "ApiService_MinReplicaSetSize"  = "3"
  "BackgroundService_Enabled"     = "true"
  "ConnectionString"              = "Server=myserver;Database=mydb"
  "LogLevel"                      = "Information"
  "FeatureFlags_EnableNewUI"      = "false"
}
```

## Outputs

| Name                          | Description                                                    |
|-------------------------------|----------------------------------------------------------------|
| `application_id`              | The ID of the Service Fabric application                       |
| `application_name`            | The name of the Service Fabric application                     |
| `application_type_id`         | The ID of the Service Fabric application type                  |
| `application_type_version_id` | The ID of the Service Fabric application type version          |
| `service_ids`                 | Map of service names to their resource IDs                     |

## Module Architecture

### Resource Creation Flow

1. **Application Type**: Creates the application type definition in the SFMC cluster
2. **Application Type Version**: Creates a version of the application type and links it to the application package URL
3. **Application**: Deploys the application instance with:
   - User-assigned managed identity
   - Application parameters
   - Upgrade policy configuration
4. **Services**: Creates stateless services for each service name specified, with:
   - Singleton partition scheme
   - Exclusive process activation mode
   - Configurable instance count
   - Placement constraints

### Service Configuration

All services created by this module are configured as:
- **Service Kind**: Stateless
- **Partition Scheme**: Singleton
- **Activation Mode**: ExclusiveProcess
- **Service Type Name**: `{ServiceName}Type` (automatically derived from service name)

## Important Notes

- **Cluster Name Validation**: The `cluster_name` must be between 3 and 23 characters and contain only letters and numbers.
- **Stateless Services Only**: This module currently creates only stateless services. For stateful services, modifications to the service resource configuration are required.
- **Application Package**: The `app_package_url` must point to a valid Service Fabric application package (`.sfpkg` file) that is publicly accessible or accessible via managed identity.
- **Managed Identity**: The module requires a user-assigned managed identity with appropriate permissions:
  - Read access to the application package storage location
  - Permissions to deploy applications to the Service Fabric Managed Cluster
- **Placement Constraints**: Use placement constraints to control node placement:
  - `"(NodeType==Frontend)"` - Deploy only on Frontend nodes
  - `"(NodeType!=Backend")` - Avoid Backend nodes
  - Multiple constraints can be combined with logical operators
- **Service Type Naming**: Service type names are automatically derived by appending "Type" to the service name (e.g., service "MyWebService" uses type "MyWebServiceType"). Ensure your application manifest defines matching service types.
- **Upgrade Policy**: The upgrade policy is required and must be fully specified. There are no default values in this module.
- **Resource Dependencies**: The module automatically handles dependencies:
  - Application Type Version depends on Application Type
  - Application depends on both Application Type and Application Type Version
  - Services depend on the Application
- **API Version**: This module uses the `2022-01-01` API version for Service Fabric Managed Cluster resources.

## References

- **Azure Service Fabric Managed Clusters Documentation**: [Azure Service Fabric Managed Clusters](https://learn.microsoft.com/en-us/azure/service-fabric/overview-managed-cluster)
- **Azure Service Fabric Deployment via Azure Resource Manager Documentation**: [Azure Service Fabric Deployment via Azure Resource Manager](https://learn.microsoft.com/en-us/azure/service-fabric/how-to-managed-cluster-app-deployment-template)
- **Service Fabric Application Terraform Documentation**: [Terraform Documetation](https://learn.microsoft.com/en-us/azure/templates/microsoft.servicefabric/managedclusters/applications?pivots=deployment-language-terraform)