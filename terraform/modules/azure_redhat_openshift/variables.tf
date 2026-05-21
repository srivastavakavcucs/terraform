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

#---------------------------------------------------------------------------------
# Network Contributor Role Assignment variables
#---------------------------------------------------------------------------------

# Principal ID for the ARO Cluster Service Principal
variable "aro_cluster_aad_sp_object_id" {
  description = "The object ID of the AAD Service Principal for the ARO Cluster."
  type        = string
  nullable    = false
  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.aro_cluster_aad_sp_object_id))
    error_message = "The ARO Cluster AAD Service Principal Object ID must be a valid UUID."
  }
}

# Principal ID for the ARO Resource Provider Service Principal
variable "aro_resource_provider_aad_sp_object_id" {
  description = "The object ID of the AAD Service Principal for the ARO Resource Provider."
  type        = string
  nullable    = false
  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.aro_resource_provider_aad_sp_object_id))
    error_message = "The ARO Resource Provider AAD Service Principal Object ID must be a valid UUID."
  }
}

#---------------------------------------------------------------------------------
# ARO Cluster Configuration variables
#---------------------------------------------------------------------------------

variable "main_subnet_name_segment" {
  description = "Name segment of the subnet for main/master nodes. Example: 'aro-main' for the segment of the subnet name of 'snet-aro-main-001-10.190.1.0_24'."
  type        = string
  nullable    = false
  validation {
    condition     = length(var.main_subnet_name_segment) > 3 && length(var.main_subnet_name_segment) <= 25
    error_message = "The main subnet name segment must be between 3 and 25 characters long."
  }
}

variable "worker_subnet_name_segment" {
  description = "Name segment of the subnet for worker nodes. Example: 'aro-workers' for the segment of the subnet name of 'snet-aro-workers-001-10.190.2.0_24'."
  type        = string
  nullable    = false
  validation {
    condition     = length(var.worker_subnet_name_segment) > 3 && length(var.worker_subnet_name_segment) <= 25
    error_message = "The worker subnet name segment must be between 3 and 25 characters long."
  }
}

# Service Principal Client ID
variable "sp_client_id" {
  description = "The Client ID for the Service Principal used for the Azure Red Hat OpenShift cluster."
  type        = string
  nullable    = false
}

# Service Principal Client Secret
variable "sp_client_secret" {
  description = "The Client Secret for the Service Principal used for the Azure Red Hat OpenShift cluster."
  type        = string
  nullable    = false
  sensitive   = true # Marked as sensitive to avoid being displayed in logs
}

# Additional Variables
variable "rh_pull_secret" {
  description = "Pull secret for Red Hat OpenShift"
  type        = string
  nullable    = false
  sensitive   = true
}

#--------------------------------------------------------
# Module Optional Inputs
#--------------------------------------------------------

#--------------------------------------------------------
# Please refer to:
# https://learn.microsoft.com/en-us/azure/openshift/support-policies-v4
# for more information on supported Control Plane and
# worker node VM types, sizes and node counts.
#--------------------------------------------------------
variable "main_vm_size" {
  description = "The size of the Virtual Machines for the main/master nodes."
  nullable    = false
  type        = string
  default     = "Standard_D8s_v5" # Default VM size for control plane
  validation {
    condition = contains(
      [
        # Dsv3 series
        "Standard_D8s_v3", "Standard_D16s_v3", "Standard_D32s_v3",
        # Dsv4 series
        "Standard_D8s_v4", "Standard_D16s_v4", "Standard_D32s_v4",
        # Dsv5 series
        "Standard_D8s_v5", "Standard_D16s_v5", "Standard_D32s_v5",
        # Dasv4 series
        "Standard_D8as_v4", "Standard_D16as_v4", "Standard_D32as_v4",
        # Dasv5 series
        "Standard_D8as_v5", "Standard_D16as_v5", "Standard_D32as_v5",
        # Easv4 series
        "Standard_E8as_v4", "Standard_E16as_v4", "Standard_E20as_v4",
        "Standard_E32as_v4", "Standard_E48as_v4", "Standard_E64as_v4", "Standard_E96as_v4",
        # Easv5 series
        "Standard_E8as_v5", "Standard_E16as_v5", "Standard_E20as_v5",
        "Standard_E32as_v5", "Standard_E48as_v5", "Standard_E64as_v5", "Standard_E96as_v5",
        # Eisv3, Eisv4, Esv4, Esv5, and Fsv2 series
        "Standard_E64is_v3", "Standard_E80is_v4", "Standard_E80ids_v4",
        "Standard_E104is_v5", "Standard_E104ids_v5", "Standard_E64s_v4",
        "Standard_E96s_v5", "Standard_F72s_v2", "Standard_M128ms"
      ],
      var.main_vm_size
    )
    error_message = "Main/Master VM size must be one of the supported sizes for Azure Red Hat OpenShift."
  }
}

