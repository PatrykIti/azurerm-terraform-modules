output "role_assignment_id" {
  description = "The role assignment ID."
  value       = module.role_assignment.id
}

output "principal_id" {
  description = "The principal ID assigned."
  value       = module.role_assignment.principal_id
}
