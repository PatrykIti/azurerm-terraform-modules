output "group_id" {
  description = "The ID of the Azure DevOps group managed by the module."
  value       = try(azuredevops_group.group.group_id, null)
}

output "group_descriptor" {
  description = "The descriptor of the Azure DevOps group managed by the module."
  value       = try(azuredevops_group.group.descriptor, null)
}

output "group_entitlement_ids" {
  description = "Map of group entitlement IDs keyed by entitlement key."
  value       = try({ for key, entitlement in azuredevops_group_entitlement.group_entitlement : key => entitlement.id }, {})
}

output "group_entitlement_descriptors" {
  description = "Map of group entitlement descriptors keyed by entitlement key."
  value       = try({ for key, entitlement in azuredevops_group_entitlement.group_entitlement : key => entitlement.descriptor }, {})
}

output "group_membership_ids" {
  description = "Map of group membership IDs keyed by membership key."
  value       = try({ for key, membership in azuredevops_group_membership.group_membership : key => membership.id }, {})
}
