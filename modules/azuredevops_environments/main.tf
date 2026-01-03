# Azure DevOps Environments
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

resource "azuredevops_check_branch_control" "check_branch_control" {
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

resource "azuredevops_check_business_hours" "check_business_hours" {
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

resource "azuredevops_check_exclusive_lock" "check_exclusive_lock" {
  for_each = { for check in var.check_exclusive_locks : check.name => check }

  project_id           = var.project_id
  target_resource_type = "environment"
  target_resource_id   = azuredevops_environment.environment.id
  timeout              = each.value.timeout
}

resource "azuredevops_check_required_template" "check_required_template" {
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

resource "azuredevops_check_rest_api" "check_rest_api" {
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
