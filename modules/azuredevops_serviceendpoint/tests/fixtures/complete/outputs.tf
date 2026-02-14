output "primary_serviceendpoint_id" {
  description = "Primary generic service endpoint ID created by the module."
  value       = module.azuredevops_serviceendpoint["generic"].serviceendpoint_id
}

output "secondary_serviceendpoint_id" {
  description = "Secondary generic service endpoint ID created by the module."
  value       = module.azuredevops_serviceendpoint["secondary"].serviceendpoint_id
}

output "primary_permissions" {
  description = "Primary service endpoint permission IDs created by the module."
  value       = module.azuredevops_serviceendpoint["generic"].permissions
}
