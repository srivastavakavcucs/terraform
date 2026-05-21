#---------------------------------------------------------------------------------
# Common Required Inputs
#---------------------------------------------------------------------------------

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

#---------------------------------------------------------------------------------
# Module Required Inputs for NetApp Pool
#---------------------------------------------------------------------------------

variable "pool_size" {
  type        = number
  description = "(Required) Provisioned size of the pool in TB. Value must be between 1 and 2048."
  validation {
    condition     = var.pool_size >= 1 && var.pool_size <= 2048
    error_message = "The pool_size must be between 1 and 2048 TB."
  }
}

variable "pool_service_level" {
  type        = string
  description = "(Required) The service level of the file system. Valid values include Premium, Standard, and Ultra. Changing this forces a new resource to be created."
  validation {
    condition     = contains(["Premium", "Standard", "Ultra"], var.pool_service_level)
    error_message = "The pool_service_level must be one of: Premium, Standard, or Ultra."
  }
}

#---------------------------------------------------------------------------------
# Module Required Inputs for NetApp Volume
#---------------------------------------------------------------------------------

variable "volume_path" {
  type        = string
  description = "(Required) A unique file path for the volume. Used when creating mount targets. Changing this forces a new resource to be created."
  validation {
    condition     = length(var.volume_path) > 0
    error_message = "The volume_path cannot be empty."
  }
}

variable "volume_service_level" {
  type        = string
  description = "(Required) The target performance of the file system. Valid values include Premium, Standard, or Ultra. Changing this forces a new resource to be created."
  validation {
    condition     = contains(["Premium", "Standard", "Ultra"], var.volume_service_level)
    error_message = "The volume_service_level must be one of: Premium, Standard, or Ultra."
  }
}

variable "storage_quota_in_gb" {
  type        = number
  description = "(Required) The maximum Storage Quota allowed for a file system in Gigabytes."
  validation {
    condition     = var.storage_quota_in_gb > 0
    error_message = "The storage_quota_in_gb must be a positive number."
  }
}

variable "rule_index" {
  type        = number
  description = "(Required) The index number of the rule."
  validation {
    condition     = var.rule_index >= 0
    error_message = "The rule_index must be 0 or a positive integer."
  }
}

variable "allowed_clients" {
  type        = list(string)
  description = "(Required) A list of allowed client IPv4 addresses."
  validation {
    condition     = length(var.allowed_clients) > 0
    error_message = "The allowed_clients list must contain at least one client IP address."
  }
}

variable "delegated_subnet_name_segment" {
  description = "Segment of the virtual network subnet that is delegated for Azure NetApp Files(ANF). Ex: 'netapp' for snet-netapp-10.x.x.x_24"
  type        = string
}

#---------------------------------------------------------------------------------
# Module Optional Inputs
#---------------------------------------------------------------------------------

variable "enable_telemetry" {
  description = "(Optional) Enable telemetry for the module. Default: true"
  type        = bool
  default     = true
}

variable "lock" {
  description = "(Optional) Controls the Resource Lock configuration for this resource. Default: null"
  type = object({
    kind = string
  })
  default = null
}

variable "zone" {
  type        = string
  description = "(Optional) Specifies the Availability Zone in which the Volume should be located. Possible values are 1, 2, and 3. Changing this forces a new resource to be created. Default: 1."
  default     = "1"
  validation {
    condition     = contains(["1", "2", "3"], var.zone)
    error_message = "The zone must be one of: 1, 2, or 3."
  }
}

variable "network_features" {
  type        = string
  description = "(Optional) Indicates which network feature to use, accepted values are Basic or Standard. Default: Standard."
  default     = "Standard"
  validation {
    condition     = contains(["Basic", "Standard"], var.network_features)
    error_message = "The network_features must be either Basic or Standard."
  }
}

variable "protocols" {
  type        = list(string)
  description = "(Optional) The target volume protocol expressed as a list. Supported single value include CIFS, NFSv3, or NFSv4.1. Default: NFSv4.1."
  default     = ["NFSv4.1"]
  validation {
    condition     = alltrue([for protocol in var.protocols : contains(["CIFS", "NFSv3", "NFSv4.1"], protocol)])
    error_message = "The protocols list can only include CIFS, NFSv3, or NFSv4.1."
  }
}

variable "security_style" {
  type        = string
  description = "(Optional) Volume security style, accepted values are unix or ntfs. Default: unix."
  default     = "unix"
  validation {
    condition     = contains(["unix", "ntfs"], var.security_style)
    error_message = "The security_style must be either unix or ntfs."
  }
}

variable "snapshot_directory_visible" {
  type        = bool
  description = "(Optional) Specifies whether the .snapshot (NFS clients) or ~snapshot (SMB clients) path of a volume is visible. Default: false."
  default     = false
}

variable "protocols_enabled" {
  type        = list(string)
  description = "(Optional) A list of allowed protocols. Valid values include CIFS, NFSv3, or NFSv4.1. Default: NFSv4.1."
  default     = ["NFSv4.1"]
  validation {
    condition     = alltrue([for protocol in var.protocols_enabled : contains(["CIFS", "NFSv3", "NFSv4.1"], protocol)])
    error_message = "The protocols_enabled list can only include CIFS, NFSv3, or NFSv4.1."
  }
}

variable "unix_read_write" {
  type        = bool
  description = "(Optional) Is the file system on unix read and write? Default: true."
  default     = true
}

variable "custom_resource_group_name" {
  description = "(Optional) Name of an existing resource group to use. If provided, no new resource group will be created."
  type        = string
  default     = null
}
#---------------------------------------------------------------------------------
# Tags variables
#---------------------------------------------------------------------------------

variable "resource_tags" {
  type        = map(string)
  description = "(Optional) This tags which we can define specific to the resources. Default: {}"
  default     = {}
}

variable "common_tags" {
  type        = map(string)
  description = "(Required) These are the default VyStar common tags for all Azure resources that are deployed."
}