output "linux_function_app_id" {
  description = "The ID of the created Linux Function App"
  value       = module.linux_function_app.id
}

output "linux_function_app_name" {
  description = "The name of the created Linux Function App"
  value       = module.linux_function_app.name
}

output "resource_group_name" {
  description = "The resource group name"
  value       = azurerm_resource_group.example.name
}
