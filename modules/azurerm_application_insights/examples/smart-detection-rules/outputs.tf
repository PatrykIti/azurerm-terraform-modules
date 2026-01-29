output "application_insights_id" {
  description = "The ID of the created Application Insights."
  value       = module.application_insights.id
}

output "smart_detection_rules" {
  description = "Smart detection rules created by the module."
  value       = module.application_insights.smart_detection_rules
}
