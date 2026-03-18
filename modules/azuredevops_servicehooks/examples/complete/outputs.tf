output "webhook_ids" {
  description = "Webhook IDs created in this example, keyed by module instance."
  value       = { for key, instance in module.azuredevops_servicehooks : key => instance.webhook_id }
}
