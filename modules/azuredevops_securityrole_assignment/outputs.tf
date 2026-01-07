output "securityrole_assignment_ids" {
  description = "Map of security role assignment IDs keyed by assignment key."
  value       = try({ for key, assignment in azuredevops_securityrole_assignment.securityrole_assignment : key => assignment.id }, {})
}
