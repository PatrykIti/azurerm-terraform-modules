output "environment_id" {
  description = "Environment ID created by the module."
  value       = module.azuredevops_environments.environment_id
}

output "check_ids" {
  description = "Check IDs created by the module."
  value       = module.azuredevops_environments.check_ids
}
