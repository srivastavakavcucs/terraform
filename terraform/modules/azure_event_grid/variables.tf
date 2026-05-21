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
# Module Required Inputs
#---------------------------------------------------------------------------------

variable "source_resource_id" {
  description = "The ARM resource ID for the source resource that triggers the Event Grid topic."
  type        = string
}

variable "topic_type" {
  description = <<EOT
The type of topic for the Event Grid System Topic.
Valid values: "Microsoft.Storage.StorageAccounts", "Microsoft.KeyVault.vaults", "Microsoft.ServiceBus.Namespaces", etc.
EOT
  type        = string

  validation {
    condition     = can(regex("^Microsoft\\.", var.topic_type))
    error_message = "The topic_type must be a valid Azure Resource Provider namespace (e.g., 'Microsoft.Storage.StorageAccounts')."
  }
}

variable "webhook_url" {
  description = "The URL of the webhook endpoint that will receive events."
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^https://", var.webhook_url))
    error_message = "The webhook_url must be a valid HTTPS URL."
  }
}

variable "subscription_name" {
  description = "The name of the Event Grid event subscription."
  type        = string
}

#---------------------------------------------------------------------------------
# Module Optional Inputs
#---------------------------------------------------------------------------------

variable "included_event_types" {
  description = <<EOT
List of event types to subscribe to. Use ["Microsoft.EventGrid.SubscriptionValidationEvent", "Microsoft.EventGrid.SubscriptionDeletedEvent"]
to receive subscription validation and deletion events. Default includes common storage events.
EOT
  type        = list(string)
  default = [
    "Microsoft.Storage.BlobCreated",
    "Microsoft.Storage.BlobDeleted"
  ]
}

variable "event_delivery_schema" {
  description = <<EOT
The schema in which events should be delivered to the endpoint.
Valid values: "EventGridSchema", "CloudEventSchemaV1_0", "CustomEventSchema".
Default: "EventGridSchema"
EOT
  type        = string
  default     = "EventGridSchema"

  validation {
    condition     = contains(["EventGridSchema", "CloudEventSchemaV1_0", "CustomEventSchema"], var.event_delivery_schema)
    error_message = "The event_delivery_schema must be one of 'EventGridSchema', 'CloudEventSchemaV1_0', or 'CustomEventSchema'."
  }
}

variable "labels" {
  description = "A list of labels to assign to the event subscription. Default: []"
  type        = list(string)
  default     = []
}

variable "webhook_max_events_per_batch" {
  description = "The maximum number of events per batch sent to the webhook endpoint. Default: 1."
  type        = number
  default     = 1

  validation {
    condition     = var.webhook_max_events_per_batch >= 1 && var.webhook_max_events_per_batch <= 5000
    error_message = "The webhook_max_events_per_batch must be between 1 and 5000."
  }
}

variable "webhook_preferred_batch_size_kb" {
  description = "The preferred batch size in kilobytes for the webhook endpoint. Default: 64."
  type        = number
  default     = 64

  validation {
    condition     = var.webhook_preferred_batch_size_kb >= 1 && var.webhook_preferred_batch_size_kb <= 1024
    error_message = "The webhook_preferred_batch_size_kb must be between 1 and 1024."
  }
}

variable "retry_policy" {
  description = <<EOT
Retry policy configuration for failed event deliveries.
- `max_delivery_attempts` (Optional): Maximum number of delivery attempts. Default: 30 (max: 30).
- `event_time_to_live` (Optional): Event time to live in minutes. Default: 1440 (max: 1440).
EOT
  type = object({
    max_delivery_attempts = optional(number, 30)
    event_time_to_live    = optional(number, 1440)
  })
  default = {}

  validation {
    condition     = var.retry_policy.max_delivery_attempts == null || (var.retry_policy.max_delivery_attempts >= 1 && var.retry_policy.max_delivery_attempts <= 30)
    error_message = "The max_delivery_attempts must be between 1 and 30."
  }

  validation {
    condition     = var.retry_policy.event_time_to_live == null || (var.retry_policy.event_time_to_live >= 1 && var.retry_policy.event_time_to_live <= 1440)
    error_message = "The event_time_to_live must be between 1 and 1440 minutes."
  }
}

variable "advanced_filters" {
  description = <<EOT
Advanced filtering options for events. Allows filtering by string patterns and numeric values.
Each filter type supports multiple conditions.
EOT
  type = object({
    string_begins_with = optional(list(object({
      key    = string
      values = list(string)
    })), null)

    string_ends_with = optional(list(object({
      key    = string
      values = list(string)
    })), null)

    string_contains = optional(list(object({
      key    = string
      values = list(string)
    })), null)

    number_greater_than = optional(list(object({
      key   = string
      value = number
    })), null)

    number_less_than = optional(list(object({
      key   = string
      value = number
    })), null)
  })
  default = null
}

variable "dead_letter_endpoint" {
  description = <<EOT
Configuration for the dead-letter endpoint to store events that cannot be delivered.
- `storage_account_id` (Required): The resource ID of the storage account.
- `storage_blob_container_name` (Required): The name of the blob container in the storage account.
EOT
  type = object({
    storage_account_id          = string
    storage_blob_container_name = string
  })
  default = null
}

variable "lock" {
  description = "(Optional) Controls the Resource Lock configuration for this resource. Default: null"
  type = object({
    kind = string
  })
  default = null
}

variable "enable_telemetry" {
  description = "(Optional) Enable telemetry for the module. Default: true."
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
  nullable    = false
}

variable "resource_tags" {
  type        = map(string)
  description = "This tags which we can define specific to the resources. Default: {}"
  default     = {}
}
