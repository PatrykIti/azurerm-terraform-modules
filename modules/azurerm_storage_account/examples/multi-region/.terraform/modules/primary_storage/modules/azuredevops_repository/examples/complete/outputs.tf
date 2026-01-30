output "repository_ids" {
  description = "Map of repository IDs keyed by module instance key."
  value       = { for key, module_instance in module.azuredevops_repository : key => module_instance.repository_id }
}

output "repository_urls" {
  description = "Map of repository URLs keyed by module instance key."
  value       = { for key, module_instance in module.azuredevops_repository : key => module_instance.repository_url }
}

output "branch_ids" {
  description = "Map of branch ID maps keyed by module instance key."
  value       = { for key, module_instance in module.azuredevops_repository : key => module_instance.branch_ids }
}

output "file_ids" {
  description = "Map of file ID maps keyed by module instance key."
  value       = { for key, module_instance in module.azuredevops_repository : key => module_instance.file_ids }
}

output "policy_ids" {
  description = "Map of policy ID maps keyed by module instance key."
  value       = { for key, module_instance in module.azuredevops_repository : key => module_instance.policy_ids }
}
