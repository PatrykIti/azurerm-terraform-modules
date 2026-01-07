output "user_entitlement_ids" {
  description = "Map of user entitlement IDs keyed by entitlement key."
  value       = module.azuredevops_user_entitlement.user_entitlement_ids
}
