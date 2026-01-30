output "webhook_id" {
  description = "Webhook ID created in this example."
  value       = module.azuredevops_servicehooks.webhook_id
}

output "servicehook_permission_ids" {
  description = "Service hook permission IDs created in this example."
  value       = module.azuredevops_servicehooks.servicehook_permission_ids
}
