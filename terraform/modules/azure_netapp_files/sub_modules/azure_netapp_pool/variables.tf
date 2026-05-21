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

variable "service_level" {
  type        = string
  description = "(Required) The service level of the file system. Valid values include Premium, Standard, and Ultra. Changing this forces a new resource to be created."
}

variable "pool_size" {
  type        = number
  description = " (Required) Provisioned size of the pool in TB. Value must be between 1 and 2048."
}


#---------------------------------------------------------------------------------
# Module Optional Inputs
#---------------------------------------------------------------------------------


#---------------------------------------------------------------------------------
# Tags variables
#---------------------------------------------------------------------------------

variable "tags" {
  type        = map(string)
  description = "(Optional) A mapping of tags to assign to the resource. Default: {}"
  default     = {}
}
