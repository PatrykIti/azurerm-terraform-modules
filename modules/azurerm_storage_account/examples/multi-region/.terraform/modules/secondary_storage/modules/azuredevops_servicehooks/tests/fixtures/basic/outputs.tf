output "webhook_id" {
  description = "Webhook ID created in this fixture."
  value       = module.azuredevops_servicehooks.webhook_id
}
