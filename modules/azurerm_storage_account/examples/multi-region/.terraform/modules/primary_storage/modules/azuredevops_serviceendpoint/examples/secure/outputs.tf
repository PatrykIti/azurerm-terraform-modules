output "serviceendpoint_id" {
  description = "Service endpoint ID created by the module."
  value       = module.azuredevops_serviceendpoint.serviceendpoint_id
}

output "permissions" {
  description = "Service endpoint permission IDs created by the module."
  value       = module.azuredevops_serviceendpoint.permissions
}
