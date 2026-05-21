variable "system_topic_name" {
  description = "Name of the Event grid system topic"
  type        = string
}

variable "subscription_name" {
  description = "Name of the Event grid event subscription"
  type        = string
}

variable "resource_group_name" {
  description = "Azure Resource Group Name"
  type        = string
}

variable "location" {
  description = "Azure Region"
  type        = string
}

variable "source_resource_id" {
  description = "Azure Resource ID for system topic"
  type        = string
}

variable "topic_type" {
  description = "Azure Event grid topic type"
  type        = string
}

variable "webhook_url" {
  description = "Webhook endpoint URL"
  type        = string
}

variable "included_event_types" {
  description = "List of included event types"
  type        = list(string)
  default = [
    "Microsoft.Storage.BlobCreated"
  ]
}

variable "tags" {
  description = "Tags applied to Resources"
  type        = map(string)
  default     = {}
}