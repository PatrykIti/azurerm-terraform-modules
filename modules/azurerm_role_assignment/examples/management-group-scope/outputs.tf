output "role_assignment_id" {
  description = "The role assignment ID."
  value       = module.role_assignment.id
}

output "scope" {
  description = "The management group scope used."
  value       = module.role_assignment.scope
}
