output "webhook_id" {
  description = "ID of the webhook service hook."
  value       = azuredevops_servicehook_webhook_tfs.webhook.id
}
