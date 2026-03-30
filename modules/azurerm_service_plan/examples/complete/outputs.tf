output "service_plan_id" {
  description = "The App Service Plan ID."
  value       = module.service_plan.id
}

output "service_plan_name" {
  description = "The App Service Plan name."
  value       = module.service_plan.name
}

output "zone_balancing_enabled" {
  description = "Whether zone balancing is enabled."
  value       = module.service_plan.zone_balancing_enabled
}

output "diagnostic_settings_skipped" {
  description = "Diagnostic settings skipped due to missing categories."
  value       = module.service_plan.diagnostic_settings_skipped
}
