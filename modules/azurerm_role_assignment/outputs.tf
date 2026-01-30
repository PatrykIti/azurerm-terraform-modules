output "id" {
  description = "The ID of the Role Assignment"
  value       = try(azurerm_role_assignment.role_assignment.id, null)
}

output "name" {
  description = "The name of the Role Assignment"
  value       = try(azurerm_role_assignment.role_assignment.name, null)
}

output "scope" {
  description = "The scope for the Role Assignment."
  value       = try(azurerm_role_assignment.role_assignment.scope, null)
}

output "principal_id" {
  description = "The principal ID of the Role Assignment."
  value       = try(azurerm_role_assignment.role_assignment.principal_id, null)
}

output "role_definition_id" {
  description = "The role definition ID assigned."
  value       = try(azurerm_role_assignment.role_assignment.role_definition_id, null)
}

output "role_definition_name" {
  description = "The role definition name assigned (if using role_definition_name)."
  value       = try(azurerm_role_assignment.role_assignment.role_definition_name, null)
}

output "principal_type" {
  description = "The principal type assigned."
  value       = try(azurerm_role_assignment.role_assignment.principal_type, null)
}

output "condition" {
  description = "The ABAC condition expression, if configured."
  value       = try(azurerm_role_assignment.role_assignment.condition, null)
}

output "condition_version" {
  description = "The ABAC condition version, if configured."
  value       = try(azurerm_role_assignment.role_assignment.condition_version, null)
}

output "delegated_managed_identity_resource_id" {
  description = "The delegated managed identity resource ID, if configured."
  value       = try(azurerm_role_assignment.role_assignment.delegated_managed_identity_resource_id, null)
}
