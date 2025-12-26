output "servicehook_ids" {
  description = "Map of service hook IDs grouped by type."
  value = {
    webhook_tfs             = try({ for key, hook in azuredevops_servicehook_webhook_tfs.webhook : key => hook.id }, {})
    storage_queue_pipelines = try({ for key, hook in azuredevops_servicehook_storage_queue_pipelines.storage_queue : key => hook.id }, {})
  }
}

output "webhook_ids" {
  description = "Map of webhook service hook IDs keyed by webhook key."
  value       = try({ for key, hook in azuredevops_servicehook_webhook_tfs.webhook : key => hook.id }, {})
}

output "storage_queue_hook_ids" {
  description = "Map of storage queue service hook IDs keyed by hook key."
  value       = try({ for key, hook in azuredevops_servicehook_storage_queue_pipelines.storage_queue : key => hook.id }, {})
}

output "servicehook_permission_ids" {
  description = "Map of service hook permission IDs keyed by permission key."
  value       = try({ for key, permission in azuredevops_servicehook_permissions.servicehook_permissions : key => permission.id }, {})
}
