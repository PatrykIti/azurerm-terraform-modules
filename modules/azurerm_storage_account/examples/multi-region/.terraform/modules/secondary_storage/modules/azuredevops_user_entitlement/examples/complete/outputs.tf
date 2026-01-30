output "user_entitlement_ids" {
  description = "Map of user entitlement IDs keyed by entitlement key."
  value       = { for key, entitlement in module.azuredevops_user_entitlement : key => entitlement.user_entitlement_id }
}

output "user_entitlement_descriptors" {
  description = "Map of user entitlement descriptors keyed by entitlement key."
  value       = { for key, entitlement in module.azuredevops_user_entitlement : key => entitlement.user_entitlement_descriptor }
}
