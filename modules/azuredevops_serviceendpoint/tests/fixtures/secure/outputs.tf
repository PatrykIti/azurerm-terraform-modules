output "generic_endpoint_ids" {
  description = "Generic service endpoint IDs created by the module."
  value       = module.azuredevops_serviceendpoint.serviceendpoint_ids.generic
}
