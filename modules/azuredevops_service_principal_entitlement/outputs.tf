output "service_principal_entitlement_id" {
  description = "The ID of the service principal entitlement."
  value       = try(azuredevops_service_principal_entitlement.service_principal_entitlement.id, null)
}

output "service_principal_entitlement_descriptor" {
  description = "The descriptor of the service principal entitlement."
  value       = try(azuredevops_service_principal_entitlement.service_principal_entitlement.descriptor, null)
}
