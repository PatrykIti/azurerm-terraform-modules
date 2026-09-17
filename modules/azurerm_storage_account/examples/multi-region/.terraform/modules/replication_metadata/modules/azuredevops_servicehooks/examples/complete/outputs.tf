output "webhook_ids" {
  description = "Webhook IDs created in this example, keyed by module instance."
  value       = { for key, instance in module.azuredevops_servicehooks : key => instance.webhook_id }
}

output "storage_queue_hook_ids" {
  description = "Storage queue hook IDs created in this example, keyed by module instance."
  value       = { for key, instance in module.azuredevops_servicehooks : key => instance.storage_queue_hook_id }
}
