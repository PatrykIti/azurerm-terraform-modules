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

output "premium_plan_auto_scale_enabled" {
  description = "Whether Premium autoscale is enabled."
  value       = module.service_plan.premium_plan_auto_scale_enabled
}

output "maximum_elastic_worker_count" {
  description = "Maximum elastic worker count configured for the plan."
  value       = module.service_plan.maximum_elastic_worker_count
}

output "reserved" {
  description = "Whether the App Service Plan is reserved for Linux."
  value       = module.service_plan.reserved
}
