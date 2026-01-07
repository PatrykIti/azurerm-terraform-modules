output "user_entitlement_ids" {
  description = "Map of user entitlement IDs keyed by entitlement key."
  value       = try({ for key, entitlement in azuredevops_user_entitlement.user_entitlement : key => entitlement.id }, {})
}

output "user_entitlement_descriptors" {
  description = "Map of user entitlement descriptors keyed by entitlement key."
  value       = try({ for key, entitlement in azuredevops_user_entitlement.user_entitlement : key => entitlement.descriptor }, {})
}
