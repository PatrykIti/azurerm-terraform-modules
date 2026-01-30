output "serviceendpoint_ids" {
  description = "Service endpoint IDs created by the module instances."
  value       = { for key, module_instance in module.azuredevops_serviceendpoint : key => module_instance.serviceendpoint_id }
}

output "permissions" {
  description = "Service endpoint permission IDs created by the module instances."
  value       = { for key, module_instance in module.azuredevops_serviceendpoint : key => module_instance.permissions }
}
