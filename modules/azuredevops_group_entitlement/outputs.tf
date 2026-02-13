output "group_entitlement_id" {
  description = "The ID of the Azure DevOps group entitlement managed by the module."
  value       = try(azuredevops_group_entitlement.group_entitlement.id, null)
}

output "group_entitlement_descriptor" {
  description = "The descriptor of the Azure DevOps group entitlement managed by the module."
  value       = try(azuredevops_group_entitlement.group_entitlement.descriptor, null)
}

output "group_entitlement_key" {
  description = "Derived key for the entitlement (key, display_name, or origin_id)."
  value       = try(local.group_entitlement_key, null)
}
