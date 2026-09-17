output "application_insights_id" {
  description = "The ID of the created Application Insights"
  value       = module.application_insights.id
}

output "standard_web_tests" {
  description = "Standard web tests created by the module"
  value       = module.application_insights.standard_web_tests
}

output "resource_group_name" {
  description = "The resource group name."
  value       = azurerm_resource_group.example.name
}
