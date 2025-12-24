output "environment_ids" {
  description = "Environment IDs created by the module."
  value       = module.azuredevops_environments.environment_ids
}

output "check_ids" {
  description = "Check IDs created by the module."
  value       = module.azuredevops_environments.check_ids
}
