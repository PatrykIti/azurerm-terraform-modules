output "user_assigned_identity_id" {
  description = "The ID of the created User Assigned Identity."
  value       = module.user_assigned_identity.id
}

output "user_assigned_identity_principal_id" {
  description = "The principal ID of the created User Assigned Identity."
  value       = module.user_assigned_identity.principal_id
}

output "role_assignment_id" {
  description = "The ID of the resource group role assignment."
  value       = azurerm_role_assignment.rg_reader.id
}
