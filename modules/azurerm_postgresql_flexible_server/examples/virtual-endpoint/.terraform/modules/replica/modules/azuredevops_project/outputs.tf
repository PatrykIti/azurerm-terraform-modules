output "project_id" {
  description = "The ID of the Azure DevOps project."
  value       = azuredevops_project.project.id
}

output "project_name" {
  description = "The name of the Azure DevOps project."
  value       = azuredevops_project.project.name
}

output "project_description" {
  description = "The description of the Azure DevOps project."
  value       = azuredevops_project.project.description
}

output "project_visibility" {
  description = "The visibility of the Azure DevOps project."
  value       = azuredevops_project.project.visibility
}

output "project_version_control" {
  description = "The version control system used by the project."
  value       = azuredevops_project.project.version_control
}

output "project_work_item_template" {
  description = "The work item template used by the project."
  value       = azuredevops_project.project.work_item_template
}

output "project_process_template_id" {
  description = "The process template ID used by the project."
  value       = azuredevops_project.project.process_template_id
}

output "project_pipeline_settings_id" {
  description = "The ID returned by azuredevops_project_pipeline_settings when managed."
  value       = try(azuredevops_project_pipeline_settings.project_pipeline_settings[0].id, null)
}

output "project_tags" {
  description = "Tags assigned to the project (when managed)."
  value       = try(azuredevops_project_tags.project_tags[0].tags, [])
}

output "dashboard_ids" {
  description = "Map of dashboard IDs keyed by dashboard name."
  value       = { for key, dashboard in azuredevops_dashboard.dashboard : key => dashboard.id }
}

output "dashboard_owner_ids" {
  description = "Map of dashboard owner IDs keyed by dashboard name."
  value       = { for key, dashboard in azuredevops_dashboard.dashboard : key => dashboard.owner_id }
}
