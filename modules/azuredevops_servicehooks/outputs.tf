output "servicehook_ids" {
  description = "Map of service hook IDs grouped by type."
  value = {
    webhook_tfs             = { for key, hook in azuredevops_servicehook_webhook_tfs.webhook : key => hook.id }
    storage_queue_pipelines = { for key, hook in azuredevops_servicehook_storage_queue_pipelines.storage_queue : key => hook.id }
  }
}
