output "application_insights_id" {
  description = "The ID of the created Application Insights"
  value       = module.application_insights.id
}

output "application_insights_name" {
  description = "The name of the created Application Insights"
  value       = module.application_insights.name
}

output "api_keys" {
  description = "API keys created by the module"
  value       = module.application_insights.api_keys
  sensitive   = true
}

output "resource_group_name" {
  description = "The resource group name."
  value       = azurerm_resource_group.example.name
}