# Worker Node VM Size
variable "worker_node_vm_size" {
  description = "The size of the Virtual Machines for the worker nodes."
  nullable    = false
  type        = string
  default     = "Standard_D4s_v5" # Default VM size for worker nodes
  validation {
    condition = contains(
      [
        # Dasv4 and Dasv5 series
        "Standard_D4as_v4", "Standard_D8as_v4", "Standard_D16as_v4", "Standard_D32as_v4", "Standard_D64as_v4", "Standard_D96as_v4",
        "Standard_D4as_v5", "Standard_D8as_v5", "Standard_D16as_v5", "Standard_D32as_v5", "Standard_D64as_v5", "Standard_D96as_v5",
        # Dsv3, Dsv4, and Dsv5 series
        "Standard_D4s_v3", "Standard_D8s_v3", "Standard_D16s_v3", "Standard_D32s_v3",
        "Standard_D4s_v4", "Standard_D8s_v4", "Standard_D16s_v4", "Standard_D32s_v4", "Standard_D64s_v4",
        "Standard_D4s_v5", "Standard_D8s_v5", "Standard_D16s_v5", "Standard_D32s_v5", "Standard_D64s_v5", "Standard_D96s_v5",
        # Easv4, Easv5, Esv4, Esv5, and Fsv2 series
        "Standard_E4as_v4", "Standard_E8as_v4", "Standard_E16as_v4", "Standard_E20as_v4", "Standard_E32as_v4",
        "Standard_E48as_v4", "Standard_E64as_v4", "Standard_E96as_v4",
        "Standard_E4as_v5", "Standard_E8as_v5", "Standard_E16as_v5", "Standard_E20as_v5", "Standard_E32as_v5",
        "Standard_E48as_v5", "Standard_E64as_v5", "Standard_E96as_v5",
        "Standard_E4s_v3", "Standard_E8s_v3", "Standard_E16s_v3", "Standard_E32s_v3",
        "Standard_E4s_v4", "Standard_E8s_v4", "Standard_E16s_v4", "Standard_E20s_v4", "Standard_E32s_v4",
        "Standard_E48s_v4", "Standard_E64s_v4", "Standard_E96s_v5",
        # Memory optimized and storage optimized
        "Standard_E104is_v5", "Standard_E64is_v3", "Standard_L4s", "Standard_L8s", "Standard_L16s",
        "Standard_L32s", "Standard_L64s_v2", "Standard_L48s_v2", "Standard_L64s_v3",
        # GPU-optimized
        "Standard_NC4as_T4_v3", "Standard_NC8as_T4_v3", "Standard_NC24ads_A100_v4", "Standard_ND96asr_v4"
      ],
      var.worker_node_vm_size
    )
    error_message = "Worker VM size must be one of the supported sizes for Azure Red Hat OpenShift."
  }
}

# Encryption at Host
variable "main_node_encryption_at_host_enabled" {
  description = "Whether Main/master virtual machines are encrypted at host."
  type        = bool
  nullable    = false
  default     = true
}

variable "worker_node_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 3 # Default number of worker nodes
  nullable    = false
}

variable "worker_node_disk_size_gb" {
  description = "The internal OS disk size of the worker Virtual Machines in GB."
  type        = number
  default     = 128 # Defaults to 128 GB Disk size for the worker nodes.
  nullable    = false
}

variable "pod_cidr" {
  description = "Pod CIDR block (must be private)"
  type        = string
  nullable    = false
  default     = "10.128.0.0/14" # Default Pod CIDR block
  validation {
    condition     = can(regex("^10\\.(?:[0-9]{1,3})\\.(?:[0-9]{1,3})\\.(?:[0-9]{1,3})/(1[0-9]|2[0-9]|3[0-2])$", var.pod_cidr))
    error_message = "Pod CIDR must be a valid private CIDR range starting with 10.x.x.x and a subnet mask between /10 and /32."
  }
}

variable "service_cidr" {
  description = "Service CIDR block (must be private)"
  type        = string
  nullable    = false
  default     = "172.30.0.0/16" # Default Service CIDR block
  validation {
    condition     = can(regex("^172\\.(1[6-9]|2[0-9]|3[0-1])\\.(?:[0-9]{1,3})\\.(?:[0-9]{1,3})/(1[0-9]|2[0-9]|3[0-2])$", var.service_cidr))
    error_message = "Service CIDR must be a valid private CIDR range starting with 172.16.x.x and a subnet mask between /16 and /32."
  }
}

variable "preconfigured_network_security_group_enabled" {
  description = "Whether a pre-configured network security group is being used on the subnets. Defaults to false. Changing this forces a new resource to be created."
  type        = bool
  default     = false
  nullable    = false
}

# Encryption at Host
variable "worker_node_encryption_at_host_enabled" {
  description = "Whether worker virtual machines are encrypted at host."
  type        = bool
  nullable    = false
  default     = true
}

variable "domain" {
  description = "Domain for the cluster"
  type        = string
  nullable    = false
  default     = "jaxnavy.org"
}

variable "openshift_version" {
  description = "Version of OpenShift to deploy"
  type        = string
  default     = "4.15.27"
  nullable    = false
  validation {
    condition     = can(regex("^(4\\.15\\.(2[7-9]|[3-9][0-9]|\\d{3,})|4\\.(1[6-9]|[2-9][0-9])\\.\\d+|[5-9]\\d*\\.\\d+\\.\\d+|[1-9]\\d{1,}\\.\\d+\\.\\d+)$", var.openshift_version))
    error_message = "OpenShift version must be 4.15.27 or higher, and in the format 'X.Y.Z' where X, Y, and Z are numeric values."
  }
}

variable "api_server_visibility" {
  description = "Visibility for the API server"
  type        = string
  default     = "Private"
  nullable    = false
  validation {
    condition     = var.api_server_visibility == "Public" || var.api_server_visibility == "Private"
    error_message = "API server visibility must be either 'Public' or 'Private'."
  }
}

variable "ingress_visibility" {
  description = "Visibility for the ingress controller"
  type        = string
  default     = "Private"
  nullable    = false
  validation {
    condition     = var.ingress_visibility == "Public" || var.ingress_visibility == "Private"
    error_message = "Ingress visibility must be either 'Public' or 'Private'."
  }
}

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
