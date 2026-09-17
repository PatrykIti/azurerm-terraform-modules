output "repository_id" {
  description = "Repository ID."
  value       = module.azuredevops_repository.repository_id
}

output "repository_url" {
  description = "Repository web URL."
  value       = module.azuredevops_repository.repository_url
}

output "file_ids" {
  description = "Map of file IDs keyed by file path and branch."
  value       = module.azuredevops_repository.file_ids
}

output "branch_ids" {
  description = "Map of branch IDs keyed by branch name."
  value       = module.azuredevops_repository.branch_ids
}

output "policy_ids" {
  description = "Map of policy IDs grouped by policy type."
  value       = module.azuredevops_repository.policy_ids
}
