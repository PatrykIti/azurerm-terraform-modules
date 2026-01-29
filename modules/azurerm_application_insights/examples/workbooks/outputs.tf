output "application_insights_id" {
  description = "The ID of the created Application Insights."
  value       = module.application_insights.id
}

output "workbooks" {
  description = "Workbooks created by the module."
  value       = module.application_insights.workbooks
}
