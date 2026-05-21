#---------------------------------------------------------------------------------
# Module Required Inputs
#---------------------------------------------------------------------------------
variable "name" {
  type        = string
  description = "(Required) The name of the NetApp Account. Changing this forces a new resource to be created."
}

variable "location" {
  description = "(Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
  type        = string
}

variable "resource_group_name" {
  type        = string
  description = "(Required) The name of the resource group where the NetApp Account should be created. Changing this forces a new resource to be created."
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