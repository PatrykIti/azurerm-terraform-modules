# Azure DevOps Environments

locals {
  check_approvals = merge(
    {
      for check in var.check_approvals : format("environment:%s", check.name) => {
        scope         = "environment"
        resource_name = null
        check         = check
      }
    },
    {
      for item in flatten([
        for resource in var.kubernetes_resources : [
          for check in try(resource.checks.approvals, []) : {
            key = format("kubernetes:%s:%s", resource.name, check.name)
            value = {
              scope         = "kubernetes"
              resource_name = resource.name
              check         = check
            }
          }
        ]
      ]) : item.key => item.value
    }
  )

  check_branch_controls = merge(
    {
      for check in var.check_branch_controls : format("environment:%s", check.name) => {
        scope         = "environment"
        resource_name = null
        check         = check
      }
    },
    {
      for item in flatten([
        for resource in var.kubernetes_resources : [
          for check in try(resource.checks.branch_controls, []) : {
            key = format("kubernetes:%s:%s", resource.name, check.name)
            value = {
              scope         = "kubernetes"
              resource_name = resource.name
              check         = check
            }
          }
        ]
      ]) : item.key => item.value
    }
  )

  check_business_hours = merge(
    {
      for check in var.check_business_hours : format("environment:%s", check.name) => {
        scope         = "environment"
        resource_name = null
        check         = check
      }
    },
    {
      for item in flatten([
        for resource in var.kubernetes_resources : [
          for check in try(resource.checks.business_hours, []) : {
            key = format("kubernetes:%s:%s", resource.name, check.name)
            value = {
              scope         = "kubernetes"
              resource_name = resource.name
              check         = check
            }
          }
        ]
      ]) : item.key => item.value
    }
  )

  check_exclusive_locks = merge(
    {
      for check in var.check_exclusive_locks : format("environment:%s", check.name) => {
        scope         = "environment"
        resource_name = null
        check         = check
      }
    },
    {
      for item in flatten([
        for resource in var.kubernetes_resources : [
          for check in try(resource.checks.exclusive_locks, []) : {
            key = format("kubernetes:%s:%s", resource.name, check.name)
            value = {
              scope         = "kubernetes"
              resource_name = resource.name
              check         = check
            }
          }
        ]
      ]) : item.key => item.value
    }
  )

  check_required_templates = merge(
    {
      for check in var.check_required_templates : format("environment:%s", check.name) => {
        scope         = "environment"
        resource_name = null
        check         = check
      }
    },
    {
      for item in flatten([
        for resource in var.kubernetes_resources : [
          for check in try(resource.checks.required_templates, []) : {
            key = format("kubernetes:%s:%s", resource.name, check.name)
            value = {
              scope         = "kubernetes"
              resource_name = resource.name
              check         = check
            }
          }
        ]
      ]) : item.key => item.value
    }
  )

  check_rest_apis = merge(
    {
      for check in var.check_rest_apis : format("environment:%s", check.name) => {
        scope         = "environment"
        resource_name = null
        check         = check
      }
    },
    {
      for item in flatten([
        for resource in var.kubernetes_resources : [
          for check in try(resource.checks.rest_apis, []) : {
            key = format("kubernetes:%s:%s", resource.name, check.name)
            value = {
              scope         = "kubernetes"
              resource_name = resource.name
              check         = check
            }
          }
        ]
      ]) : item.key => item.value
    }
  )
}

resource "azuredevops_environment" "environment" {
  project_id  = var.project_id
  name        = var.name
  description = var.description
}

resource "azuredevops_environment_resource_kubernetes" "environment_resource_kubernetes" {
  for_each = { for resource in var.kubernetes_resources : resource.name => resource }

  project_id          = var.project_id
  environment_id      = azuredevops_environment.environment.id
  service_endpoint_id = each.value.service_endpoint_id
  name                = each.value.name
  namespace           = each.value.namespace
  cluster_name        = each.value.cluster_name
  tags                = each.value.tags
}

