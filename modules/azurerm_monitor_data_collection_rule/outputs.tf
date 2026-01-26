output "id" {
  description = "The ID of the Data Collection Rule."
  value       = azurerm_monitor_data_collection_rule.monitor_data_collection_rule.id
}

output "name" {
  description = "The name of the Data Collection Rule."
  value       = azurerm_monitor_data_collection_rule.monitor_data_collection_rule.name
}

output "resource_group_name" {
  description = "The resource group name of the Data Collection Rule."
  value       = azurerm_monitor_data_collection_rule.monitor_data_collection_rule.resource_group_name
}

output "location" {
  description = "The location of the Data Collection Rule."
  value       = azurerm_monitor_data_collection_rule.monitor_data_collection_rule.location
}

output "description" {
  description = "The description of the Data Collection Rule."
  value       = try(azurerm_monitor_data_collection_rule.monitor_data_collection_rule.description, null)
}

output "kind" {
  description = "The kind of the Data Collection Rule."
  value       = try(azurerm_monitor_data_collection_rule.monitor_data_collection_rule.kind, null)
}

output "data_collection_endpoint_id" {
  description = "The Data Collection Endpoint ID used by the rule."
  value       = try(azurerm_monitor_data_collection_rule.monitor_data_collection_rule.data_collection_endpoint_id, null)
}

output "immutable_id" {
  description = "The immutable ID of the Data Collection Rule."
  value       = try(azurerm_monitor_data_collection_rule.monitor_data_collection_rule.immutable_id, null)
}

output "identity" {
  description = "The managed identity details for the Data Collection Rule."
  value = try({
    principal_id = azurerm_monitor_data_collection_rule.monitor_data_collection_rule.identity[0].principal_id
    tenant_id    = azurerm_monitor_data_collection_rule.monitor_data_collection_rule.identity[0].tenant_id
    type         = azurerm_monitor_data_collection_rule.monitor_data_collection_rule.identity[0].type
  }, null)
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
  description = "The tags assigned to the Data Collection Rule."
  value       = azurerm_monitor_data_collection_rule.monitor_data_collection_rule.tags
}
