output "user_entitlement_id" {
  description = "ID of the user entitlement."
  value       = module.azuredevops_user_entitlement.user_entitlement_id
}

output "user_entitlement_descriptor" {
  description = "Descriptor of the user entitlement."
  value       = module.azuredevops_user_entitlement.user_entitlement_descriptor
}

output "user_entitlement_key" {
  description = "Derived key for the user entitlement."
  value       = module.azuredevops_user_entitlement.user_entitlement_key
}
