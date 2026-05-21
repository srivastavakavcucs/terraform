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

variable "resource_name_for_private_link" {
  description = "(Required) Specifies the name of this Private Link resource to which private links needs to be created. Changing this forces a new resource to be created."
  type        = string
}

variable "load_balancer_frontend_ip_configuration_ids" {
  description = " (Required) A list of Frontend IP Configuration IDs from a Standard Load Balancer, where traffic from the Private Link Service should be routed. You can use Load Balancer Rules to direct this traffic to appropriate backend pools where your applications are running. Changing this forces a new resource to be created."
  type        = list(string)
  default     = []
}

#--------------------------------------------------------
# Module Optional Inputs
#--------------------------------------------------------

variable "lock" {
  description = "(Optional) Controls the Resource Lock configuration for this resource."
  type = object({
    kind = string
  })
  default = null
}

variable "enable_telemetry" {
  description = "(Optional) Enable telemetry for the module. Defaulted to true."
  type        = bool
  default     = true
}

variable "private_link_subnet_name_segment" {
  description = "The subnet id of the private link service"
  type        = string
}

variable "visibility_subscription_ids" {
  description = "(Optional) A list of Subscription UUID/GUID's that will be able to see this Private Link Service."
  type        = list(string)
  default     = []
}

variable "auto_approval_subscription_ids" {
  description = " (Optional) A list of Subscription UUID/GUID's that will be automatically be able to use this Private Link Service."
  type        = list(string)
  default     = []
}

variable "nat_ip_address" {
  description = " (Optional) Specifies a Private Static IP Address for this IP Configuration."
  type        = string
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
  description = "This is the default common tags for the entire resources."
}

variable "resource_tags" {
  type        = map(string)
  description = "This tags which we can define specific to the resources."
  default     = {}
}
