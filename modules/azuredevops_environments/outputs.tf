output "environment_id" {
  description = "ID of the Azure DevOps environment managed by this module."
  value       = azuredevops_environment.environment.id
}

output "kubernetes_resource_ids" {
  description = "Map of Kubernetes resource IDs keyed by resource name."
  value = {
    for key, resource in azuredevops_environment_resource_kubernetes.environment_resource_kubernetes :
    key => resource.id
  }
}

output "check_ids" {
  description = "Map of check IDs grouped by target: environment and kubernetes_resources."
  value = {
    environment = {
      approvals = {
        for key, check in azuredevops_check_approval.check_approval_environment : key => check.id
      }
      branch_controls = {
        for key, check in azuredevops_check_branch_control.check_branch_control_environment : key => check.id
      }
      business_hours = {
        for key, check in azuredevops_check_business_hours.check_business_hours_environment : key => check.id
      }
      exclusive_locks = {
        for key, check in azuredevops_check_exclusive_lock.check_exclusive_lock_environment : key => check.id
      }
      required_templates = {
        for key, check in azuredevops_check_required_template.check_required_template_environment : key => check.id
      }
      rest_apis = {
        for key, check in azuredevops_check_rest_api.check_rest_api_environment : key => check.id
      }
    }

    kubernetes_resources = {
      for resource_name in keys(local.kubernetes_resources_by_name) :
      resource_name => {
        approvals = {
          for key, check in azuredevops_check_approval.check_approval_kubernetes :
          split(":", key)[1] => check.id
          if split(":", key)[0] == resource_name
        }
        branch_controls = {
          for key, check in azuredevops_check_branch_control.check_branch_control_kubernetes :
          split(":", key)[1] => check.id
          if split(":", key)[0] == resource_name
        }
        business_hours = {
          for key, check in azuredevops_check_business_hours.check_business_hours_kubernetes :
          split(":", key)[1] => check.id
          if split(":", key)[0] == resource_name
        }
        exclusive_locks = {
          for key, check in azuredevops_check_exclusive_lock.check_exclusive_lock_kubernetes :
          split(":", key)[1] => check.id
          if split(":", key)[0] == resource_name
        }
        required_templates = {
          for key, check in azuredevops_check_required_template.check_required_template_kubernetes :
          split(":", key)[1] => check.id
          if split(":", key)[0] == resource_name
        }
        rest_apis = {
          for key, check in azuredevops_check_rest_api.check_rest_api_kubernetes :
          split(":", key)[1] => check.id
          if split(":", key)[0] == resource_name
        }
      }
    }
  }
}
