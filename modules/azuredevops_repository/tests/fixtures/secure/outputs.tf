output "azuredevops_repository_id" {
  description = "The ID of the created Azure DevOps Repository"
  value       = module.azuredevops_repository.id
}

output "azuredevops_repository_name" {
  description = "The name of the created Azure DevOps Repository"
  value       = module.azuredevops_repository.name
}
