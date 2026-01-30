output "user_assigned_identity_id" {
  description = "The ID of the created User Assigned Identity."
  value       = module.user_assigned_identity.id
}

output "user_assigned_identity_client_id" {
  description = "The client ID of the created User Assigned Identity."
  value       = module.user_assigned_identity.client_id
}

output "user_assigned_identity_principal_id" {
  description = "The principal ID of the created User Assigned Identity."
  value       = module.user_assigned_identity.principal_id
}
