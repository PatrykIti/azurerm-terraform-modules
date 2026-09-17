output "application_insights_id" {
  description = "The ID of the created Application Insights."
  value       = module.application_insights.id
}

output "api_keys" {
  description = "API keys created by the module."
  value       = module.application_insights.api_keys
  sensitive   = true
}
