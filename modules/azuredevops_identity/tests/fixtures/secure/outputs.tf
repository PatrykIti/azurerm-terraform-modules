output "azuredevops_identity_id" {
  description = "The ID of the created Azure DevOps Identity"
  value       = module.azuredevops_identity.id
}

output "azuredevops_identity_name" {
  description = "The name of the created Azure DevOps Identity"
  value       = module.azuredevops_identity.name
}
