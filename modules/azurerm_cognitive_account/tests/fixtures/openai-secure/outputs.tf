output "cognitive_account_id" {
  description = "The ID of the created Cognitive Account"
  value       = module.cognitive_account.id
}

output "cognitive_account_name" {
  description = "The name of the created Cognitive Account"
  value       = module.cognitive_account.name
}

output "resource_group_name" {
  description = "The resource group name for the Cognitive Account"
  value       = module.cognitive_account.resource_group_name
}

output "private_endpoint_id" {
  description = "The ID of the private endpoint created for the Cognitive Account"
  value       = azurerm_private_endpoint.openai.id
}
