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

output "user_entitlement_ids" {
  description = "Map of user entitlement IDs keyed by entitlement key."
  value       = module.azuredevops_identity.user_entitlement_ids
}

output "securityrole_assignment_ids" {
  description = "Map of security role assignment IDs keyed by assignment key."
  value       = module.azuredevops_identity.securityrole_assignment_ids
}
