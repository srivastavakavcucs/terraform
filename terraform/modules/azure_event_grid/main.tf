resource "azurerm_eventgrid_system_topic" "this" {
  name                   = var.system_topic_name
  location               = var.location
  resource_group_name    = var.resource_group_name
  source_arm_resource_id = var.source_resource_id
  topic_type             = var.topic_type

  tags = var.tags
}

resource "azurerm_eventgrid_system_topic_event_subscription" "this" {
  name                = var.subscription_name
  system_topic        = azurerm_eventgrid_system_topic.this.name
  resource_group_name = var.resource_group_name

  included_event_types = var.included_event_types

  webhook_endpoint {
    url = var.webhook_url
  }

  retry_policy {
    max_delivery_attempts = 30
    event_time_to_live    = 1440
  }
}