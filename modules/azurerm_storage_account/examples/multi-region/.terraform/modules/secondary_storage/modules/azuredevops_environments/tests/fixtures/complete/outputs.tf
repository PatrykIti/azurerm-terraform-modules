output "environment_id" {
  description = "Environment ID created by the module."
  value       = module.azuredevops_environments.environment_id
}

output "kubernetes_resource_ids" {
  description = "Kubernetes resource IDs created by the module."
  value       = module.azuredevops_environments.kubernetes_resource_ids
}

output "check_ids" {
  description = "Check IDs created by the module."
  value       = module.azuredevops_environments.check_ids
}

output "approval_check_ids" {
  description = "Approval check IDs created by the module."
  value       = module.azuredevops_environments.check_ids.environment.approvals
}
