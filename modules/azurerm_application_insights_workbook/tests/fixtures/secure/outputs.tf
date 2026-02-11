output "application_insights_workbook_id" {
  description = "The ID of the created Application Insights Workbook"
  value       = module.application_insights_workbook.id
}

output "application_insights_workbook_name" {
  description = "The name of the created Application Insights Workbook"
  value       = module.application_insights_workbook.name
}

output "resource_group_name" {
  description = "The resource group name"
  value       = azurerm_resource_group.example.name
}

output "identity_type" {
  description = "Identity type for the workbook"
  value       = try(module.application_insights_workbook.identity.type, null)
}

output "identity_ids" {
  description = "Identity IDs for the workbook"
  value       = try(module.application_insights_workbook.identity.identity_ids, null)
}
