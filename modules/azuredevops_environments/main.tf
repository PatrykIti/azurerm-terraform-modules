# Azure DevOps Environments

locals {
  kubernetes_resources_by_name = {
    for resource in var.kubernetes_resources : resource.name => resource
  }

  kubernetes_approval_checks_by_key = {
    for item in flatten([
      for resource in var.kubernetes_resources : [
        for check in try(resource.checks.approvals, []) : {
          resource_name       = resource.name
          service_endpoint_id = resource.service_endpoint_id
          check               = check
        }
      ]
    ]) : format("%s:%s", item.resource_name, item.check.name) => item
  }

  kubernetes_branch_control_checks_by_key = {
    for item in flatten([
      for resource in var.kubernetes_resources : [
        for check in try(resource.checks.branch_controls, []) : {
          resource_name       = resource.name
          service_endpoint_id = resource.service_endpoint_id
          check               = check
        }
      ]
    ]) : format("%s:%s", item.resource_name, item.check.name) => item
  }

  kubernetes_business_hours_checks_by_key = {
    for item in flatten([
      for resource in var.kubernetes_resources : [
        for check in try(resource.checks.business_hours, []) : {
          resource_name       = resource.name
          service_endpoint_id = resource.service_endpoint_id
          check               = check
        }
      ]
    ]) : format("%s:%s", item.resource_name, item.check.name) => item
  }

  kubernetes_exclusive_lock_checks_by_key = {
    for item in flatten([
      for resource in var.kubernetes_resources : [
        for check in try(resource.checks.exclusive_locks, []) : {
          resource_name       = resource.name
          service_endpoint_id = resource.service_endpoint_id
          check               = check
        }
      ]
    ]) : format("%s:%s", item.resource_name, item.check.name) => item
  }

  kubernetes_required_template_checks_by_key = {
    for item in flatten([
      for resource in var.kubernetes_resources : [
        for check in try(resource.checks.required_templates, []) : {
          resource_name       = resource.name
          service_endpoint_id = resource.service_endpoint_id
          check               = check
        }
      ]
    ]) : format("%s:%s", item.resource_name, item.check.name) => item
  }

  kubernetes_rest_api_checks_by_key = {
    for item in flatten([
      for resource in var.kubernetes_resources : [
        for check in try(resource.checks.rest_apis, []) : {
          resource_name       = resource.name
          service_endpoint_id = resource.service_endpoint_id
          check               = check
        }
      ]
    ]) : format("%s:%s", item.resource_name, item.check.name) => item
  }
}

resource "azuredevops_environment" "environment" {
  project_id  = var.project_id
  name        = var.name
  description = var.description
}

resource "azuredevops_environment_resource_kubernetes" "environment_resource_kubernetes" {
  for_each = local.kubernetes_resources_by_name

  project_id          = var.project_id
  environment_id      = azuredevops_environment.environment.id
  service_endpoint_id = each.value.service_endpoint_id
  name                = each.value.name
  namespace           = each.value.namespace
  cluster_name        = each.value.cluster_name
  tags                = each.value.tags
}

# Environment-level checks
resource "azuredevops_check_approval" "check_approval_environment" {
  for_each = { for check in var.check_approvals : check.name => check }

  project_id                 = var.project_id
  target_resource_type       = "environment"
  target_resource_id         = azuredevops_environment.environment.id
  approvers                  = each.value.approvers
  instructions               = each.value.instructions
  minimum_required_approvers = each.value.minimum_required_approvers
  requester_can_approve      = each.value.requester_can_approve
  timeout                    = each.value.timeout
}

resource "azuredevops_check_branch_control" "check_branch_control_environment" {
  for_each = { for check in var.check_branch_controls : check.name => check }

  project_id                       = var.project_id
  display_name                     = each.value.name
  target_resource_type             = "environment"
  target_resource_id               = azuredevops_environment.environment.id
  allowed_branches                 = each.value.allowed_branches
  verify_branch_protection         = each.value.verify_branch_protection
  ignore_unknown_protection_status = each.value.ignore_unknown_protection_status
  timeout                          = each.value.timeout
}

resource "azuredevops_check_business_hours" "check_business_hours_environment" {
  for_each = { for check in var.check_business_hours : check.name => check }

  project_id           = var.project_id
  display_name         = each.value.name
  target_resource_type = "environment"
  target_resource_id   = azuredevops_environment.environment.id
  start_time           = each.value.start_time
  end_time             = each.value.end_time
  time_zone            = each.value.time_zone
  monday               = each.value.monday
  tuesday              = each.value.tuesday
  wednesday            = each.value.wednesday
  thursday             = each.value.thursday
  friday               = each.value.friday
  saturday             = each.value.saturday
  sunday               = each.value.sunday
  timeout              = each.value.timeout
}

