/*
--------------------------------------------------------------------------------
  MODULE VARIABLES
--------------------------------------------------------------------------------
*/

variable "cluster_name" {
  description = "Name of your cluster"
  type        = string
  validation {
    condition     = length(var.cluster_name) > 3 && length(var.cluster_name) < 24
    error_message = "Name of your cluster - Between 3 and 23 characters"
  }
}

variable "application_type_name" {
  description = "The application type name."
  type        = string
}

variable "application_type_version" {
  description = "The application type version."
  type        = string
}

variable "app_package_url" {
  description = "The URL to the application package sfpkg file."
  type        = string
}

variable "application_name" {
  description = "The name of the application resource."
  type        = string
}

variable "service_names" {
  description = "An array of service names."
  type        = list(string)
  validation {
    condition     = length(var.service_names) <= 5
    error_message = "Maximum of 5 service names allowed."
  }
}

variable "placement_constraints" {
  description = "The placement constraints."
  type        = string
}

variable "sfmc_resource_group_name" {
  description = "The name of the resource group containing the SFMC user-assigned managed identity"
  type        = string
}

variable "sfmc_cluster_resource_group_name" {
  description = "The name of the resource group containing the SFMC cluster"
  type        = string
}

variable "sfmc_managed_identity_name" {
  description = "SFMC User-assigned managed identity name"
  type        = string
}

variable "application_parameters" {
  description = "The application parameters."
  type        = map(string)
}


/*
--------------------------------------------------------------------------------
  Module Optional Values
--------------------------------------------------------------------------------
*/

variable "instance_count" {
  description = "The instance count."
  type        = number
  default     = -1
}

variable "location" {
  description = "Location for resources"
  type        = string
  default     = "eastus"
}

variable "upgrade_policy" {
  description = "The upgrade policy."
  type = object({
    applicationHealthPolicy = object({
      considerWarningAsError                  = bool
      maxPercentUnhealthyDeployedApplications = number
    })
    forceRestart               = bool
    instanceCloseDelayDuration = number
    recreateApplication        = bool
    rollingUpgradeMonitoringPolicy = object({
      failureAction             = string
      healthCheckRetryTimeout   = string
      healthCheckStableDuration = string
      healthCheckWaitDuration   = string
      upgradeDomainTimeout      = string
      upgradeTimeout            = string
    })
    upgradeReplicaSetCheckTimeout = number
    upgradeMode                   = string
  })
  default = {
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