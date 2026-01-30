output "role_definition_id" {
  description = "The role definition ID."
  value       = module.role_definition.role_definition_id
}

output "resource_group_name" {
  description = "Resource group name."
  value       = azurerm_resource_group.example.name
}
