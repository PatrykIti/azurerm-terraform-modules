output "application_insights_id" {
  description = "The ID of the created Application Insights."
  value       = module.application_insights.id
}

output "analytics_items" {
  description = "Analytics items created by the module."
  value       = module.application_insights.analytics_items
}
