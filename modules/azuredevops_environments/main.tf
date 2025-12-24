# Azure DevOps Environments

locals {
  environment_ids = { for key, env in azuredevops_environment.environment : key => env.id }
}

resource "azuredevops_environment" "environment" {
  for_each = var.environments

  project_id  = var.project_id
  name        = coalesce(each.value.name, each.key)
  description = each.value.description
}

resource "azuredevops_environment_resource_kubernetes" "kubernetes_resource" {
  for_each = { for index, resource in var.kubernetes_resources : index => resource }

  project_id          = var.project_id
  environment_id      = each.value.environment_id != null ? each.value.environment_id : try(local.environment_ids[each.value.environment_key], null)
  service_endpoint_id = each.value.service_endpoint_id
  name                = each.value.name
  namespace           = each.value.namespace
  cluster_name        = each.value.cluster_name
  tags                = each.value.tags
}

resource "azuredevops_check_approval" "check_approval" {
  for_each = { for index, check in var.check_approvals : index => check }

  project_id                 = var.project_id
  target_resource_id         = check.value.target_resource_id != null ? check.value.target_resource_id : try(local.environment_ids[check.value.target_environment_key], null)
  target_resource_type       = check.value.target_resource_type
  approvers                  = check.value.approvers
  instructions               = check.value.instructions
  minimum_required_approvers = check.value.minimum_required_approvers
  requester_can_approve      = check.value.requester_can_approve
  timeout                    = check.value.timeout
}

resource "azuredevops_check_branch_control" "check_branch_control" {
  for_each = { for index, check in var.check_branch_controls : index => check }

  project_id                       = var.project_id
  display_name                     = check.value.display_name
  target_resource_id               = check.value.target_resource_id != null ? check.value.target_resource_id : try(local.environment_ids[check.value.target_environment_key], null)
  target_resource_type             = check.value.target_resource_type
  allowed_branches                 = check.value.allowed_branches
  verify_branch_protection         = check.value.verify_branch_protection
  ignore_unknown_protection_status = check.value.ignore_unknown_protection_status
  timeout                          = check.value.timeout
}

resource "azuredevops_check_business_hours" "check_business_hours" {
  for_each = { for index, check in var.check_business_hours : index => check }

  project_id           = var.project_id
  display_name         = check.value.display_name
  target_resource_id   = check.value.target_resource_id != null ? check.value.target_resource_id : try(local.environment_ids[check.value.target_environment_key], null)
  target_resource_type = check.value.target_resource_type
  start_time           = check.value.start_time
  end_time             = check.value.end_time
  time_zone            = check.value.time_zone
  monday               = check.value.monday
  tuesday              = check.value.tuesday
  wednesday            = check.value.wednesday
  thursday             = check.value.thursday
  friday               = check.value.friday
  saturday             = check.value.saturday
  sunday               = check.value.sunday
  timeout              = check.value.timeout
}

resource "azuredevops_check_exclusive_lock" "check_exclusive_lock" {
  for_each = { for index, check in var.check_exclusive_locks : index => check }

  project_id           = var.project_id
  target_resource_id   = check.value.target_resource_id != null ? check.value.target_resource_id : try(local.environment_ids[check.value.target_environment_key], null)
  target_resource_type = check.value.target_resource_type
  timeout              = check.value.timeout
}

resource "azuredevops_check_required_template" "check_required_template" {
  for_each = { for index, check in var.check_required_templates : index => check }

  project_id           = var.project_id
  target_resource_id   = check.value.target_resource_id != null ? check.value.target_resource_id : try(local.environment_ids[check.value.target_environment_key], null)
  target_resource_type = check.value.target_resource_type

  dynamic "required_template" {
    for_each = check.value.required_templates
    content {
      template_path   = required_template.value.template_path
      repository_name = required_template.value.repository_name
      repository_ref  = required_template.value.repository_ref
      repository_type = required_template.value.repository_type
    }
  }
}

resource "azuredevops_check_rest_api" "check_rest_api" {
  for_each = { for index, check in var.check_rest_apis : index => check }

  project_id                      = var.project_id
  target_resource_id              = check.value.target_resource_id != null ? check.value.target_resource_id : try(local.environment_ids[check.value.target_environment_key], null)
  target_resource_type            = check.value.target_resource_type
  display_name                    = check.value.display_name
  connected_service_name_selector = check.value.connected_service_name_selector
  connected_service_name          = check.value.connected_service_name
  method                          = check.value.method
  body                            = check.value.body
  headers                         = check.value.headers
  retry_interval                  = check.value.retry_interval
  success_criteria                = check.value.success_criteria
  url_suffix                      = check.value.url_suffix
  variable_group_name             = check.value.variable_group_name
  completion_event                = check.value.completion_event
  timeout                         = check.value.timeout
}
