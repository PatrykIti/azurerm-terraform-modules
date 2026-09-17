output "user_entitlement_id" {
  description = "The ID of the Azure DevOps user entitlement managed by the module."
  value       = try(azuredevops_user_entitlement.user_entitlement.id, null)
}

output "user_entitlement_descriptor" {
  description = "The descriptor of the Azure DevOps user entitlement managed by the module."
  value       = try(azuredevops_user_entitlement.user_entitlement.descriptor, null)
}

output "user_entitlement_key" {
  description = "Derived key for the entitlement (key, principal_name, or origin_id)."
  value       = try(local.user_entitlement_key, null)
}
