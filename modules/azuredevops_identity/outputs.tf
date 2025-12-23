output "group_ids" {
  description = "Map of group IDs keyed by group key."
  value       = { for key, group in azuredevops_group.group : key => group.group_id }
}

output "group_descriptors" {
  description = "Map of group descriptors keyed by group key."
  value       = { for key, group in azuredevops_group.group : key => group.descriptor }
}

output "group_entitlement_ids" {
  description = "Map of group entitlement IDs keyed by index."
  value       = { for key, entitlement in azuredevops_group_entitlement.group_entitlement : key => entitlement.id }
}

output "group_entitlement_descriptors" {
  description = "Map of group entitlement descriptors keyed by index."
  value       = { for key, entitlement in azuredevops_group_entitlement.group_entitlement : key => entitlement.descriptor }
}

output "user_entitlement_ids" {
  description = "Map of user entitlement IDs keyed by index."
  value       = { for key, entitlement in azuredevops_user_entitlement.user_entitlement : key => entitlement.id }
}

output "user_entitlement_descriptors" {
  description = "Map of user entitlement descriptors keyed by index."
  value       = { for key, entitlement in azuredevops_user_entitlement.user_entitlement : key => entitlement.descriptor }
}

output "service_principal_entitlement_ids" {
  description = "Map of service principal entitlement IDs keyed by index."
  value       = { for key, entitlement in azuredevops_service_principal_entitlement.service_principal_entitlement : key => entitlement.id }
}

output "service_principal_entitlement_descriptors" {
  description = "Map of service principal entitlement descriptors keyed by index."
  value       = { for key, entitlement in azuredevops_service_principal_entitlement.service_principal_entitlement : key => entitlement.descriptor }
}

output "group_membership_ids" {
  description = "Map of group membership IDs keyed by index."
  value       = { for key, membership in azuredevops_group_membership.group_membership : key => membership.id }
}
