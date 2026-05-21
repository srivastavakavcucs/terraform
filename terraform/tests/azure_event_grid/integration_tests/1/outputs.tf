output "system_topic_id" {
    description = "Event Grid System topic ID"
    value = module.eventgrid.system_topic_id
}

output "event_subscription_id" {
    description = "Event Grid event subscription id"
    value = module.eventgrid.event_subscription_id
}