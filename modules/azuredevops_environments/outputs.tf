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
  description = "Map of check IDs grouped by target scope and keyed by check name."
  value = {
    environment = {
      approvals = {
        for key, check in azuredevops_check_approval.check_approval :
        local.check_approvals[key].check.name => check.id
        if local.check_approvals[key].scope == "environment"
      }
      branch_controls = {
        for key, check in azuredevops_check_branch_control.check_branch_control :
        local.check_branch_controls[key].check.name => check.id
        if local.check_branch_controls[key].scope == "environment"
      }
      business_hours = {
        for key, check in azuredevops_check_business_hours.check_business_hours :
        local.check_business_hours[key].check.name => check.id
        if local.check_business_hours[key].scope == "environment"
      }
      exclusive_locks = {
        for key, check in azuredevops_check_exclusive_lock.check_exclusive_lock :
        local.check_exclusive_locks[key].check.name => check.id
        if local.check_exclusive_locks[key].scope == "environment"
      }
      required_templates = {
        for key, check in azuredevops_check_required_template.check_required_template :
        local.check_required_templates[key].check.name => check.id
        if local.check_required_templates[key].scope == "environment"
      }
      rest_apis = {
        for key, check in azuredevops_check_rest_api.check_rest_api :
        local.check_rest_apis[key].check.name => check.id
        if local.check_rest_apis[key].scope == "environment"
      }
    }
    kubernetes_resources = {
      for resource_name in keys(azuredevops_environment_resource_kubernetes.environment_resource_kubernetes) :
      resource_name => {
        approvals = {
          for key, check in azuredevops_check_approval.check_approval :
          local.check_approvals[key].check.name => check.id
          if local.check_approvals[key].scope == "kubernetes" && local.check_approvals[key].resource_name == resource_name
        }
        branch_controls = {
          for key, check in azuredevops_check_branch_control.check_branch_control :
          local.check_branch_controls[key].check.name => check.id
          if local.check_branch_controls[key].scope == "kubernetes" && local.check_branch_controls[key].resource_name == resource_name
        }
        business_hours = {
          for key, check in azuredevops_check_business_hours.check_business_hours :
          local.check_business_hours[key].check.name => check.id
          if local.check_business_hours[key].scope == "kubernetes" && local.check_business_hours[key].resource_name == resource_name
        }
        exclusive_locks = {
          for key, check in azuredevops_check_exclusive_lock.check_exclusive_lock :
          local.check_exclusive_locks[key].check.name => check.id
          if local.check_exclusive_locks[key].scope == "kubernetes" && local.check_exclusive_locks[key].resource_name == resource_name
        }
        required_templates = {
          for key, check in azuredevops_check_required_template.check_required_template :
          local.check_required_templates[key].check.name => check.id
          if local.check_required_templates[key].scope == "kubernetes" && local.check_required_templates[key].resource_name == resource_name
        }
        rest_apis = {
          for key, check in azuredevops_check_rest_api.check_rest_api :
          local.check_rest_apis[key].check.name => check.id
          if local.check_rest_apis[key].scope == "kubernetes" && local.check_rest_apis[key].resource_name == resource_name
        }
      }
    }
  }
}
