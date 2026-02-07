output "id" {
  description = "The ID of the Application Insights Workbook."
  value       = try(azurerm_application_insights_workbook.application_insights_workbook.id, null)
}

output "name" {
  description = "The name of the Application Insights Workbook."
  value       = try(azurerm_application_insights_workbook.application_insights_workbook.name, null)
}

output "location" {
  description = "The location of the Application Insights Workbook."
  value       = try(azurerm_application_insights_workbook.application_insights_workbook.location, null)
}

output "resource_group_name" {
  description = "The resource group name of the Application Insights Workbook."
  value       = try(azurerm_application_insights_workbook.application_insights_workbook.resource_group_name, null)
}

output "storage_container_id" {
  description = "The storage container resource ID configured for the workbook, when set."
  value       = try(azurerm_application_insights_workbook.application_insights_workbook.storage_container_id, null)
}

output "identity" {
  description = "Managed identity information for the workbook."
  value = try({
    type         = azurerm_application_insights_workbook.application_insights_workbook.identity[0].type
    principal_id = azurerm_application_insights_workbook.application_insights_workbook.identity[0].principal_id
    tenant_id    = azurerm_application_insights_workbook.application_insights_workbook.identity[0].tenant_id
    identity_ids = azurerm_application_insights_workbook.application_insights_workbook.identity[0].identity_ids
  }, null)
}
