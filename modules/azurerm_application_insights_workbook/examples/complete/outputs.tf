output "application_insights_workbook_id" {
  description = "The ID of the created Application Insights Workbook"
  value       = module.application_insights_workbook.id
}

output "application_insights_workbook_name" {
  description = "The name of the created Application Insights Workbook"
  value       = module.application_insights_workbook.name
}
