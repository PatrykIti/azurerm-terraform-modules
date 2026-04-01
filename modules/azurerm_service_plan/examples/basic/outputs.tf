output "service_plan_id" {
  description = "The App Service Plan ID."
  value       = module.service_plan.id
}

output "service_plan_name" {
  description = "The App Service Plan name."
  value       = module.service_plan.name
}

output "service_plan_kind" {
  description = "The App Service Plan kind."
  value       = module.service_plan.kind
}
