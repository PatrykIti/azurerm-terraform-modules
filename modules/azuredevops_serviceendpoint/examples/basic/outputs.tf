output "serviceendpoint_ids" {
  description = "Service endpoint IDs created by the module."
  value       = module.azuredevops_serviceendpoint.serviceendpoint_ids
}
