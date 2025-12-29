output "serviceendpoint_id" {
  description = "Service endpoint ID created by the module."
  value       = try(local.serviceendpoint_id, null)
}

output "serviceendpoint_name" {
  description = "Service endpoint name created by the module."
  value       = try(local.serviceendpoint_name, null)
  sensitive   = true
}

output "permissions" {
  description = "Map of service endpoint permission IDs keyed by permission key."
  value       = try({ for key, permission in azuredevops_serviceendpoint_permissions.permissions : key => permission.id }, {})
}
