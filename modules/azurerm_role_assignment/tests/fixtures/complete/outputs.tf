output "role_assignment_id" {
  description = "The role assignment ID."
  value       = module.role_assignment.id
}

output "role_assignment_name" {
  description = "The role assignment name."
  value       = module.role_assignment.name
}

output "resource_group_name" {
  description = "Resource group name."
  value       = azurerm_resource_group.example.name
}
