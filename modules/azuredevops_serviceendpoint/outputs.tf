output "serviceendpoint_id" {
  description = "Service endpoint ID created by the module."
  value       = azuredevops_serviceendpoint_generic.generic.id
}

output "serviceendpoint_name" {
  description = "Service endpoint name created by the module."
  value       = azuredevops_serviceendpoint_generic.generic.service_endpoint_name
  sensitive   = true
}

output "permissions" {
  description = "Map of service endpoint permission IDs keyed by permission key."
  value       = { for key, permission in azuredevops_serviceendpoint_permissions.permissions : key => permission.id }
}
