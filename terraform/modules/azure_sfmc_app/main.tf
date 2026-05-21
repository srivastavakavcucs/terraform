/*
--------------------------------------------------------------------------------
  SERVICE FABRIC MANAGED CLUSTER APPLICATION MODULE
--------------------------------------------------------------------------------
*/


# Service Fabric Application Type
resource "azapi_resource" "sfmc_app_type" {
  type      = "Microsoft.ServiceFabric/managedclusters/applicationTypes@2022-01-01"
  name      = var.application_type_name
  parent_id = local.sfmc_id
  location  = var.location

  body = jsonencode({
    properties = {}
  })
}

# Service Fabric Application Type Version
resource "azapi_resource" "sfmc_app_type_version" {
  type      = "Microsoft.ServiceFabric/managedclusters/applicationTypes/versions@2022-01-01"
  name      = var.application_type_version
  parent_id = azapi_resource.sfmc_app_type.id
  location  = var.location

  body = jsonencode({
    properties = {
      appPackageUrl = var.app_package_url
    }
  })
}

# Service Fabric Application
resource "azapi_resource" "sfmc_application" {
  type      = "Microsoft.ServiceFabric/managedclusters/applications@2022-01-01"
  name      = var.application_name
  parent_id = local.sfmc_id
  location  = var.location

  identity {
    type = "UserAssigned"
    identity_ids = [
      local.managed_identity_id
    ]
  }

  body = jsonencode({
    properties = {
      version    = "${local.sfmc_id}/applicationTypes/${var.application_type_name}/versions/${var.application_type_version}"
      parameters = var.application_parameters
      upgradePolicy = {
        applicationHealthPolicy = {
          considerWarningAsError                  = var.upgrade_policy.applicationHealthPolicy.considerWarningAsError
          maxPercentUnhealthyDeployedApplications = var.upgrade_policy.applicationHealthPolicy.maxPercentUnhealthyDeployedApplications
        }
        forceRestart               = var.upgrade_policy.forceRestart
        instanceCloseDelayDuration = var.upgrade_policy.instanceCloseDelayDuration
        recreateApplication        = var.upgrade_policy.recreateApplication
        rollingUpgradeMonitoringPolicy = {
          failureAction             = var.upgrade_policy.rollingUpgradeMonitoringPolicy.failureAction
          healthCheckRetryTimeout   = var.upgrade_policy.rollingUpgradeMonitoringPolicy.healthCheckRetryTimeout
          healthCheckStableDuration = var.upgrade_policy.rollingUpgradeMonitoringPolicy.healthCheckStableDuration
          healthCheckWaitDuration   = var.upgrade_policy.rollingUpgradeMonitoringPolicy.healthCheckWaitDuration
          upgradeDomainTimeout      = var.upgrade_policy.rollingUpgradeMonitoringPolicy.upgradeDomainTimeout
          upgradeTimeout            = var.upgrade_policy.rollingUpgradeMonitoringPolicy.upgradeTimeout
        }
        upgradeReplicaSetCheckTimeout = var.upgrade_policy.upgradeReplicaSetCheckTimeout
        upgradeMode                   = var.upgrade_policy.upgradeMode
      }
      managedIdentities = [
        {
          name        = var.sfmc_managed_identity_name
          principalId = local.managed_identity_principal_id
        }
      ]
    }
  })

  depends_on = [
    azapi_resource.sfmc_app_type,
    azapi_resource.sfmc_app_type_version
  ]

  lifecycle {
    replace_triggered_by = [azapi_resource.sfmc_app_type_version]
  }
}

# Service Fabric Services
resource "azapi_resource" "sfmc_services" {
  for_each = toset(var.service_names)

  type      = "Microsoft.ServiceFabric/managedclusters/applications/services@2022-01-01"
  name      = each.value
  parent_id = azapi_resource.sfmc_application.id
  location  = var.location

  body = jsonencode({
    properties = {
      placementConstraints         = var.placement_constraints
      servicePackageActivationMode = "ExclusiveProcess"
      serviceKind                  = "Stateless"
      serviceTypeName              = "${each.value}Type"
      partitionDescription = {
        partitionScheme = "Singleton"
      }
      instanceCount = var.instance_count
    }
  })
}
