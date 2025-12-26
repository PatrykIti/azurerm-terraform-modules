output "repository_ids" {
  description = "Map of repository IDs keyed by repository key."
  value       = module.azuredevops_repository.repository_ids
}

output "repository_urls" {
  description = "Map of repository web URLs keyed by repository key."
  value       = module.azuredevops_repository.repository_urls
}

output "branch_ids" {
  description = "Map of branch IDs keyed by branch key."
  value       = module.azuredevops_repository.branch_ids
}

output "policy_ids" {
  description = "Map of policy IDs grouped by policy type."
  value       = module.azuredevops_repository.policy_ids
}
