#--------------------------------------------------------------------------------
# Create the Event Grid System Topic and Event Subscription
#--------------------------------------------------------------------------------

#--------------------------------------------------------------------------------
# Source: Azure Naming and Tagging Standards v4.0.0.0_20241022.docx
# Event Grid System Topic Naming: evtgrd-<app or service name>
# Example: evtgrd-navigator-prod
# NOTE: The naming here adds the environment suffix
#--------------------------------------------------------------------------------

resource "azurerm_eventgrid_system_topic" "this" {
  name                   = "evtgrd-${var.app_name}-${var.environment}-${var.environment_number_suffix}"
  location               = module.base.location
  resource_group_name    = module.base.resource_group_name
  source_arm_resource_id = var.source_resource_id
  topic_type             = var.topic_type

  tags = module.base.tags

  # Ensure that the resource group is created before attempting to deploy the Event Grid System Topic
  depends_on = [module.base]
}

#--------------------------------------------------------------------------------
# Create the Event Grid System Topic Event Subscription
#--------------------------------------------------------------------------------

resource "azurerm_eventgrid_system_topic_event_subscription" "this" {
  name                = "evtgrd-sub-${var.app_name}-${var.environment}-${var.environment_number_suffix}"
  system_topic_name   = azurerm_eventgrid_system_topic.this.name
  resource_group_name = module.base.resource_group_name

  # Event types to subscribe to
  included_event_types = var.included_event_types

  # Event delivery schema
  event_delivery_schema = var.event_delivery_schema

  # Labels for the subscription
  labels = var.labels

  # Webhook endpoint configuration
  webhook_endpoint {
    url = var.webhook_url
    active_directory_tenant_id = null
    active_directory_app_id_or_uri = null
  }

  # Webhook batch settings
  webhook_endpoint_properties {
    max_events_per_batch      = var.webhook_max_events_per_batch
    preferred_batch_size_in_kilobytes = var.webhook_preferred_batch_size_kb
  }

  # Retry policy configuration
  retry_policy {
    max_delivery_attempts = var.retry_policy.max_delivery_attempts != null ? var.retry_policy.max_delivery_attempts : 30
    event_time_to_live    = var.retry_policy.event_time_to_live != null ? var.retry_policy.event_time_to_live : 1440
  }

  # Advanced filtering - string begins with
  dynamic "advanced_filter" {
    for_each = var.advanced_filters != null && var.advanced_filters.string_begins_with != null ? var.advanced_filters.string_begins_with : []
    content {
      string_begins_with {
        key    = advanced_filter.value.key
        values = advanced_filter.value.values
      }
    }
  }

  # Advanced filtering - string ends with
  dynamic "advanced_filter" {
    for_each = var.advanced_filters != null && var.advanced_filters.string_ends_with != null ? var.advanced_filters.string_ends_with : []
    content {
      string_ends_with {
        key    = advanced_filter.value.key
        values = advanced_filter.value.values
      }
    }
  }

  # Advanced filtering - string contains
  dynamic "advanced_filter" {
    for_each = var.advanced_filters != null && var.advanced_filters.string_contains != null ? var.advanced_filters.string_contains : []
    content {
      string_contains {
        key    = advanced_filter.value.key
        values = advanced_filter.value.values
      }
    }
  }

  # Advanced filtering - number greater than
  dynamic "advanced_filter" {
    for_each = var.advanced_filters != null && var.advanced_filters.number_greater_than != null ? var.advanced_filters.number_greater_than : []
    content {
      number_greater_than {
        key   = advanced_filter.value.key
        value = advanced_filter.value.value
      }
    }
  }

  # Advanced filtering - number less than
  dynamic "advanced_filter" {
    for_each = var.advanced_filters != null && var.advanced_filters.number_less_than != null ? var.advanced_filters.number_less_than : []
    content {
      number_less_than {
        key   = advanced_filter.value.key
        value = advanced_filter.value.value
      }
    }
  }

  # Dead-letter endpoint configuration
  dynamic "dead_letter_endpoint" {
    for_each = var.dead_letter_endpoint != null ? [var.dead_letter_endpoint] : []
    content {
      storage_account_id          = dead_letter_endpoint.value.storage_account_id
      storage_blob_container_name = dead_letter_endpoint.value.storage_blob_container_name
    }
  }
}
