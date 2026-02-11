output "cognitive_account_id" {
  description = "The Cognitive Account resource ID."
  value       = module.cognitive_account.id
}

output "cognitive_account_name" {
  description = "The Cognitive Account name."
  value       = module.cognitive_account.name
}

output "private_endpoint_id" {
  description = "The private endpoint resource ID."
  value       = azurerm_private_endpoint.openai.id
}
