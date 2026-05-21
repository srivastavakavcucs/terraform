#--------------------------------------------------------
# Common Required Inputs
#--------------------------------------------------------

variable "region" {
  description = "Azure region where the resource should be deployed. Allowed values are 'eastus' or 'westus'."
  type        = string
}

variable "app_name" {
  type        = string
  description = "Name of the VyStar application that will be deployed."
}

variable "environment" {
  type        = string
  description = "Target environment abbreviation for naming."
}

variable "environment_number_suffix" {
  type        = string
  description = "Environment number suffix for naming."
}

#--------------------------------------------------------
# Module Required Inputs
#--------------------------------------------------------

# Private Connection Resource
variable "private_connection_resource" {
  description = <<-EOF
    (Required) Object containing the details of the Remote Resource to which the private endpoint will connect.

    Valid options for the resource type of the Private Link Enabled Remote Resource are:

    - Application Gateway: "Microsoft.Network/applicationGateways"
    - Azure AI Search: "Microsoft.Search/searchServices"
    - Azure AI services: "Microsoft.CognitiveServices/accounts"
    - Azure API for FHIR: "Microsoft.HealthcareApis/services"
    - Azure API Management: "Microsoft.ApiManagement/service"
    - Azure App Configuration: "Microsoft.AppConfiguration/configurationStores"
    - Azure App Service (hosting environments): "Microsoft.Web/hostingEnvironments"
    - Azure App Service (sites): "Microsoft.Web/sites"
    - Azure Attestation Service: "Microsoft.Attestation/attestationProviders"
    - Azure Automation: "Microsoft.Automation/automationAccounts"
    - Azure Backup: "Microsoft.RecoveryServices/vaults"
    - Azure Batch: "Microsoft.Batch/batchAccounts"
    - Azure Cache for Redis: "Microsoft.Cache/Redis"
    - Azure Cache for Redis Enterprise: "Microsoft.Cache/redisEnterprise"
    - Azure Container Registry: "Microsoft.ContainerRegistry/registries"
    - Azure Cosmos DB: "Microsoft.AzureCosmosDB/databaseAccounts"
    - Azure Cosmos DB for MongoDB vCore: "Microsoft.DocumentDB/mongoClusters"
    - Azure Cosmos DB for PostgreSQL: "Microsoft.DBforPostgreSQL/serverGroupsv2"
    - Azure Data Explorer: "Microsoft.Kusto/clusters"
    - Azure Data Factory: "Microsoft.DataFactory/factories"
    - Azure Database for MariaDB: "Microsoft.DBforMariaDB/servers"
    - Azure Database for MySQL - Flexible Server: "Microsoft.DBforMySQL/flexibleServers"
    - Azure Database for MySQL - Single Server: "Microsoft.DBforMySQL/servers"
    - Azure Database for PostgreSQL - Flexible Server: "Microsoft.DBforPostgreSQL/flexibleServers"
    - Azure Database for PostgreSQL - Single Server: "Microsoft.DBforPostgreSQL/servers"
    - Azure Databricks: "Microsoft.Databricks/workspaces"
    - Azure Device Provisioning Service: "Microsoft.Devices/provisioningServices"
    - Azure Digital Twins: "Microsoft.DigitalTwins/digitalTwinsInstances"
    - Azure Event Grid (domains): "Microsoft.EventGrid/domains"
    - Azure Event Grid (topics): "Microsoft.EventGrid/topics"
    - Azure Event Hub: "Microsoft.EventHub/namespaces"
    - Azure File Sync: "Microsoft.StorageSync/storageSyncServices"
    - Azure HDInsight: "Microsoft.HDInsight/clusters"
    - Azure IoT Central: "Microsoft.IoTCentral/IoTApps"
    - Azure IoT Hub: "Microsoft.Devices/IotHubs"
    - Azure Key Vault: "Microsoft.KeyVault/vaults"
    - Azure Key Vault HSM: "Microsoft.KeyVault/managedHSMs"
    - Azure Kubernetes Service - Kubernetes API: "Microsoft.ContainerService/managedClusters"
    - Azure Machine Learning (registries): "Microsoft.MachineLearningServices/registries"
    - Azure Machine Learning (workspaces): "Microsoft.MachineLearningServices/workspaces"
    - Azure Managed Disks: "Microsoft.Compute/diskAccesses"
    - Azure Media Services: "Microsoft.Media/mediaservices"
    - Azure Migrate: "Microsoft.Migrate/assessmentProjects"
    - Azure Monitor Private Link Scope: "Microsoft.Insights/privateLinkScopes"
    - Azure Relay: "Microsoft.Relay/namespaces"
    - Azure Service Bus: "Microsoft.ServiceBus/namespaces"
    - Azure SignalR Service: "Microsoft.SignalRService/SignalR"
    - Azure SignalR Service (Web PubSub): "Microsoft.SignalRService/WebPubSub"
    - Azure SQL Database: "Microsoft.Sql/servers"
    - Azure SQL Managed Instance: "Microsoft.Sql/managedInstances"
    - Azure Static Web Apps: "Microsoft.Web/staticSites"
    - Azure Storage: "Microsoft.Storage/storageAccounts"
    - Azure Synapse (privateLinkHubs): "Microsoft.Synapse/privateLinkHubs"
    - Azure Synapse Analytics: "Microsoft.Synapse/workspaces"
    - Azure Virtual Desktop - host pools: "Microsoft.DesktopVirtualization/hostPools"
    - Azure Virtual Desktop - workspaces: "Microsoft.DesktopVirtualization/workspaces"
    - Device Update for IoT Hub: "Microsoft.DeviceUpdate/accounts"
    - Integration Account (Premium): "Microsoft.Logic/integrationAccounts"
    - Microsoft Purview: "Microsoft.Purview/accounts"
    - Power BI: "Microsoft.PowerBI/privateLinkServicesForPowerBI"
    - Private Link service (your own service): "Microsoft.Network/privateLinkServices"
    - Resource Management Private Links: "Microsoft.Authorization/resourceManagementPrivateLinks"
  EOF

  type = object({
    name                = string
    resource_group_name = string
    type                = string
  })

  validation {
    condition     = length(var.private_connection_resource.name) > 0
    error_message = "The 'name' field in 'private_connection_resource' must not be empty."
  }

  validation {
    condition     = contains(keys(local.allowed_private_link_resources), var.private_connection_resource.type)
    error_message = "The 'type' field in 'private_connection_resource' must be one of the supported resource types as per Azure Private Link documentation. Refer to the variable description for valid options."
  }
}

