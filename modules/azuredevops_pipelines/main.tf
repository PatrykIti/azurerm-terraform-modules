# Azure DevOps Pipelines

locals {
  build_definition_ids = { for key, definition in azuredevops_build_definition.build_definition : key => definition.id }
  build_folders_by_key = {
    for folder in var.build_folders :
    coalesce(folder.key, folder.path) => folder
  }
  build_definition_permissions_by_key = {
    for permission in var.build_definition_permissions :
    coalesce(
      permission.key,
      format(
        "%s:%s",
        coalesce(permission.build_definition_key, permission.build_definition_id, "missing"),
        permission.principal
      )
    ) => permission
  }
  build_folder_permissions_by_key = {
    for permission in var.build_folder_permissions :
    coalesce(permission.key, format("%s:%s", permission.path, permission.principal)) => permission
  }
  pipeline_authorizations_by_key = {
    for authorization in var.pipeline_authorizations :
    coalesce(
      authorization.key,
      format(
        "%s:%s:%s",
        coalesce(authorization.pipeline_id, authorization.pipeline_key, "missing"),
        lower(authorization.type),
        authorization.resource_id
      )
    ) => authorization
  }
  resource_authorizations_by_key = {
    for authorization in var.resource_authorizations :
    coalesce(
      authorization.key,
      format(
        "%s:%s:%s",
        coalesce(authorization.definition_id, authorization.build_definition_key, "missing"),
        lower(authorization.type),
        authorization.resource_id
      )
    ) => authorization
  }
}

moved {
  from = azuredevops_resource_authorization.resource_authorization
  to   = azuredevops_pipeline_authorization.resource_authorization
}

resource "azuredevops_build_folder" "build_folder" {
  for_each = local.build_folders_by_key

  project_id  = var.project_id
  path        = each.value.path
  description = each.value.description
}

resource "azuredevops_build_definition" "build_definition" {
  for_each = var.build_definitions

  project_id              = var.project_id
  name                    = coalesce(each.value.name, each.key)
  path                    = each.value.path
  agent_pool_name         = each.value.agent_pool_name
  agent_specification     = each.value.agent_specification
  queue_status            = each.value.queue_status == null ? null : lower(each.value.queue_status)
  job_authorization_scope = each.value.job_authorization_scope

  repository {
    repo_id               = each.value.repository.repo_id
    repo_type             = each.value.repository.repo_type
    branch_name           = each.value.repository.branch_name
    service_connection_id = each.value.repository.service_connection_id
    yml_path              = each.value.repository.yml_path
    github_enterprise_url = each.value.repository.github_enterprise_url
    url                   = each.value.repository.url
    report_build_status   = each.value.repository.report_build_status
  }

  dynamic "ci_trigger" {
    for_each = each.value.ci_trigger == null ? [] : [each.value.ci_trigger]
    content {
      use_yaml = try(ci_trigger.value.use_yaml, null)

      dynamic "override" {
        for_each = ci_trigger.value.override == null ? [] : [ci_trigger.value.override]
        content {
          branch_filter {
            include = override.value.branch_filter.include
            exclude = try(override.value.branch_filter.exclude, null)
          }

          batch                            = try(override.value.batch, null)
          max_concurrent_builds_per_branch = try(override.value.max_concurrent_builds_per_branch, null)
          polling_interval                 = try(override.value.polling_interval, null)

          dynamic "path_filter" {
            for_each = override.value.path_filter == null ? [] : [override.value.path_filter]
            content {
              include = try(path_filter.value.include, null)
              exclude = try(path_filter.value.exclude, null)
            }
          }
        }
      }
    }
  }

  dynamic "pull_request_trigger" {
    for_each = each.value.pull_request_trigger == null ? [] : [each.value.pull_request_trigger]
    content {
      use_yaml       = try(pull_request_trigger.value.use_yaml, null)
      initial_branch = try(pull_request_trigger.value.initial_branch, null)

      dynamic "forks" {
        for_each = pull_request_trigger.value.forks == null ? [] : [pull_request_trigger.value.forks]
        content {
          enabled       = forks.value.enabled
          share_secrets = forks.value.share_secrets
        }
      }

      dynamic "override" {
        for_each = pull_request_trigger.value.override == null ? [] : [pull_request_trigger.value.override]
        content {
          branch_filter {
            include = override.value.branch_filter.include
            exclude = try(override.value.branch_filter.exclude, null)
          }

          auto_cancel = try(override.value.auto_cancel, null)

          dynamic "path_filter" {
            for_each = override.value.path_filter == null ? [] : [override.value.path_filter]
            content {
              include = try(path_filter.value.include, null)
              exclude = try(path_filter.value.exclude, null)
            }
          }
        }
      }
    }
  }

  dynamic "build_completion_trigger" {
    for_each = each.value.build_completion_trigger == null ? [] : [each.value.build_completion_trigger]
    content {
      build_definition_id = build_completion_trigger.value.build_definition_id

      branch_filter {
        include = build_completion_trigger.value.branch_filter.include
        exclude = try(build_completion_trigger.value.branch_filter.exclude, null)
      }
    }
  }

  dynamic "schedules" {
    for_each = each.value.schedules == null ? [] : each.value.schedules
    content {
      branch_filter {
        include = schedules.value.branch_filter.include
        exclude = try(schedules.value.branch_filter.exclude, null)
      }
      days_to_build              = schedules.value.days_to_build
      schedule_only_with_changes = try(schedules.value.schedule_only_with_changes, null)
      start_hours                = try(schedules.value.start_hours, null)
      start_minutes              = try(schedules.value.start_minutes, null)
      time_zone                  = try(schedules.value.time_zone, null)
    }
  }

  variable_groups = try(each.value.variable_groups, null)

  dynamic "variable" {
    for_each = each.value.variables == null ? [] : each.value.variables
    content {
      name           = variable.value.name
      value          = try(variable.value.value, null)
      secret_value   = try(variable.value.secret_value, null)
      is_secret      = try(variable.value.is_secret, null)
      allow_override = try(variable.value.allow_override, null)
    }
  }

  dynamic "features" {
    for_each = each.value.features == null ? [] : [each.value.features]
    content {
      skip_first_run = try(features.value.skip_first_run, null)
    }
  }

  dynamic "jobs" {
    for_each = each.value.jobs == null ? [] : each.value.jobs
    content {
      name                             = jobs.value.name
      ref_name                         = jobs.value.ref_name
      condition                        = jobs.value.condition
      job_timeout_in_minutes           = try(jobs.value.job_timeout_in_minutes, null)
      job_cancel_timeout_in_minutes    = try(jobs.value.job_cancel_timeout_in_minutes, null)
      job_authorization_scope          = try(jobs.value.job_authorization_scope, null)
      allow_scripts_auth_access_option = try(jobs.value.allow_scripts_auth_access_option, null)

      dynamic "dependencies" {
        for_each = jobs.value.dependencies == null ? [] : jobs.value.dependencies
        content {
          scope = dependencies.value.scope
        }
      }

      target {
        type    = jobs.value.target.type
        demands = try(jobs.value.target.demands, null)

        execution_options {
          type              = jobs.value.target.execution_options.type
          multipliers       = try(jobs.value.target.execution_options.multipliers, null)
          max_concurrency   = try(jobs.value.target.execution_options.max_concurrency, null)
          continue_on_error = try(jobs.value.target.execution_options.continue_on_error, null)
        }
      }
    }
  }

}

