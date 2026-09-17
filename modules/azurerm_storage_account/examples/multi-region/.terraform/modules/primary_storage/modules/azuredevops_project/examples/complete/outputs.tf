output "project_id" {
  description = "ID of the Azure DevOps project."
  value       = module.azuredevops_project.project_id
}

output "project_name" {
  description = "Name of the Azure DevOps project."
  value       = module.azuredevops_project.project_name
}
