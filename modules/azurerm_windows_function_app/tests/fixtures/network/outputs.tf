output "windows_function_app_id" {
  description = "The ID of the created Windows Function App"
  value       = module.windows_function_app.id
}

output "windows_function_app_name" {
  description = "The name of the created Windows Function App"
  value       = module.windows_function_app.name
}

output "resource_group_name" {
  description = "The resource group name"
  value       = azurerm_resource_group.test.name
}
