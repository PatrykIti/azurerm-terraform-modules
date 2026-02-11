output "user_assigned_identity_id" {
  description = "The ID of the created User Assigned Identity."
  value       = module.user_assigned_identity.id
}

output "user_assigned_identity_name" {
  description = "The name of the created User Assigned Identity."
  value       = module.user_assigned_identity.name
}

output "user_assigned_identity_client_id" {
  description = "The client ID of the created User Assigned Identity."
  value       = module.user_assigned_identity.client_id
}

output "user_assigned_identity_principal_id" {
  description = "The principal ID of the created User Assigned Identity."
  value       = module.user_assigned_identity.principal_id
}

output "user_assigned_identity_tenant_id" {
  description = "The tenant ID of the created User Assigned Identity."
  value       = module.user_assigned_identity.tenant_id
}

output "resource_group_name" {
  description = "The resource group name."
  value       = azurerm_resource_group.example.name
}
