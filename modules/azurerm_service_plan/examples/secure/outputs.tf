output "service_plan_id" {
  description = "The App Service Plan ID."
  value       = module.service_plan.id
}

output "service_plan_name" {
  description = "The App Service Plan name."
  value       = module.service_plan.name
}

output "reserved" {
  description = "Whether the App Service Plan is reserved for Linux."
  value       = module.service_plan.reserved
}
