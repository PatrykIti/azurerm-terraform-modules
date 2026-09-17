output "id" {
  description = "The ID of the Data Collection Endpoint."
  value       = azurerm_monitor_data_collection_endpoint.monitor_data_collection_endpoint.id
}

output "name" {
  description = "The name of the Data Collection Endpoint."
  value       = azurerm_monitor_data_collection_endpoint.monitor_data_collection_endpoint.name
}

output "resource_group_name" {
  description = "The resource group name of the Data Collection Endpoint."
  value       = azurerm_monitor_data_collection_endpoint.monitor_data_collection_endpoint.resource_group_name
}

output "location" {
  description = "The location of the Data Collection Endpoint."
  value       = azurerm_monitor_data_collection_endpoint.monitor_data_collection_endpoint.location
}

output "kind" {
  description = "The kind of the Data Collection Endpoint."
  value       = try(azurerm_monitor_data_collection_endpoint.monitor_data_collection_endpoint.kind, null)
}

output "public_network_access_enabled" {
  description = "Whether public network access is enabled."
  value       = try(azurerm_monitor_data_collection_endpoint.monitor_data_collection_endpoint.public_network_access_enabled, null)
}

output "description" {
  description = "The description of the Data Collection Endpoint."
  value       = try(azurerm_monitor_data_collection_endpoint.monitor_data_collection_endpoint.description, null)
}

output "immutable_id" {
  description = "The immutable ID of the Data Collection Endpoint."
  value       = try(azurerm_monitor_data_collection_endpoint.monitor_data_collection_endpoint.immutable_id, null)
}

output "configuration_access_endpoint" {
  description = "The configuration access endpoint for the Data Collection Endpoint."
  value       = try(azurerm_monitor_data_collection_endpoint.monitor_data_collection_endpoint.configuration_access_endpoint, null)
}

output "logs_ingestion_endpoint" {
  description = "The logs ingestion endpoint for the Data Collection Endpoint."
  value       = try(azurerm_monitor_data_collection_endpoint.monitor_data_collection_endpoint.logs_ingestion_endpoint, null)
}

output "metrics_ingestion_endpoint" {
  description = "The metrics ingestion endpoint for the Data Collection Endpoint."
  value       = try(azurerm_monitor_data_collection_endpoint.monitor_data_collection_endpoint.metrics_ingestion_endpoint, null)
}

output "diagnostic_settings_skipped" {
  description = "Diagnostic settings entries skipped because no log or metric categories were supplied."
  value = [
    for ds in var.monitoring : {
      name              = ds.name
      log_categories    = ds.log_categories
      metric_categories = ds.metric_categories
    }
    if(
      (ds.log_categories == null ? 0 : length(ds.log_categories)) +
      (ds.metric_categories == null ? 0 : length(ds.metric_categories))
    ) == 0
  ]
}

output "tags" {
  description = "The tags assigned to the Data Collection Endpoint."
  value       = azurerm_monitor_data_collection_endpoint.monitor_data_collection_endpoint.tags
}
