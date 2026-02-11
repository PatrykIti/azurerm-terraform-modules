output "role_assignment_id" {
  description = "The role assignment ID."
  value       = module.role_assignment.id
}

output "role_definition_id" {
  description = "The custom role definition ID."
  value       = module.role_definition.role_definition_id
}
