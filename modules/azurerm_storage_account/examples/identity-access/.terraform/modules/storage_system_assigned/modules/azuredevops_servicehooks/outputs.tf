output "webhook_id" {
  description = "ID of the webhook service hook when configured."
  value       = try(azuredevops_servicehook_webhook_tfs.webhook[0].id, null)
}

output "storage_queue_hook_id" {
  description = "ID of the storage queue service hook when configured."
  value       = try(azuredevops_servicehook_storage_queue_pipelines.storage_queue[0].id, null)
}

output "servicehook_permission_ids" {
  description = "Map of service hook permission IDs keyed by permission key."
  value       = try({ for key, permission in azuredevops_servicehook_permissions.servicehook_permissions : key => permission.id }, {})
}
