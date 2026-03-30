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

output "diagnostic_settings_skipped_count" {
  description = "Number of diagnostic settings skipped due to missing categories."
  value       = length(module.service_plan.diagnostic_settings_skipped)
}
