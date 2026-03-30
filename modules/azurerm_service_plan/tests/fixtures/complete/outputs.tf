output "service_plan_id" {
  description = "The ID of the created App Service Plan."
  value       = module.service_plan.id
}

output "service_plan_name" {
  description = "The name of the created App Service Plan."
  value       = module.service_plan.name
}

output "resource_group_name" {
  description = "The resource group name."
  value       = azurerm_resource_group.example.name
}

output "reserved" {
  description = "Whether the App Service Plan is reserved for Linux."
  value       = module.service_plan.reserved
}

output "worker_count" {
  description = "Configured worker count."
  value       = module.service_plan.worker_count
}

output "zone_balancing_enabled" {
  description = "Whether zone balancing is enabled."
  value       = module.service_plan.zone_balancing_enabled
}

output "diagnostic_settings_skipped" {
  description = "Diagnostic settings skipped due to missing categories."
  value       = module.service_plan.diagnostic_settings_skipped
}
