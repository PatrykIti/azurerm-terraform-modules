output "service_principal_entitlement_ids" {
  description = "Map of service principal entitlement IDs keyed by entitlement key."
  value       = module.azuredevops_service_principal_entitlement.service_principal_entitlement_ids
}
