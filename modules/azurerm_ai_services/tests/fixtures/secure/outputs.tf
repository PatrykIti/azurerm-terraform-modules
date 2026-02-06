output "ai_services_id" {
  description = "The ID of the created AI Services Account"
  value       = module.ai_services.id
}

output "ai_services_name" {
  description = "The name of the created AI Services Account"
  value       = module.ai_services.name
}

output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.example.name
}
