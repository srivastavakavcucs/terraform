#--------------------------------------------------------
# Common Required Inputs - IaC Base Module Inputs
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
# NSG Configuration Variables
#--------------------------------------------------------

variable "network_security_group_name" {
  description = "Name of the Network Security Group to associate with firewall interfaces"
  type        = string
  default     = null
}

variable "network_security_group_resource_group_name" {
  description = "Resource group name where the NSG is located (if different from firewall RG)"
  type        = string
  default     = null
}
#--------------------------------------------------------
# Network Configuration Variables
#--------------------------------------------------------

variable "custom_vnet_name" {
  description = "(Optional) Custom VNet name. If not set, the default naming convention will be used."
  type        = string
  default     = ""
}

variable "custom_vnet_resource_group_name" {
  description = "(Optional) Custom VNet resource group name. If not set, the default naming convention will be used."
  type        = string
  default     = ""
}

variable "management_subnet_name" {
  description = "Name of the management subnet for Palo Alto firewall"
  type        = string
  nullable    = false

  validation {
    condition     = length(var.management_subnet_name) > 0
    error_message = "Management subnet name cannot be empty."
  }
}

variable "untrust_subnet_name" {
  description = "Name of the untrust (external/public) subnet for Palo Alto firewall"
  type        = string
  nullable    = false

  validation {
    condition     = length(var.untrust_subnet_name) > 0
    error_message = "Untrust subnet name cannot be empty."
  }
}

variable "trust_subnet_name" {
  description = "Name of the trust (internal/private) subnet for Palo Alto firewall"
  type        = string
  nullable    = false

  validation {
    condition     = length(var.trust_subnet_name) > 0
    error_message = "Trust subnet name cannot be empty."
  }
}

#--------------------------------------------------------
# VM Configuration Variables
#--------------------------------------------------------

variable "vm_size" {
  description = "Size of the Palo Alto VM"
  type        = string
  default     = "Standard_D3_v2"
}

variable "admin_username" {
  description = "Admin username for the VM (hardcoded as per security requirements)"
  type        = string
  default     = "infosec"
}

variable "admin_ssh_keys" {
  description = "List of SSH public keys for VM authentication"
  type = list(object({
    username   = string
    public_key = string
  }))
  default = []
}

variable "disable_password_authentication" {
  description = "Disable password authentication (set to true when using SSH keys)"
  type        = bool
  default     = true
}

variable "computer_name" {
  description = "Computer name for the VM (if null, will be auto-generated)"
  type        = string
  default     = null

  validation {
    condition     = var.computer_name == null || (length(var.computer_name) >= 1 && length(var.computer_name) <= 15)
    error_message = "Computer name must be between 1 and 15 characters when specified."
  }
}

variable "enable_availability_set" {
  description = "Enable availability set for high availability"
  type        = bool
  default     = false
}

variable "availability_set_fault_domain_count" {
  description = "Number of fault domains for the availability set"
  type        = number
  default     = 2

  validation {
    condition     = var.availability_set_fault_domain_count >= 1 && var.availability_set_fault_domain_count <= 3
    error_message = "Fault domain count must be between 1 and 3."
  }
}

variable "enable_availability_zones" {
  description = "Enable availability zones instead of availability set"
  type        = bool
  default     = true
}

variable "availability_zone" {
  description = "Availability zone for the VM (1, 2, or 3). Only used when enable_availability_zones is true."
  type        = string
  default     = "1"

  validation {
    condition     = contains(["1", "2", "3"], var.availability_zone)
    error_message = "Availability zone must be 1, 2, or 3."
  }
}

# VM Agent and Extension Configuration
variable "provision_vm_agent" {
  description = "Should the Azure VM Agent be provisioned on this Virtual Machine"
  type        = bool
  default     = true
}

variable "allow_extension_operations" {
  description = "Should Extension Operations be allowed on this Virtual Machine"
  type        = bool
  default     = true
}

variable "patch_mode" {
  description = "Specifies the mode of in-guest patching for this Linux Virtual Machine"
  type        = string
  default     = "ImageDefault"

  validation {
    condition     = contains(["AutomaticByPlatform", "ImageDefault"], var.patch_mode)
    error_message = "Patch mode must be either 'AutomaticByPlatform' or 'ImageDefault'."
  }
}

variable "patch_assessment_mode" {
  description = "Specifies the mode of VM Guest Patching for the Virtual Machine"
  type        = string
  default     = "ImageDefault"

  validation {
    condition     = contains(["AutomaticByPlatform", "ImageDefault"], var.patch_assessment_mode)
    error_message = "Patch assessment mode must be either 'AutomaticByPlatform' or 'ImageDefault'."
  }
}

variable "extensions_time_budget" {
  description = "Specifies the duration allocated for all extensions to start"
  type        = string
  default     = "PT1H30M"
}

#--------------------------------------------------------
# Public IP Configuration Variables
#--------------------------------------------------------

