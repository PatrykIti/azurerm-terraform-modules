output "application_insights_id" {
  description = "The ID of the created Application Insights."
  value       = module.application_insights.id
}

output "web_tests" {
  description = "Classic web tests created by the module."
  value       = module.application_insights.web_tests
}
