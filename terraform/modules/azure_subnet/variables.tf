#----------------------------------------------------------------------------------------------------------------------------
#
# See documentation for more details: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet
#
#----------------------------------------------------------------------------------------------------------------------------

variable "name" {
  description = "The name of the subnet to be created."
  type        = string
  validation {
    condition     = length(var.name) > 0
    error_message = "The name of the subnet cannot be empty."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which the subnet is created."
  type        = string
  validation {
    condition     = length(var.resource_group_name) > 0
    error_message = "The resource group name cannot be empty."
  }
}

variable "virtual_network_name" {
  description = "The name of the Virtual Network to which the subnet belongs."
  type        = string
  validation {
    condition     = length(var.virtual_network_name) > 0
    error_message = "The virtual network name cannot be empty."
  }
}

variable "address_prefixes" {
  description = "List of address prefixes for the subnet, which must be in valid CIDR format."
  type        = list(string)
  validation {
    condition     = alltrue([for prefix in var.address_prefixes : can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/([0-9]|[12][0-9]|3[0-2])$", prefix))])
    error_message = "Each entry in address_prefixes must be a valid CIDR block."
  }
}

variable "delegations" {
  description = "List of delegations for the subnet."
  type = list(object({
    name = string
    service_delegation = object({
      name    = string
      actions = list(string)
    })
  }))
  default = []
  validation {
    condition = alltrue([for delegation in var.delegations : (
      length(delegation.name) > 0 && # Ensure delegation name is not empty
      contains([
        "GitHub.Network/networkSettings", "Microsoft.ApiManagement/service", "Microsoft.Apollo/npu",
        "Microsoft.App/environments", "Microsoft.App/testClients", "Microsoft.AVS/PrivateClouds",
        "Microsoft.AzureCosmosDB/clusters", "Microsoft.BareMetal/AzureHostedService",
        "Microsoft.BareMetal/AzureHPC", "Microsoft.BareMetal/AzurePaymentHSM",
        "Microsoft.BareMetal/AzureVMware", "Microsoft.BareMetal/CrayServers",
        "Microsoft.BareMetal/MonitoringServers", "Microsoft.Batch/batchAccounts",
        "Microsoft.CloudTest/hostedpools", "Microsoft.CloudTest/images", "Microsoft.CloudTest/pools",
        "Microsoft.Codespaces/plans", "Microsoft.ContainerInstance/containerGroups",
        "Microsoft.ContainerService/managedClusters", "Microsoft.ContainerService/TestClients",
        "Microsoft.Databricks/workspaces", "Microsoft.DBforMySQL/flexibleServers",
        "Microsoft.DBforMySQL/servers", "Microsoft.DBforMySQL/serversv2",
        "Microsoft.DBforPostgreSQL/flexibleServers", "Microsoft.DBforPostgreSQL/serversv2",
        "Microsoft.DBforPostgreSQL/singleServers", "Microsoft.DelegatedNetwork/controller",
        "Microsoft.DevCenter/networkConnection", "Microsoft.DevOpsInfrastructure/pools",
        "Microsoft.DocumentDB/cassandraClusters", "Microsoft.Fidalgo/networkSettings",
        "Microsoft.HardwareSecurityModules/dedicatedHSMs", "Microsoft.Kusto/clusters",
        "Microsoft.LabServices/labplans", "Microsoft.Logic/integrationServiceEnvironments",
        "Microsoft.MachineLearningServices/workspaces", "Microsoft.Netapp/volumes",
        "Microsoft.Network/dnsResolvers", "Microsoft.Network/managedResolvers",
        "Microsoft.Network/fpgaNetworkInterfaces", "Microsoft.Network/networkWatchers",
        "Microsoft.Network/virtualNetworkGateways", "Microsoft.Orbital/orbitalGateways",
        "Microsoft.PowerPlatform/enterprisePolicies", "Microsoft.PowerPlatform/vnetaccesslinks",
        "Microsoft.ServiceFabricMesh/networks", "Microsoft.ServiceNetworking/trafficControllers",
        "Microsoft.Singularity/accounts/networks", "Microsoft.Singularity/accounts/npu",
        "Microsoft.Sql/managedInstances", "Microsoft.Sql/managedInstancesOnebox",
        "Microsoft.Sql/managedInstancesStage", "Microsoft.Sql/managedInstancesTest",
        "Microsoft.Sql/servers", "Microsoft.StoragePool/diskPools", "Microsoft.StreamAnalytics/streamingJobs",
        "Microsoft.Synapse/workspaces", "Microsoft.Web/hostingEnvironments",
        "Microsoft.Web/serverFarms", "NGINX.NGINXPLUS/nginxDeployments",
        "PaloAltoNetworks.Cloudngfw/firewalls", "Qumulo.Storage/fileSystems",
        "Oracle.Database/networkAttachments"
      ], delegation.service_delegation.name)
      && alltrue([for action in delegation.service_delegation.actions : contains([
        "Microsoft.Network/networkinterfaces/*", "Microsoft.Network/publicIPAddresses/join/action",
        "Microsoft.Network/publicIPAddresses/read", "Microsoft.Network/virtualNetworks/read",
        "Microsoft.Network/virtualNetworks/subnets/action", "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"
      ], action)])
    )])
    error_message = "Invalid delegation: each delegation must have a non-empty name and a valid service_delegation name. Actions, if provided, must be valid for the service being delegated."
  }
}


variable "default_outbound_access_enabled" {
  description = "Enable or Disable default outbound access to the internet for the subnet. Defaults to true."
  type        = bool
  default     = true
}

variable "private_endpoint_network_policies" {
  description = "Enable or Disable network policies for the private endpoint on the subnet. Possible values are Disabled, Enabled, NetworkSecurityGroupEnabled, and RouteTableEnabled. Defaults to Disabled."
  type        = string
  default     = "Disabled"
  validation {
    condition     = contains(["Disabled", "Enabled", "NetworkSecurityGroupEnabled", "RouteTableEnabled"], var.private_endpoint_network_policies)
    error_message = "private_endpoint_network_policies must be one of Disabled, Enabled, NetworkSecurityGroupEnabled, or RouteTableEnabled."
  }
}

variable "private_link_service_network_policies_enabled" {
  description = "Boolean to enable/disable private link service network policies."
  type        = bool
  default     = true
}

variable "service_endpoints" {
  description = "The list of Service endpoints to associate with the subnet."
  type        = list(string)
  default     = []
  validation {
    condition = alltrue([for endpoint in var.service_endpoints : contains([
      "Microsoft.AzureActiveDirectory", "Microsoft.AzureCosmosDB", "Microsoft.ContainerRegistry",
      "Microsoft.EventHub", "Microsoft.KeyVault", "Microsoft.ServiceBus",
      "Microsoft.Sql", "Microsoft.Storage", "Microsoft.Storage.Global", "Microsoft.Web"
    ], endpoint)])
    error_message = "Each entry in service_endpoints must be one of the following: Microsoft.AzureActiveDirectory, Microsoft.AzureCosmosDB, Microsoft.ContainerRegistry, Microsoft.EventHub, Microsoft.KeyVault, Microsoft.ServiceBus, Microsoft.Sql, Microsoft.Storage, Microsoft.Storage.Global, or Microsoft.Web."
  }
}

variable "service_endpoint_policy_ids" {
  description = "A list of service endpoint policy IDs to apply to the subnet."
  type        = list(string)
  default     = []
}

