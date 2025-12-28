output "group_id" {
  description = "The ID of the Azure DevOps group."
  value       = module.azuredevops_identity.group_id
}

output "group_descriptor" {
  description = "The descriptor of the Azure DevOps group."
  value       = module.azuredevops_identity.group_descriptor
}

output "group_membership_ids" {
  description = "Map of group membership IDs keyed by membership key."
  value       = module.azuredevops_identity.group_membership_ids
}

output "group_entitlement_ids" {
  description = "Map of group entitlement IDs keyed by entitlement key."
  value       = module.azuredevops_identity.group_entitlement_ids
}

output "user_entitlement_ids" {
  description = "Map of user entitlement IDs keyed by entitlement key."
  value       = module.azuredevops_identity.user_entitlement_ids
}

output "service_principal_entitlement_ids" {
  description = "Map of service principal entitlement IDs keyed by entitlement key."
  value       = module.azuredevops_identity.service_principal_entitlement_ids
}

output "securityrole_assignment_ids" {
  description = "Map of security role assignment IDs keyed by assignment key."
  value       = module.azuredevops_identity.securityrole_assignment_ids
}
