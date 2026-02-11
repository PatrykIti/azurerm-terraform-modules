output "user_assigned_identity_id" {
  description = "The ID of the created User Assigned Identity."
  value       = module.user_assigned_identity.id
}

output "user_assigned_identity_name" {
  description = "The name of the created User Assigned Identity."
  value       = module.user_assigned_identity.name
}

output "user_assigned_identity_principal_id" {
  description = "The principal ID of the created User Assigned Identity."
  value       = module.user_assigned_identity.principal_id
}

output "federated_identity_credentials" {
  description = "Federated identity credentials created by the module."
  value       = module.user_assigned_identity.federated_identity_credentials
}

output "resource_group_name" {
  description = "The resource group name."
  value       = azurerm_resource_group.example.name
}

output "role_assignment_id" {
  description = "The role assignment ID."
  value       = azurerm_role_assignment.rg_reader.id
}
