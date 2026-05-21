#---------------------------------------------------------------------------------
# Module Required Inputs
#---------------------------------------------------------------------------------

variable "name" {
  type        = string
  description = " (Required) The name of the NetApp Pool. Changing this forces a new resource to be created."
}

variable "location" {
  description = " (Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
  type        = string
}

variable "resource_group_name" {
  type        = string
  description = "(Required) The name of the resource group where the NetApp Pool should be created. Changing this forces a new resource to be created."
}

variable "account_name" {
  type        = string
  description = "(Required) The name of the NetApp account in which the NetApp Pool should be created. Changing this forces a new resource to be created."
}

variable "pool_name" {
  type        = string
  description = "(Required) The name of the NetApp pool in which the NetApp Volume should be created. Changing this forces a new resource to be created."
}

variable "volume_path" {
  type        = string
  description = " (Required) A unique file path for the volume. Used when creating mount targets. Changing this forces a new resource to be created."
}

variable "service_level" {
  type        = string
  description = "(Required) The target performance of the file system. Valid values include Premium, Standard, or Ultra. Changing this forces a new resource to be created."
}

variable "storage_quota_in_gb" {
  type        = string
  description = "(Required) The maximum Storage Quota allowed for a file system in Gigabytes."
}

variable "rule_index" {
  type        = number
  description = "(Required) The index number of the rule."
}

variable "allowed_clients" {
  type        = list(string)
  description = "(Required) A list of allowed clients IPv4 addresses."
}

variable "subnet_id" {
  description = "(Required) The ID of the Subnet the NetApp Volume resides in, which must have the Microsoft.NetApp/volumes delegation. Changing this forces a new resource to be created."
  type        = string
}

#---------------------------------------------------------------------------------
# Module Optional Inputs
#---------------------------------------------------------------------------------

variable "zone" {
  type        = string
  description = "(Optional) Specifies the Availability Zone in which the Volume should be located. Possible values are 1, 2 and 3. Changing this forces a new resource to be created. Default: 1"
  default     = "1"
}

variable "network_features" {
  type        = string
  description = "(Optional) Indicates which network feature to use, accepted values are Basic or Standard. Default: Standard"
  default     = "Standard"
}

variable "protocols" {
  type        = list(string)
  description = "(Optional) The target volume protocol expressed as a list. Supported single value include CIFS, NFSv3, or NFSv4.1. If argument is not defined it will default to NFSv3. Changing this forces a new resource to be created and data will be lost. Dual protocol scenario is supported for CIFS and NFSv3, Default: NFSv4.1"
  default     = ["NFSv4.1"]
}

variable "security_style" {
  type        = string
  description = "(Optional) Volume security style, accepted values are unix or ntfs. If not provided, single-protocol volume is created defaulting to unix if it is NFSv3 or NFSv4.1 volume, if CIFS, it will default to ntfs. In a dual-protocol volume, if not provided, its value will be ntfs. Changing this forces a new resource to be created. Default: unix"
  default     = "unix"
}

variable "snapshot_directory_visible" {
  type        = bool
  description = "(Optional) Specifies whether the .snapshot (NFS clients) or ~snapshot (SMB clients) path of a volume is visible, Default: false."
  default     = false
}

variable "protocols_enabled" {
  type        = list(string)
  description = "(Optional) A list of allowed protocols. Valid values include CIFS, NFSv3, or NFSv4.1. Only one value is supported at this time. This replaces the previous arguments: cifs_enabled, nfsv3_enabled and nfsv4_enabled. Default: NFSv4.1"
  default     = ["NFSv4.1"]
}

variable "unix_read_write" {
  type        = bool
  description = "(Optional) Is the file system on unix read and write? Default: true"
  default     = true
}

#---------------------------------------------------------------------------------
# Tags variables
#---------------------------------------------------------------------------------

variable "tags" {
  type        = map(string)
  description = "(Optional) A mapping of tags to assign to the resource. Default: {}"
  default     = {}
}