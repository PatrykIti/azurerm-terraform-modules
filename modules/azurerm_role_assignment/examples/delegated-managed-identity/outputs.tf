output "role_assignment_id" {
  description = "The role assignment ID."
  value       = module.role_assignment.id
}

output "delegated_managed_identity_resource_id" {
  description = "The delegated managed identity resource ID."
  value       = module.role_assignment.delegated_managed_identity_resource_id
}
