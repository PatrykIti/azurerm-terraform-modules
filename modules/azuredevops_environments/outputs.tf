output "environment_id" {
  description = "ID of the Azure DevOps environment managed by this module."
  value       = try(azuredevops_environment.environment.id, null)
}

output "kubernetes_resource_ids" {
  description = "Map of Kubernetes resource IDs keyed by resource key or name."
  value = try({
    for key, resource in azuredevops_environment_resource_kubernetes.kubernetes_resource :
    key => resource.id
  }, {})
}

output "check_ids" {
  description = "Map of check IDs grouped by check type and keyed by check key or display_name."
  value = {
    approvals = try({
      for key, check in azuredevops_check_approval.check_approval :
      key => check.id
    }, {})
    branch_controls = try({
      for key, check in azuredevops_check_branch_control.check_branch_control :
      key => check.id
    }, {})
    business_hours = try({
      for key, check in azuredevops_check_business_hours.check_business_hours :
      key => check.id
    }, {})
    exclusive_locks = try({
      for key, check in azuredevops_check_exclusive_lock.check_exclusive_lock :
      key => check.id
    }, {})
    required_templates = try({
      for key, check in azuredevops_check_required_template.check_required_template :
      key => check.id
    }, {})
    rest_apis = try({
      for key, check in azuredevops_check_rest_api.check_rest_api :
      key => check.id
    }, {})
  }
}
