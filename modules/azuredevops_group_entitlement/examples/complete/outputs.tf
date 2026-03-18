output "group_entitlement_id" {
  description = "ID of the created group entitlement."
  value       = module.azuredevops_group_entitlement.group_entitlement_id
}

output "group_entitlement_key" {
  description = "Derived key for the entitlement."
  value       = module.azuredevops_group_entitlement.group_entitlement_key
}
