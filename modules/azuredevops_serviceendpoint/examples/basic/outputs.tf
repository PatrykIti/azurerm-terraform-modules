output "serviceendpoint_id" {
  description = "Service endpoint ID created by the module."
  value       = module.azuredevops_serviceendpoint.serviceendpoint_id
}

output "serviceendpoint_name" {
  description = "Service endpoint name created by the module."
  value       = module.azuredevops_serviceendpoint.serviceendpoint_name
  sensitive   = true
}
