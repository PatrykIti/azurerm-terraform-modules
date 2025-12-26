output "group_ids" {
  description = "Map of group IDs keyed by group key."
  value       = module.azuredevops_identity.group_ids
}

output "group_descriptors" {
  description = "Map of group descriptors keyed by group key."
  value       = module.azuredevops_identity.group_descriptors
}

output "group_membership_ids" {
  description = "Map of group membership IDs keyed by membership key."
  value       = module.azuredevops_identity.group_membership_ids
}