resource "azuredevops_check_approval" "check_approval" {
  for_each = local.check_approvals

  project_id                 = var.project_id
  target_resource_type       = "environment"
  target_resource_id         = each.value.scope == "environment" ? azuredevops_environment.environment.id : azuredevops_environment_resource_kubernetes.environment_resource_kubernetes[each.value.resource_name].id
  approvers                  = each.value.check.approvers
  instructions               = each.value.check.instructions
  minimum_required_approvers = each.value.check.minimum_required_approvers
  requester_can_approve      = each.value.check.requester_can_approve
  timeout                    = each.value.check.timeout
}

resource "azuredevops_check_branch_control" "check_branch_control" {
  for_each = local.check_branch_controls

  project_id                       = var.project_id
  display_name                     = each.value.check.name
  target_resource_type             = "environment"
  target_resource_id               = each.value.scope == "environment" ? azuredevops_environment.environment.id : azuredevops_environment_resource_kubernetes.environment_resource_kubernetes[each.value.resource_name].id
  allowed_branches                 = each.value.check.allowed_branches
  verify_branch_protection         = each.value.check.verify_branch_protection
  ignore_unknown_protection_status = each.value.check.ignore_unknown_protection_status
  timeout                          = each.value.check.timeout
}

resource "azuredevops_check_business_hours" "check_business_hours" {
  for_each = local.check_business_hours

  project_id           = var.project_id
  display_name         = each.value.check.name
  target_resource_type = "environment"
  target_resource_id   = each.value.scope == "environment" ? azuredevops_environment.environment.id : azuredevops_environment_resource_kubernetes.environment_resource_kubernetes[each.value.resource_name].id
  start_time           = each.value.check.start_time
  end_time             = each.value.check.end_time
  time_zone            = each.value.check.time_zone
  monday               = each.value.check.monday
  tuesday              = each.value.check.tuesday
  wednesday            = each.value.check.wednesday
  thursday             = each.value.check.thursday
  friday               = each.value.check.friday
  saturday             = each.value.check.saturday
  sunday               = each.value.check.sunday
  timeout              = each.value.check.timeout
}

resource "azuredevops_check_exclusive_lock" "check_exclusive_lock" {
  for_each = local.check_exclusive_locks

  project_id           = var.project_id
  target_resource_type = "environment"
  target_resource_id   = each.value.scope == "environment" ? azuredevops_environment.environment.id : azuredevops_environment_resource_kubernetes.environment_resource_kubernetes[each.value.resource_name].id
  timeout              = each.value.check.timeout
}

resource "azuredevops_check_required_template" "check_required_template" {
  for_each = local.check_required_templates

  project_id           = var.project_id
  target_resource_type = "environment"
  target_resource_id   = each.value.scope == "environment" ? azuredevops_environment.environment.id : azuredevops_environment_resource_kubernetes.environment_resource_kubernetes[each.value.resource_name].id

  dynamic "required_template" {
    for_each = each.value.check.required_templates
    content {
      template_path   = required_template.value.template_path
      repository_name = required_template.value.repository_name
      repository_ref  = required_template.value.repository_ref
      repository_type = required_template.value.repository_type
    }
  }
}

resource "azuredevops_check_rest_api" "check_rest_api" {
  for_each = local.check_rest_apis

  project_id                      = var.project_id
  display_name                    = each.value.check.name
  target_resource_type            = "environment"
  target_resource_id              = each.value.scope == "environment" ? azuredevops_environment.environment.id : azuredevops_environment_resource_kubernetes.environment_resource_kubernetes[each.value.resource_name].id
  connected_service_name_selector = each.value.check.connected_service_name_selector
  connected_service_name          = each.value.check.connected_service_name
  method                          = each.value.check.method
  body                            = each.value.check.body
  headers                         = each.value.check.headers
  retry_interval                  = each.value.check.retry_interval
  success_criteria                = each.value.check.success_criteria
  url_suffix                      = each.value.check.url_suffix
  variable_group_name             = each.value.check.variable_group_name
  completion_event                = each.value.check.completion_event
  timeout                         = each.value.check.timeout
}
