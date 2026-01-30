output "user_assigned_identity_id" {
  description = "The ID of the created User Assigned Identity."
  value       = module.user_assigned_identity.id
}

output "federated_identity_credentials" {
  description = "Federated identity credentials created by the module."
  value       = module.user_assigned_identity.federated_identity_credentials
}
