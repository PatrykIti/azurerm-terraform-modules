output "securityrole_assignment_id" {
  description = "The security role assignment ID."
  value       = try(azuredevops_securityrole_assignment.securityrole_assignment.id, null)
}