variable "subnet_name_segment" {
  description = "(Required) The name segment of the subnet within the Virtual Network. Example: 'redis' for the segment of the subnet name of 'snet-redis-001-10.190.1.0_24'."
  type        = string
  validation {
    condition     = length(var.subnet_name_segment) > 0
    error_message = "The 'subnet_name_segment' variable must not be empty."
  }
}

# Private DNS Zones
variable "private_dns_zones" {
  description = "(Required) A list of Private DNS Zones with their corresponding resource group names."
  type = list(object({
    name                = string
    resource_group_name = string
  }))

  validation {
    condition = length(var.private_dns_zones) > 0 && alltrue([
      for dns_zone in var.private_dns_zones : (
        length(dns_zone.name) > 0 && length(dns_zone.resource_group_name) > 0
      )
    ])
    error_message = "The 'private_dns_zones' variable must contain at least one DNS zone, and each item must have non-empty 'name' and 'resource_group_name' attributes."
  }
}

#--------------------------------------------------------
# Module Optional Inputs
#--------------------------------------------------------

variable "network_interface_name" {
  description = "(Optional) The custom name of the network interface attached to the private endpoint. Default: null"
  type        = string
  default     = null
}

variable "application_security_group_associations" {
  description = "(Optional) A list of resource IDs of the application security groups to associate with the private endpoint. Default: []"
  type        = map(string)
  default     = {}
}

# Variable for subresource_names with validation
variable "subresource_names" {
  description = "(Optional) A list of sub-resource names which the Private Endpoint is able to connect to. Valid sub-resource names depend on the 'private_connection_resource_type' provided."

  type    = list(string)
  default = []

  validation {
    condition = length(var.subresource_names) == 0 || alltrue([
      for name in var.subresource_names : contains(
        lookup(local.allowed_private_link_resources, var.private_connection_resource.type, []),
        name
      )
    ])
    error_message = "Each 'subresource_name' in 'subresource_names' must be valid for the given private_connection_resource type. Refer to Azure Private Link documentation for valid subresources."
  }
}