resource "azuredevops_build_definition_permissions" "build_definition_permissions" {
  for_each = local.build_definition_permissions_by_key

  project_id  = var.project_id
  principal   = each.value.principal
  permissions = each.value.permissions
  replace     = each.value.replace

  build_definition_id = coalesce(
    each.value.build_definition_id,
    try(local.build_definition_ids[each.value.build_definition_key], null)
  )

  lifecycle {
    precondition {
      condition = (
        each.value.build_definition_key == null ||
        contains(keys(var.build_definitions), each.value.build_definition_key)
      )
      error_message = "build_definition_permissions.build_definition_key must reference a key in build_definitions."
    }
  }
}

resource "azuredevops_build_folder_permissions" "build_folder_permissions" {
  for_each = local.build_folder_permissions_by_key

  project_id  = var.project_id
  path        = each.value.path
  principal   = each.value.principal
  permissions = each.value.permissions
  replace     = each.value.replace
}

resource "azuredevops_pipeline_authorization" "pipeline_authorization" {
  for_each = local.pipeline_authorizations_by_key

  project_id          = var.project_id
  resource_id         = each.value.resource_id
  type                = lower(each.value.type)
  pipeline_project_id = each.value.pipeline_project_id
  pipeline_id         = coalesce(each.value.pipeline_id, try(local.build_definition_ids[each.value.pipeline_key], null))

  lifecycle {
    precondition {
      condition = (
        each.value.pipeline_key == null ||
        contains(keys(var.build_definitions), each.value.pipeline_key)
      )
      error_message = "pipeline_authorizations.pipeline_key must reference a key in build_definitions."
    }
  }
}

resource "azuredevops_pipeline_authorization" "resource_authorization" {
  for_each = local.resource_authorizations_by_key

  project_id  = var.project_id
  resource_id = each.value.resource_id
  type        = lower(each.value.type)

  pipeline_id = coalesce(each.value.definition_id, try(local.build_definition_ids[each.value.build_definition_key], null))

  lifecycle {
    precondition {
      condition = (
        each.value.build_definition_key == null ||
        contains(keys(var.build_definitions), each.value.build_definition_key)
      )
      error_message = "resource_authorizations.build_definition_key must reference a key in build_definitions."
    }
  }
}
