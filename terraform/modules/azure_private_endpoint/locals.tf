
# Local Variables


#************************************************************************************************
#
# See documentation for additional information:
# https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview#private-link-resource
#
#************************************************************************************************

# Local variable to define allowed resource types and their valid sub-resource names
locals {
  private_connection_resource = [for r in data.azurerm_resources.private_connection_resource.resources : r if r.name == var.private_connection_resource.name][0]

  allowed_private_link_resources = {
    # Resource types and sub-resources as per the provided table

    # Application Gateway
    "Microsoft.Network/applicationGateways" = ["Frontend IP Configuration name"]

    # Azure AI Search
    "Microsoft.Search/searchServices" = ["searchService"]

    # Azure AI services
    "Microsoft.CognitiveServices/accounts" = ["account"]

    # Azure API for FHIR
    "Microsoft.HealthcareApis/services" = ["fhir"]

    # Azure API Management
    "Microsoft.ApiManagement/service" = ["Gateway"]

    # Azure App Configuration
    "Microsoft.AppConfiguration/configurationStores" = ["configurationStores"]

    # Azure App Service (hosting environments)
    "Microsoft.Web/hostingEnvironments" = ["hosting environment"]

    # Azure App Service (sites)
    "Microsoft.Web/sites" = ["sites"]

    # Azure Attestation Service
    "Microsoft.Attestation/attestationProviders" = ["standard"]

    # Azure Automation
    "Microsoft.Automation/automationAccounts" = ["Webhook", "DSCAndHybridWorker"]

    # Azure Backup
    "Microsoft.RecoveryServices/vaults" = ["AzureBackup", "AzureSiteRecovery"]

    # Azure Batch
    "Microsoft.Batch/batchAccounts" = ["batchAccount", "nodeManagement"]

    # Azure Cache for Redis
    "Microsoft.Cache/Redis" = ["redisCache"]

    # Azure Cache for Redis Enterprise
    "Microsoft.Cache/redisEnterprise" = ["redisEnterprise"]

    # Azure Container Registry
    "Microsoft.ContainerRegistry/registries" = ["registry"]

    # Azure Cosmos DB
    "Microsoft.AzureCosmosDB/databaseAccounts" = ["SQL", "MongoDB", "Cassandra", "Gremlin", "Table"]

    # Azure Cosmos DB for MongoDB vCore
    "Microsoft.DocumentDB/mongoClusters" = ["mongoCluster"]

    # Azure Cosmos DB for PostgreSQL
    "Microsoft.DBforPostgreSQL/serverGroupsv2" = ["coordinator"]

    # Azure Data Explorer
    "Microsoft.Kusto/clusters" = ["cluster"]

    # Azure Data Factory
    "Microsoft.DataFactory/factories" = ["dataFactory"]

    # Azure Database for MariaDB
    "Microsoft.DBforMariaDB/servers" = ["mariadbServer"]

    # Azure Database for MySQL - Flexible Server
    "Microsoft.DBforMySQL/flexibleServers" = ["mysqlServer"]

    # Azure Database for MySQL - Single Server
    "Microsoft.DBforMySQL/servers" = ["mysqlServer"]

    # Azure Database for PostgreSQL - Flexible Server
    "Microsoft.DBforPostgreSQL/flexibleServers" = ["postgresqlServer"]

    # Azure Database for PostgreSQL - Single Server
    "Microsoft.DBforPostgreSQL/servers" = ["postgresqlServer"]

    # Azure Databricks
    "Microsoft.Databricks/workspaces" = ["databricks_ui_api", "browser_authentication"]

    # Azure Device Provisioning Service
    "Microsoft.Devices/provisioningServices" = ["iotDps"]

    # Azure Digital Twins
    "Microsoft.DigitalTwins/digitalTwinsInstances" = ["API"]

    # Azure Event Grid (domains)
    "Microsoft.EventGrid/domains" = ["domain"]

    # Azure Event Grid (topics)
    "Microsoft.EventGrid/topics" = ["topic"]

    # Azure Event Hub
    "Microsoft.EventHub/namespaces" = ["namespace"]

    # Azure File Sync
    "Microsoft.StorageSync/storageSyncServices" = ["File Sync Service"]

    # Azure HDInsight
    "Microsoft.HDInsight/clusters" = ["cluster"]

    # Azure IoT Central
    "Microsoft.IoTCentral/IoTApps" = ["IoTApps"]

    # Azure IoT Hub
    "Microsoft.Devices/IotHubs" = ["iotHub"]

    # Azure Key Vault
    "Microsoft.KeyVault/vaults" = ["vault"]

    # Azure Key Vault HSM
    "Microsoft.KeyVault/managedHSMs" = ["HSM"]

    # Azure Kubernetes Service - Kubernetes API
    "Microsoft.ContainerService/managedClusters" = ["management"]

    # Azure Machine Learning (registries)
    "Microsoft.MachineLearningServices/registries" = ["amlregistry"]

    # Azure Machine Learning (workspaces)
    "Microsoft.MachineLearningServices/workspaces" = ["amlworkspace"]

    # Azure Managed Disks
    "Microsoft.Compute/diskAccesses" = ["managed disk"]

    # Azure Media Services
    "Microsoft.Media/mediaservices" = ["keydelivery", "liveevent", "streamingendpoint"]

    # Azure Migrate
    "Microsoft.Migrate/assessmentProjects" = ["project"]

    # Azure Monitor Private Link Scope
    "Microsoft.Insights/privateLinkScopes" = ["azuremonitor"]

    # Azure Relay
    "Microsoft.Relay/namespaces" = ["namespace"]

    # Azure Service Bus
    "Microsoft.ServiceBus/namespaces" = ["namespace"]

    # Azure SignalR Service
    "Microsoft.SignalRService/SignalR" = ["signalR"]

    # Azure SignalR Service (Web PubSub)
    "Microsoft.SignalRService/WebPubSub" = ["webpubsub"]

    # Azure SQL Database
    "Microsoft.Sql/servers" = ["sqlServer"]

    # Azure SQL Managed Instance
    "Microsoft.Sql/managedInstances" = ["managedInstance"]

    # Azure Static Web Apps
    "Microsoft.Web/staticSites" = ["staticSites"]

    # Azure Storage
    "Microsoft.Storage/storageAccounts" = [
      "blob", "blob_secondary",
      "file", "file_secondary",
      "queue", "queue_secondary",
      "table", "table_secondary",
      "web", "web_secondary",
      "dfs", "dfs_secondary"
    ]

    # Azure Synapse (privateLinkHubs)
    "Microsoft.Synapse/privateLinkHubs" = ["web"]

    # Azure Synapse Analytics
    "Microsoft.Synapse/workspaces" = ["Sql", "SqlOnDemand", "Dev"]

    # Azure Virtual Desktop - host pools
    "Microsoft.DesktopVirtualization/hostPools" = ["connection"]

    # Azure Virtual Desktop - workspaces
    "Microsoft.DesktopVirtualization/workspaces" = ["feed", "global"]

    # Device Update for IoT Hub
    "Microsoft.DeviceUpdate/accounts" = ["DeviceUpdate"]

    # Integration Account (Premium)
    "Microsoft.Logic/integrationAccounts" = ["integrationAccount"]

    # Microsoft Purview
    "Microsoft.Purview/accounts" = ["account", "portal"]

    # Power BI
    "Microsoft.PowerBI/privateLinkServicesForPowerBI" = ["Power BI"]

    # Private Link service (your own service)
    "Microsoft.Network/privateLinkServices" = ["empty"]

    # Resource Management Private Links
    "Microsoft.Authorization/resourceManagementPrivateLinks" = ["ResourceManagement"]
  }
}
