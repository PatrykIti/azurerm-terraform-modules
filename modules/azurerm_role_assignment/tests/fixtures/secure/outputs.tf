output "role_assignment_id" {
  description = "The role assignment ID."
  value       = module.role_assignment.id
}

output "role_definition_id" {
  description = "The role definition ID assigned by the role assignment."
  value       = module.role_assignment.role_definition_id
}

output "resource_group_name" {
  description = "Resource group name."
  value       = azurerm_resource_group.example.name
}
