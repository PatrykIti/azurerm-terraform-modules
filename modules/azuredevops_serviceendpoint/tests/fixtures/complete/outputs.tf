output "generic_serviceendpoint_id" {
  description = "Generic service endpoint ID created by the module."
  value       = module.azuredevops_serviceendpoint["generic"].serviceendpoint_id
}

output "incomingwebhook_serviceendpoint_id" {
  description = "Incoming webhook service endpoint ID created by the module."
  value       = module.azuredevops_serviceendpoint["incomingwebhook"].serviceendpoint_id
}

output "generic_permissions" {
  description = "Generic service endpoint permission IDs created by the module."
  value       = module.azuredevops_serviceendpoint["generic"].permissions
}
