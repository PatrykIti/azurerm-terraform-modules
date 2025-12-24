output "environment_ids" {
  description = "Map of environment IDs keyed by environment key."
  value       = { for key, env in azuredevops_environment.environment : key => env.id }
}

output "kubernetes_resource_ids" {
  description = "Map of Kubernetes resource IDs keyed by index."
  value       = { for key, resource in azuredevops_environment_resource_kubernetes.kubernetes_resource : key => resource.id }
}

output "check_ids" {
  description = "Map of check IDs grouped by check type."
  value = {
    approvals        = { for key, check in azuredevops_check_approval.check_approval : key => check.id }
    branch_controls  = { for key, check in azuredevops_check_branch_control.check_branch_control : key => check.id }
    business_hours   = { for key, check in azuredevops_check_business_hours.check_business_hours : key => check.id }
    exclusive_locks  = { for key, check in azuredevops_check_exclusive_lock.check_exclusive_lock : key => check.id }
    required_templates = { for key, check in azuredevops_check_required_template.check_required_template : key => check.id }
    rest_apis         = { for key, check in azuredevops_check_rest_api.check_rest_api : key => check.id }
  }
}
