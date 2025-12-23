output "azuredevops_project_id" {
  description = "The ID of the created Azure DevOps Project"
  value       = module.azuredevops_project.id
}

output "azuredevops_project_name" {
  description = "The name of the created Azure DevOps Project"
  value       = module.azuredevops_project.name
}
