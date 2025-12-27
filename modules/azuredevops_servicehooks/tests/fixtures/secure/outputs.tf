output "servicehook_ids" {
  description = "Service hook IDs created in this fixture."
  value       = module.azuredevops_servicehooks.servicehook_ids
}

output "servicehook_permission_ids" {
  description = "Service hook permission IDs created in this fixture."
  value       = module.azuredevops_servicehooks.servicehook_permission_ids
}