resource "azuredevops_check_exclusive_lock" "check_exclusive_lock_environment" {
  for_each = { for check in var.check_exclusive_locks : check.name => check }

  project_id           = var.project_id
  target_resource_type = "environment"
  target_resource_id   = azuredevops_environment.environment.id
  timeout              = each.value.timeout
}

resource "azuredevops_check_required_template" "check_required_template_environment" {
  for_each = { for check in var.check_required_templates : check.name => check }

  project_id           = var.project_id
  target_resource_type = "environment"
  target_resource_id   = azuredevops_environment.environment.id

  dynamic "required_template" {
    for_each = each.value.required_templates
    content {
      template_path   = required_template.value.template_path
      repository_name = required_template.value.repository_name
      repository_ref  = required_template.value.repository_ref
      repository_type = required_template.value.repository_type
    }
  }
}

resource "azuredevops_check_rest_api" "check_rest_api_environment" {
  for_each = { for check in var.check_rest_apis : check.name => check }

  project_id                      = var.project_id
  display_name                    = each.value.name
  target_resource_type            = "environment"
  target_resource_id              = azuredevops_environment.environment.id
  connected_service_name_selector = each.value.connected_service_name_selector
  connected_service_name          = each.value.connected_service_name
  method                          = each.value.method
  body                            = each.value.body
  headers                         = each.value.headers
  retry_interval                  = each.value.retry_interval
  success_criteria                = each.value.success_criteria
  url_suffix                      = each.value.url_suffix
  variable_group_name             = each.value.variable_group_name
  completion_event                = each.value.completion_event
  timeout                         = each.value.timeout
}

# Kubernetes resource checks (target backing service endpoints)
resource "azuredevops_check_approval" "check_approval_kubernetes" {
  for_each = local.kubernetes_approval_checks_by_key

  project_id                 = var.project_id
  target_resource_type       = "endpoint"
  target_resource_id         = each.value.service_endpoint_id
  approvers                  = each.value.check.approvers
  instructions               = each.value.check.instructions
  minimum_required_approvers = each.value.check.minimum_required_approvers
  requester_can_approve      = each.value.check.requester_can_approve
  timeout                    = each.value.check.timeout

  depends_on = [azuredevops_environment_resource_kubernetes.environment_resource_kubernetes]
}

resource "azuredevops_check_branch_control" "check_branch_control_kubernetes" {
  for_each = local.kubernetes_branch_control_checks_by_key

  project_id                       = var.project_id
  display_name                     = each.value.check.name
  target_resource_type             = "endpoint"
  target_resource_id               = each.value.service_endpoint_id
  allowed_branches                 = each.value.check.allowed_branches
  verify_branch_protection         = each.value.check.verify_branch_protection
  ignore_unknown_protection_status = each.value.check.ignore_unknown_protection_status
  timeout                          = each.value.check.timeout

  depends_on = [azuredevops_environment_resource_kubernetes.environment_resource_kubernetes]
}

resource "azuredevops_check_business_hours" "check_business_hours_kubernetes" {
  for_each = local.kubernetes_business_hours_checks_by_key

  project_id           = var.project_id
  display_name         = each.value.check.name
  target_resource_type = "endpoint"
  target_resource_id   = each.value.service_endpoint_id
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

  depends_on = [azuredevops_environment_resource_kubernetes.environment_resource_kubernetes]
}

resource "azuredevops_check_exclusive_lock" "check_exclusive_lock_kubernetes" {
  for_each = local.kubernetes_exclusive_lock_checks_by_key

  project_id           = var.project_id
  target_resource_type = "endpoint"
  target_resource_id   = each.value.service_endpoint_id
  timeout              = each.value.check.timeout

  depends_on = [azuredevops_environment_resource_kubernetes.environment_resource_kubernetes]
}

resource "azuredevops_check_required_template" "check_required_template_kubernetes" {
  for_each = local.kubernetes_required_template_checks_by_key

  project_id           = var.project_id
  target_resource_type = "endpoint"
  target_resource_id   = each.value.service_endpoint_id

  dynamic "required_template" {
    for_each = each.value.check.required_templates
    content {
      template_path   = required_template.value.template_path
      repository_name = required_template.value.repository_name
      repository_ref  = required_template.value.repository_ref
      repository_type = required_template.value.repository_type
    }
  }

  depends_on = [azuredevops_environment_resource_kubernetes.environment_resource_kubernetes]
}

resource "azuredevops_check_rest_api" "check_rest_api_kubernetes" {
  for_each = local.kubernetes_rest_api_checks_by_key

  project_id                      = var.project_id
  display_name                    = each.value.check.name
  target_resource_type            = "endpoint"
  target_resource_id              = each.value.service_endpoint_id
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

  depends_on = [azuredevops_environment_resource_kubernetes.environment_resource_kubernetes]
}