# Variable for ip_configurations with validation
variable "ip_configurations" {
  description = "(Optional) A map of ip_configuration blocks."
  type = map(object({
    name               = string
    private_ip_address = string
    subresource_name   = string
    member_name        = optional(string, "default")
  }))
  default = {}

  validation {
    condition = alltrue([
      for ip_config in var.ip_configurations :
      cidr_contains("10.0.0.0/8", ip_config.private_ip_address)
    ])
    error_message = "Each 'private_ip_address' in 'ip_configurations' must be in the 10.x.y.z range."
  }
}

variable "enable_telemetry" {
  description = "Controls whether telemetry is enabled for the module. Defaults to true."
  type        = bool
  default     = true
}

variable "lock" {
  description = "(Optional) The lock level to apply. Possible values are 'None', 'CanNotDelete', and 'ReadOnly'."
  type = object({
    name = optional(string, null)
    kind = string
  })
  default = null
}

variable "private_dns_zone_group_name" {
  description = "(Optional) Specifies the name of the Private DNS Zone Group."
  type        = string
  default     = null
}

variable "private_service_connection_name" {
  description = "(Optional) Specifies the name of the Private Service Connection."
  type        = string
  default     = null
}

variable "role_assignments" {
  description = <<-EOF
    A map of role assignments to create on this resource. The map key is deliberately arbitrary to avoid issues where map keys may be unknown at plan time.

    Each map value should be an object with the following attributes:

    - role_definition_id_or_name (string, required): The ID or name of the role definition to assign to the principal.
    - principal_id (string, required): The ID of the principal to assign the role to.
    - description (string, optional): The description of the role assignment.
    - skip_service_principal_aad_check (bool, optional): If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
    - condition (string, optional): The condition which will be used to scope the role assignment.
    - condition_version (string, optional): The version of the condition syntax. Valid values are '2.0'.
    - delegated_managed_identity_resource_id (string, optional): The delegated Azure Resource ID which contains a Managed Identity. This field is only used in cross-tenant scenarios.
    - principal_type (string, optional): The type of the principal_id. Possible values are 'User', 'Group', and 'ServicePrincipal'. It is necessary to explicitly set this attribute when creating role assignments if the principal creating the assignment is constrained by ABAC rules that filter on the PrincipalType attribute.

    Note: Only set skip_service_principal_aad_check to true if you are assigning a role to a service principal.
  EOF

  type = map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string)
    condition_version                      = optional(string)
    delegated_managed_identity_resource_id = optional(string)
    principal_type                         = optional(string)
  }))

  default = {}

  validation {
    condition = alltrue([
      for assignment_key, assignment in var.role_assignments : (
        length(assignment.role_definition_id_or_name) > 0 &&
        length(assignment.principal_id) > 0 &&
        (
          assignment.skip_service_principal_aad_check != true ||
          (assignment.skip_service_principal_aad_check == true && lookup(assignment, "principal_type", "") == "ServicePrincipal")
        ) &&
        (
          lookup(assignment, "principal_type", "") == "" ||
          contains(["User", "Group", "ServicePrincipal"], assignment.principal_type)
        ) &&
        (
          lookup(assignment, "condition_version", "") == "" ||
          assignment.condition_version == "2.0"
        )
      )
    ])

    error_message = <<-EOF
      Each role assignment must have:
      - A non-empty 'role_definition_id_or_name'.
      - A non-empty 'principal_id'.
      - If 'skip_service_principal_aad_check' is true, 'principal_type' must be 'ServicePrincipal'.
      - If 'principal_type' is provided, it must be one of 'User', 'Group', or 'ServicePrincipal'.
      - If 'condition_version' is provided, it must be '2.0'.
    EOF
  }
}

variable "custom_resource_group_name" {
  description = "(Optional) Name of an existing resource group to use. If provided, no new resource group will be created."
  type        = string
  default     = null
}
#---------------------------------------------------------------------------------
# Tags variables
#---------------------------------------------------------------------------------

variable "common_tags" {
  type        = map(string)
  description = "This is the default common tags for all the resources deployed."
}

variable "resource_tags" {
  type        = map(string)
  description = "(Optional) This tags which we can define specific to the resources. Default: {}"
  default     = {}
}
