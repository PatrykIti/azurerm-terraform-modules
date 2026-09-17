output "id" {
  description = "The ID of the Azure Monitor Private Link Scope."
  value       = azurerm_monitor_private_link_scope.monitor_private_link_scope.id
}

output "name" {
  description = "The name of the Azure Monitor Private Link Scope."
  value       = azurerm_monitor_private_link_scope.monitor_private_link_scope.name
}

output "resource_group_name" {
  description = "The resource group name of the Azure Monitor Private Link Scope."
  value       = azurerm_monitor_private_link_scope.monitor_private_link_scope.resource_group_name
}

output "ingestion_access_mode" {
  description = "The ingestion access mode for the Azure Monitor Private Link Scope."
  value       = try(azurerm_monitor_private_link_scope.monitor_private_link_scope.ingestion_access_mode, null)
}

output "query_access_mode" {
  description = "The query access mode for the Azure Monitor Private Link Scope."
  value       = try(azurerm_monitor_private_link_scope.monitor_private_link_scope.query_access_mode, null)
}

output "scoped_service_ids" {
  description = "Map of scoped service names to resource IDs."
  value = {
    for name, service in azurerm_monitor_private_link_scoped_service.scoped_service :
    name => service.id
  }
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
  description = "The tags assigned to the Azure Monitor Private Link Scope."
  value       = azurerm_monitor_private_link_scope.monitor_private_link_scope.tags
}
