output "id" {
  description = "The ID of the Log Analytics Workspace."
  value       = azurerm_log_analytics_workspace.log_analytics_workspace.id
}

output "name" {
  description = "The name of the Log Analytics Workspace."
  value       = azurerm_log_analytics_workspace.log_analytics_workspace.name
}

output "resource_group_name" {
  description = "The resource group name of the Log Analytics Workspace."
  value       = azurerm_log_analytics_workspace.log_analytics_workspace.resource_group_name
}

output "location" {
  description = "The location of the Log Analytics Workspace."
  value       = azurerm_log_analytics_workspace.log_analytics_workspace.location
}

output "sku" {
  description = "The SKU of the Log Analytics Workspace."
  value       = azurerm_log_analytics_workspace.log_analytics_workspace.sku
}

output "retention_in_days" {
  description = "The retention period in days for the Log Analytics Workspace."
  value       = azurerm_log_analytics_workspace.log_analytics_workspace.retention_in_days
}

output "daily_quota_gb" {
  description = "The daily quota in GB for the Log Analytics Workspace."
  value       = try(azurerm_log_analytics_workspace.log_analytics_workspace.daily_quota_gb, null)
}

output "reservation_capacity_in_gb_per_day" {
  description = "The reservation capacity in GB per day for the Log Analytics Workspace."
  value       = try(azurerm_log_analytics_workspace.log_analytics_workspace.reservation_capacity_in_gb_per_day, null)
}

output "workspace_id" {
  description = "The Workspace ID (customer ID) of the Log Analytics Workspace."
  value       = try(azurerm_log_analytics_workspace.log_analytics_workspace.workspace_id, null)
}

output "primary_shared_key" {
  description = "The primary shared key for the Log Analytics Workspace."
  value       = try(azurerm_log_analytics_workspace.log_analytics_workspace.primary_shared_key, null)
  sensitive   = true
}

output "secondary_shared_key" {
  description = "The secondary shared key for the Log Analytics Workspace."
  value       = try(azurerm_log_analytics_workspace.log_analytics_workspace.secondary_shared_key, null)
  sensitive   = true
}

output "solutions" {
  description = "Log Analytics solutions created for the workspace."
  value = {
    for name, solution in azurerm_log_analytics_solution.log_analytics_solution : name => {
      id   = solution.id
      name = solution.solution_name
    }
  }
}

output "data_export_rules" {
  description = "Data export rules created for the workspace."
  value = {
    for name, rule in azurerm_log_analytics_data_export_rule.log_analytics_data_export_rule : name => {
      id   = rule.id
      name = rule.name
    }
  }
}

output "windows_event_datasources" {
  description = "Windows Event Log data sources created for the workspace."
  value = {
    for name, ds in azurerm_log_analytics_datasource_windows_event.log_analytics_datasource_windows_event : name => {
      id   = ds.id
      name = ds.name
    }
  }
}

output "windows_performance_counters" {
  description = "Windows Performance Counter data sources created for the workspace."
  value = {
    for name, ds in azurerm_log_analytics_datasource_windows_performance_counter.log_analytics_datasource_windows_performance_counter : name => {
      id   = ds.id
      name = ds.name
    }
  }
}

output "storage_insights" {
  description = "Storage insights configurations created for the workspace."
  value = {
    for name, si in azurerm_log_analytics_storage_insights.log_analytics_storage_insights : name => {
      id   = si.id
      name = si.name
    }
  }
}

output "linked_services" {
  description = "Linked services created for the workspace."
  value = {
    for name, ls in azurerm_log_analytics_linked_service.log_analytics_linked_service : name => {
      id = ls.id
    }
  }
}

output "clusters" {
  description = "Log Analytics clusters created by the module."
  value = {
    for name, cluster in azurerm_log_analytics_cluster.log_analytics_cluster : name => {
      id           = cluster.id
      name         = cluster.name
      principal_id = try(cluster.identity[0].principal_id, null)
      tenant_id    = try(cluster.identity[0].tenant_id, null)
    }
  }
}

output "cluster_customer_managed_keys" {
  description = "Customer managed keys configured for Log Analytics clusters."
  value = {
    for name, cmk in azurerm_log_analytics_cluster_customer_managed_key.log_analytics_cluster_customer_managed_key : name => {
      id = cmk.id
    }
  }
}

output "diagnostic_settings_skipped" {
  description = "Diagnostic settings entries skipped because no log or metric categories were supplied."
  value       = local.diagnostic_settings_skipped
}