variable "public_ip_allocation_method" {
  description = "Public IP allocation method"
  type        = string
  default     = "Static"

  validation {
    condition     = contains(["Static", "Dynamic"], var.public_ip_allocation_method)
    error_message = "Public IP allocation method must be either 'Static' or 'Dynamic'."
  }
}

variable "public_ip_sku" {
  description = "Public IP SKU"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard"], var.public_ip_sku)
    error_message = "Public IP SKU must be either 'Basic' or 'Standard'."
  }
}

variable "public_ip_sku_tier" {
  description = "The SKU Tier that should be used for the Public IP"
  type        = string
  default     = "Regional"

  validation {
    condition     = contains(["Regional", "Global"], var.public_ip_sku_tier)
    error_message = "Public IP SKU tier must be either 'Regional' or 'Global'."
  }
}

variable "public_ip_idle_timeout" {
  description = "Specifies the timeout for the TCP idle connection"
  type        = number
  default     = 4

  validation {
    condition     = var.public_ip_idle_timeout >= 4 && var.public_ip_idle_timeout <= 30
    error_message = "Public IP idle timeout must be between 4 and 30 minutes."
  }
}

# Palo Alto Image Configuration
variable "vm_image_publisher" {
  description = "VM image publisher"
  type        = string
  default     = "paloaltonetworks"
}

variable "vm_image_offer" {
  description = "VM image offer"
  type        = string
  default     = "vmseries-flex"
}

variable "vm_image_sku" {
  description = "VM image SKU"
  type        = string
  default     = "byol"
}

variable "vm_image_version" {
  description = "VM image version"
  type        = string
  default     = "11.1.407"
}

# Disk Configuration
variable "os_disk_caching" {
  description = "OS disk caching"
  type        = string
  default     = "ReadWrite"
}

variable "os_disk_storage_account_type" {
  description = "OS disk storage account type"
  type        = string
  default     = "Standard_LRS"
}

variable "os_disk_size_gb" {
  description = "OS disk size in GB"
  type        = number
  default     = 60
}

# Network Interface Configuration
variable "mgmt_accelerated_networking_enabled" {
  description = "Enable accelerated networking on management interface"
  type        = bool
  default     = false
}

variable "mgmt_ip_forwarding_enabled" {
  description = "Enable IP forwarding on management interface"
  type        = bool
  default     = false
}

variable "untrust_accelerated_networking_enabled" {
  description = "Enable accelerated networking on untrust interface"
  type        = bool
  default     = true
}

variable "untrust_ip_forwarding_enabled" {
  description = "Enable IP forwarding on untrust interface"
  type        = bool
  default     = true
}

variable "trust_accelerated_networking_enabled" {
  description = "Enable accelerated networking on trust interface"
  type        = bool
  default     = true
}

variable "trust_ip_forwarding_enabled" {
  description = "Enable IP forwarding on trust interface"
  type        = bool
  default     = true
}

# IP Configuration
variable "mgmt_private_ip_allocation" {
  description = "Management interface private IP allocation method"
  type        = string
  default     = "Dynamic"
}

variable "mgmt_static_private_ip" {
  description = "Static private IP for management interface"
  type        = string
  default     = null
}

variable "untrust_private_ip_allocation" {
  description = "Untrust interface private IP allocation method"
  type        = string
  default     = "Dynamic"
}

variable "untrust_static_private_ip" {
  description = "Static private IP for untrust interface"
  type        = string
  default     = null
}

variable "trust_private_ip_allocation" {
  description = "Trust interface private IP allocation method"
  type        = string
  default     = "Dynamic"
}

variable "trust_static_private_ip" {
  description = "Static private IP for trust interface"
  type        = string
  default     = null
}

#--------------------------------------------------------
# Bootstrap Configuration Variables
#--------------------------------------------------------

variable "custom_data" {
  description = "Custom data for VM bootstrap configuration"
  type        = string
  default     = null
}

#--------------------------------------------------------
# Optional Configuration Variables - IaC Base Module Inputs
#--------------------------------------------------------

variable "enable_telemetry" {
  description = "Enable telemetry for the IaC base module"
  type        = bool
  default     = true
}

variable "lock" {
  description = "Resource lock configuration"
  type = object({
    kind = string
    name = optional(string, null)
  })
  default = null

  validation {
    condition     = var.lock != null ? contains(["CanNotDelete", "ReadOnly"], var.lock.kind) : true
    error_message = "Lock kind must be either 'CanNotDelete' or 'ReadOnly'."
  }
}

variable "role_assignments" {
  description = "Role assignments to create on the resources"
  type = map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
    principal_type                         = optional(string, null)
  }))
  default = {}
}

variable "custom_resource_group_name" {
  description = "(Optional) Name of an existing resource group to use. If provided, no new resource group will be created."
  type        = string
  default     = null
}

#--------------------------------------------------------
# Tags
#--------------------------------------------------------

variable "common_tags" {
  type        = map(string)
  description = "This is the default common tags for the entire resources."
}

variable "resource_tags" {
  type        = map(string)
  description = "(Optional) This tags which we can define specific to the resources. Default: {}"
  default     = {}
}