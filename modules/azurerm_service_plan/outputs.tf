output "id" {
  description = "The ID of the App Service Plan."
  value       = try(azurerm_service_plan.service_plan.id, null)
}

output "name" {
  description = "The name of the App Service Plan."
  value       = try(azurerm_service_plan.service_plan.name, null)
}

output "location" {
  description = "The location of the App Service Plan."
  value       = try(azurerm_service_plan.service_plan.location, null)
}

output "resource_group_name" {
  description = "The name of the resource group containing the App Service Plan."
  value       = try(azurerm_service_plan.service_plan.resource_group_name, null)
}

output "kind" {
  description = "The kind of the App Service Plan."
  value       = try(azurerm_service_plan.service_plan.kind, null)
}

output "reserved" {
  description = "Whether the App Service Plan is reserved for Linux workloads."
  value       = try(azurerm_service_plan.service_plan.reserved, null)
}

output "os_type" {
  description = "The configured operating system type for the App Service Plan."
  value       = var.service_plan.os_type
}

output "sku_name" {
  description = "The configured SKU name for the App Service Plan."
  value       = var.service_plan.sku_name
}

output "worker_count" {
  description = "The configured worker count for the App Service Plan."
  value       = try(azurerm_service_plan.service_plan.worker_count, null)
}

output "maximum_elastic_worker_count" {
  description = "The configured maximum elastic worker count for the App Service Plan."
  value       = try(azurerm_service_plan.service_plan.maximum_elastic_worker_count, null)
}

output "premium_plan_auto_scale_enabled" {
  description = "Whether Premium autoscale is enabled for the App Service Plan."
  value       = try(azurerm_service_plan.service_plan.premium_plan_auto_scale_enabled, null)
}

output "per_site_scaling_enabled" {
  description = "Whether per-site scaling is enabled for the App Service Plan."
  value       = try(azurerm_service_plan.service_plan.per_site_scaling_enabled, null)
}

output "zone_balancing_enabled" {
  description = "Whether zone balancing is enabled for the App Service Plan."
  value       = try(azurerm_service_plan.service_plan.zone_balancing_enabled, null)
}

output "app_service_environment_id" {
  description = "The App Service Environment ID assigned to the App Service Plan, if any."
  value       = var.service_plan.app_service_environment_id
}

output "diagnostic_settings" {
  description = "Map of diagnostic settings keyed by name."
  value       = azurerm_monitor_diagnostic_setting.monitor_diagnostic_settings
}

output "diagnostic_settings_skipped" {
  description = "Diagnostic settings entries skipped because no log or metric categories were supplied."
  value = [
    for diagnostic_setting in var.diagnostic_settings : {
      name              = diagnostic_setting.name
      log_categories    = diagnostic_setting.log_categories
      metric_categories = diagnostic_setting.metric_categories
    }
    if(
      (diagnostic_setting.log_categories == null ? 0 : length(diagnostic_setting.log_categories)) +
      (diagnostic_setting.metric_categories == null ? 0 : length(diagnostic_setting.metric_categories))
    ) == 0
  ]
}

output "tags" {
  description = "The tags assigned to the App Service Plan."
  value       = try(azurerm_service_plan.service_plan.tags, null)
}
