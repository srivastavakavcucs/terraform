output "system_topic_id" {
  description = "ID of the Event Grid System Topic"

  value = azurerm_eventgrid_system_topic.this.id
}

output "system_topic_name" {
  description = "Name of the Event Grid System Topic"

  value = azurerm_eventgrid_system_topic.this.name
}

output "event_subscription_id" {
  description = "ID of the Event Subscription"

  value = azurerm_eventgrid_system_topic_event_subscription.this.id
}

output "event_subscription_name" {
  description = "Name of the Event Subscription"

  value = azurerm_eventgrid_system_topic_event_subscription.this.name
}





