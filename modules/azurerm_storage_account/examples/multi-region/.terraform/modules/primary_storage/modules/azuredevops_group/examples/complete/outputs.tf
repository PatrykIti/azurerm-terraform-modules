output "group_id" {
  description = "The ID of the Azure DevOps group."
  value       = module.azuredevops_group.group_id
}

output "group_descriptor" {
  description = "The descriptor of the Azure DevOps group."
  value       = module.azuredevops_group.group_descriptor
}

output "group_membership_ids" {
  description = "Map of group membership IDs keyed by membership key."
  value       = module.azuredevops_group.group_membership_ids
}

output "group_entitlement_ids" {
  description = "Map of group entitlement IDs keyed by entitlement key."
  value       = module.azuredevops_group.group_entitlement_ids
}
