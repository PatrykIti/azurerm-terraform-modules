output "role_assignment_id" {
  description = "The role assignment ID."
  value       = module.role_assignment.id
}

output "condition" {
  description = "The condition expression applied."
  value       = module.role_assignment.condition
}
