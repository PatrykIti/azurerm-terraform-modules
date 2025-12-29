output "repository_id" {
  description = "Repository ID."
  value       = module.azuredevops_repository.repository_id
}

output "repository_url" {
  description = "Repository URL."
  value       = module.azuredevops_repository.repository_url
}

output "branch_ids" {
  description = "Map of branch IDs keyed by branch key."
  value       = module.azuredevops_repository.branch_ids
}

output "file_ids" {
  description = "Map of file IDs keyed by file key."
  value       = module.azuredevops_repository.file_ids
}

output "policy_ids" {
  description = "Map of policy IDs grouped by policy type."
  value       = module.azuredevops_repository.policy_ids
}
