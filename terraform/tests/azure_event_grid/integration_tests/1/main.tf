resource "azurerm_resource_group" "rg" {
    name = "rg-eventgrid-test"
    location = var.location
}

resource "azurerm_storage_account" "sa" {
    name = "eventgridtest01"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location

    account_tier = "Standard"
    account_replication_type = "LRS"
}

module "eventgrid" {
    source = "../../../../modules/azure_event_grid"

    system_topic_name = "storage-events-topic"
    subscription_name = "blob-created-sub"

    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location

    source_resource_id = azurerm_storage_account.sa.id

    topic_type = "Microsoft.Storage.StorageAccounts"

    webhook_url = var.webhook_url

    included_event_types = [
        "Microsoft.Storage.BlobCreated"
    ]
    
    tags = {
        environment = "test"
        application = "eventgrid-module"
    }
    }