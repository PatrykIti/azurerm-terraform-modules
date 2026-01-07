output "service_principal_entitlement_ids" {
  description = "Map of service principal entitlement IDs keyed by entitlement key."
  value       = try({ for key, entitlement in azuredevops_service_principal_entitlement.service_principal_entitlement : key => entitlement.id }, {})
}

output "service_principal_entitlement_descriptors" {
  description = "Map of service principal entitlement descriptors keyed by entitlement key."
  value       = try({ for key, entitlement in azuredevops_service_principal_entitlement.service_principal_entitlement : key => entitlement.descriptor }, {})
}
