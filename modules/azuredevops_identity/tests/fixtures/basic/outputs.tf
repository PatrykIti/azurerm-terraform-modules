output "group_id" {
  description = "The ID of the Azure DevOps group."
  value       = module.azuredevops_identity.group_id
}

output "group_descriptor" {
  description = "The descriptor of the Azure DevOps group."
  value       = module.azuredevops_identity.group_descriptor
}
