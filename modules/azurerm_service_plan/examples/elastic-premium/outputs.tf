output "service_plan_id" {
  description = "The App Service Plan ID."
  value       = module.service_plan.id
}

output "service_plan_name" {
  description = "The App Service Plan name."
  value       = module.service_plan.name
}

output "maximum_elastic_worker_count" {
  description = "Maximum elastic worker count configured for the plan."
  value       = module.service_plan.maximum_elastic_worker_count
}
