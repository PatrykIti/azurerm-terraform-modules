output "role_definition_id" {
  description = "The role definition ID."
  value       = module.role_definition.role_definition_id
}

output "resource_group_id" {
  description = "The resource group ID used for the scope."
  value       = azurerm_resource_group.example.id
}
