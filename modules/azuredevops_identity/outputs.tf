output "group_id" {
  description = "The ID of the Azure DevOps group managed by the module."
  value       = try(azuredevops_group.group[0].group_id, null)
}

output "group_descriptor" {
  description = "The descriptor of the Azure DevOps group managed by the module."
  value       = try(azuredevops_group.group[0].descriptor, null)
}

output "group_entitlement_ids" {
  description = "Map of group entitlement IDs keyed by entitlement key."
  value       = try({ for key, entitlement in azuredevops_group_entitlement.group_entitlement : key => entitlement.id }, {})
}

output "group_entitlement_descriptors" {
  description = "Map of group entitlement descriptors keyed by entitlement key."
  value       = try({ for key, entitlement in azuredevops_group_entitlement.group_entitlement : key => entitlement.descriptor }, {})
}

output "user_entitlement_ids" {
  description = "Map of user entitlement IDs keyed by entitlement key."
  value       = try({ for key, entitlement in azuredevops_user_entitlement.user_entitlement : key => entitlement.id }, {})
}

output "user_entitlement_descriptors" {
  description = "Map of user entitlement descriptors keyed by entitlement key."
  value       = try({ for key, entitlement in azuredevops_user_entitlement.user_entitlement : key => entitlement.descriptor }, {})
}

output "service_principal_entitlement_ids" {
  description = "Map of service principal entitlement IDs keyed by entitlement key."
  value       = try({ for key, entitlement in azuredevops_service_principal_entitlement.service_principal_entitlement : key => entitlement.id }, {})
}

output "service_principal_entitlement_descriptors" {
  description = "Map of service principal entitlement descriptors keyed by entitlement key."
  value       = try({ for key, entitlement in azuredevops_service_principal_entitlement.service_principal_entitlement : key => entitlement.descriptor }, {})
}

output "group_membership_ids" {
  description = "Map of group membership IDs keyed by membership key."
  value       = try({ for key, membership in azuredevops_group_membership.group_membership : key => membership.id }, {})
}

output "securityrole_assignment_ids" {
  description = "Map of security role assignment IDs keyed by assignment key."
  value       = try({ for key, assignment in azuredevops_securityrole_assignment.securityrole_assignment : key => assignment.id }, {})
}
