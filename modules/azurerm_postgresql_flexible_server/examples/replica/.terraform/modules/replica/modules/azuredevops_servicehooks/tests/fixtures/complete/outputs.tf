output "webhook_id" {
  description = "Webhook ID created in this fixture."
  value       = module.azuredevops_servicehooks.webhook_id
}

output "storage_queue_hook_id" {
  description = "Storage queue hook ID created in this fixture."
  value       = module.azuredevops_servicehooks.storage_queue_hook_id
}

output "servicehook_permission_ids" {
  description = "Service hook permission IDs created in this fixture."
  value       = module.azuredevops_servicehooks.servicehook_permission_ids
}
