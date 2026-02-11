output "id" {
  description = "The ID of the Role Definition"
  value       = try(azurerm_role_definition.role_definition.id, null)
}

output "name" {
  description = "The name of the Role Definition"
  value       = try(azurerm_role_definition.role_definition.name, null)
}

output "role_definition_id" {
  description = "The role definition ID (GUID)."
  value       = try(azurerm_role_definition.role_definition.role_definition_id, null)
}

output "scope" {
  description = "The scope at which the role definition is created."
  value       = try(azurerm_role_definition.role_definition.scope, null)
}

output "assignable_scopes" {
  description = "The scopes where the role definition can be assigned."
  value       = try(azurerm_role_definition.role_definition.assignable_scopes, [])
}

output "description" {
  description = "The role definition description."
  value       = try(azurerm_role_definition.role_definition.description, null)
}
