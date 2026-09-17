# Azure DevOps Project

resource "azuredevops_project" "project" {
  name               = var.name
  description        = var.description
  visibility         = lower(var.visibility)
  version_control    = var.version_control
  work_item_template = var.work_item_template
  features           = var.features
}

resource "azuredevops_project_pipeline_settings" "project_pipeline_settings" {
  count = var.pipeline_settings == null ? 0 : 1

  project_id = azuredevops_project.project.id

  enforce_job_scope                    = try(var.pipeline_settings.enforce_job_scope, null)
  enforce_referenced_repo_scoped_token = try(var.pipeline_settings.enforce_referenced_repo_scoped_token, null)
  enforce_settable_var                 = try(var.pipeline_settings.enforce_settable_var, null)
  publish_pipeline_metadata            = try(var.pipeline_settings.publish_pipeline_metadata, null)
  status_badges_are_private            = try(var.pipeline_settings.status_badges_are_private, null)
  enforce_job_scope_for_release        = try(var.pipeline_settings.enforce_job_scope_for_release, null)
}

resource "azuredevops_project_tags" "project_tags" {
  count = length(var.project_tags) > 0 ? 1 : 0

  project_id = azuredevops_project.project.id
  tags       = var.project_tags
}

resource "azuredevops_dashboard" "dashboard" {
  for_each = { for dashboard in var.dashboards : dashboard.name => dashboard }

  project_id       = azuredevops_project.project.id
  name             = each.value.name
  description      = each.value.description
  team_id          = each.value.team_id
  refresh_interval = each.value.refresh_interval
}
