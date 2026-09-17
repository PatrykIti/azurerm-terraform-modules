output "application_insights_id" {
  description = "The ID of the created Application Insights"
  value       = module.application_insights.id
}

output "application_insights_name" {
  description = "The name of the created Application Insights"
  value       = module.application_insights.name
}
