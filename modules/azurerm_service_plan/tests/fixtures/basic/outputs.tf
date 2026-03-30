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

output "service_plan_kind" {
  description = "The kind of the App Service Plan."
  value       = module.service_plan.kind
}

output "reserved" {
  description = "Whether the App Service Plan is reserved for Linux."
  value       = module.service_plan.reserved
}

output "sku_name" {
  description = "Configured SKU name."
  value       = module.service_plan.sku_name
}
