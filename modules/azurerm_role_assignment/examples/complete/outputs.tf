output "role_assignment_id" {
  description = "The role assignment ID."
  value       = module.role_assignment.id
}

output "scope" {
  description = "The scope used for the role assignment."
  value       = module.role_assignment.scope
}
